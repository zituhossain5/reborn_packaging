import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../auth/config/customer_account_config.dart';
import '../../auth/data/customer_account_discovery_service.dart';
import '../models/account_models.dart';
import '../models/shopify_customer.dart';

abstract interface class CustomerProfileRepository {
  Future<ShopifyCustomer> fetchCustomer({required String accessToken});

  Future<ShopifyCustomer> createAddress({
    required String accessToken,
    required CustomerAddressInput address,
    bool defaultAddress = false,
  });

  Future<ShopifyCustomer> updateAddress({
    required String accessToken,
    required String addressId,
    required CustomerAddressInput address,
    bool? defaultAddress,
  });

  Future<ShopifyCustomer> deleteAddress({
    required String accessToken,
    required String addressId,
  });

  Future<ShopifyCustomer> setEmailMarketingSubscribed({
    required String accessToken,
    required bool subscribed,
  });
}

class ShopifyCustomerProfileRepository implements CustomerProfileRepository {
  ShopifyCustomerProfileRepository({
    required CustomerAccountConfig config,
    CustomerAccountDiscoveryService discoveryService =
        const CustomerAccountDiscoveryService(),
    Duration timeout = const Duration(seconds: 15),
  }) : this._(config, discoveryService, timeout);

  ShopifyCustomerProfileRepository._(
    this._config,
    this._discoveryService,
    this._timeout,
  );

  static const customerQuery =
      r'''
    query CustomerProfile {
      customer {
        id
        displayName
        firstName
        lastName
        emailAddress { emailAddress marketingState }
        defaultAddress { ...CustomerProfileAddress }
        addresses(first: 100) {
          nodes { ...CustomerProfileAddress }
        }
      }
    }
  ''' +
      _addressFragment;

  static const customerAddressCreateMutation = r'''
    mutation CustomerAddressCreate(
      $address: CustomerAddressInput!
      $defaultAddress: Boolean
    ) {
      customerAddressCreate(
        address: $address
        defaultAddress: $defaultAddress
      ) {
        customerAddress { id }
        userErrors { field message }
      }
    }
  ''';

  static const customerAddressUpdateMutation = r'''
    mutation CustomerAddressUpdate(
      $addressId: ID!
      $address: CustomerAddressInput
      $defaultAddress: Boolean
    ) {
      customerAddressUpdate(
        addressId: $addressId
        address: $address
        defaultAddress: $defaultAddress
      ) {
        customerAddress { id }
        userErrors { field message }
      }
    }
  ''';

  static const customerAddressDeleteMutation = r'''
    mutation CustomerAddressDelete($addressId: ID!) {
      customerAddressDelete(addressId: $addressId) {
        deletedAddressId
        userErrors { field message }
      }
    }
  ''';

  static const customerEmailMarketingSubscribeMutation = r'''
    mutation CustomerEmailMarketingSubscribe {
      customerEmailMarketingSubscribe {
        emailAddress { emailAddress marketingState }
        userErrors { field message }
      }
    }
  ''';

  static const customerEmailMarketingUnsubscribeMutation = r'''
    mutation CustomerEmailMarketingUnsubscribe {
      customerEmailMarketingUnsubscribe {
        emailAddress { emailAddress marketingState }
        userErrors { field message }
      }
    }
  ''';

  static const _addressFragment = r'''
    fragment CustomerProfileAddress on CustomerAddress {
      id
      firstName
      lastName
      address1
      address2
      city
      province
      zoneCode
      zip
      country
      territoryCode
      phoneNumber
      formatted(withName: false, withCompany: true)
    }
  ''';

  final CustomerAccountConfig _config;
  final CustomerAccountDiscoveryService _discoveryService;
  final Duration _timeout;

  @override
  Future<ShopifyCustomer> fetchCustomer({required String accessToken}) async {
    final data = await _execute(query: customerQuery, accessToken: accessToken);
    final customer = data['customer'];
    if (customer is! Map<String, dynamic>) {
      throw const CustomerProfileFailure(
        'The signed-in Shopify customer is unavailable.',
      );
    }
    return ShopifyCustomer.fromShopifyJson(customer);
  }

  @override
  Future<ShopifyCustomer> createAddress({
    required String accessToken,
    required CustomerAddressInput address,
    bool defaultAddress = false,
  }) async {
    final data = await _execute(
      query: customerAddressCreateMutation,
      variables: {
        'address': address.toShopifyInput(),
        'defaultAddress': defaultAddress,
      },
      accessToken: accessToken,
    );
    _requireSuccessfulPayload(data, 'customerAddressCreate');
    return fetchCustomer(accessToken: accessToken);
  }

  @override
  Future<ShopifyCustomer> updateAddress({
    required String accessToken,
    required String addressId,
    required CustomerAddressInput address,
    bool? defaultAddress,
  }) async {
    if (addressId.trim().isEmpty) {
      throw const CustomerProfileFailure('This address cannot be updated.');
    }
    final data = await _execute(
      query: customerAddressUpdateMutation,
      variables: {
        'addressId': addressId,
        'address': address.toShopifyInput(),
        'defaultAddress': defaultAddress,
      },
      accessToken: accessToken,
    );
    _requireSuccessfulPayload(data, 'customerAddressUpdate');
    return fetchCustomer(accessToken: accessToken);
  }

  @override
  Future<ShopifyCustomer> deleteAddress({
    required String accessToken,
    required String addressId,
  }) async {
    if (addressId.trim().isEmpty) {
      throw const CustomerProfileFailure('This address cannot be deleted.');
    }
    final data = await _execute(
      query: customerAddressDeleteMutation,
      variables: {'addressId': addressId},
      accessToken: accessToken,
    );
    _requireSuccessfulPayload(data, 'customerAddressDelete');
    return fetchCustomer(accessToken: accessToken);
  }

  @override
  Future<ShopifyCustomer> setEmailMarketingSubscribed({
    required String accessToken,
    required bool subscribed,
  }) async {
    final operation = subscribed
        ? 'customerEmailMarketingSubscribe'
        : 'customerEmailMarketingUnsubscribe';
    final data = await _execute(
      query: subscribed
          ? customerEmailMarketingSubscribeMutation
          : customerEmailMarketingUnsubscribeMutation,
      accessToken: accessToken,
    );
    _requireSuccessfulPayload(data, operation);
    return fetchCustomer(accessToken: accessToken);
  }

  Future<Map<String, dynamic>> _execute({
    required String query,
    required String accessToken,
    Map<String, dynamic> variables = const {},
  }) async {
    if (accessToken.trim().isEmpty) {
      throw const CustomerProfileFailure('Sign in to load your account.');
    }
    _config.validate();
    final discovery = await _discoveryService.discover(_config);
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client
          .postUrl(discovery.graphqlEndpoint)
          .timeout(_timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, accessToken);
      request.headers.set(HttpHeaders.userAgentHeader, 'RebornPackaging/1.0');
      request.write(jsonEncode({'query': query, 'variables': variables}));

      final response = await request.close().timeout(_timeout);
      final body = await utf8.decoder.bind(response).join().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CustomerProfileFailure(
          response.statusCode == 401
              ? 'Your account session has expired. Please sign in again.'
              : 'Unable to update your Shopify profile. Please try again.',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const CustomerProfileFailure(
          'Shopify returned invalid customer data.',
        );
      }
      final graphQlErrors = _errorMessages(decoded['errors']);
      if (graphQlErrors.isNotEmpty) {
        throw CustomerProfileFailure(_withScopeHelp(graphQlErrors.join('; ')));
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const CustomerProfileFailure(
          'Shopify returned incomplete customer data.',
        );
      }
      return data;
    } on CustomerProfileFailure {
      rethrow;
    } on TimeoutException {
      throw const CustomerProfileFailure(
        'Loading your account timed out. Please try again.',
      );
    } on SocketException {
      throw const CustomerProfileFailure(
        'Unable to connect to Shopify. Check your connection and try again.',
      );
    } on FormatException {
      throw const CustomerProfileFailure(
        'Shopify returned invalid customer data.',
      );
    } finally {
      client.close(force: true);
    }
  }

  void _requireSuccessfulPayload(Map<String, dynamic> data, String key) {
    final payload = data[key];
    if (payload is! Map<String, dynamic>) {
      throw const CustomerProfileFailure(
        'Shopify returned an invalid profile update response.',
      );
    }
    final errors = _errorMessages(payload['userErrors']);
    if (errors.isNotEmpty) {
      throw CustomerProfileFailure(_withScopeHelp(errors.join('; ')));
    }
  }

  List<String> _errorMessages(Object? errors) {
    if (errors is! List) return const [];
    return errors
        .whereType<Map<String, dynamic>>()
        .map((error) => error['message'] as String? ?? '')
        .where((message) => message.trim().isNotEmpty)
        .toList(growable: false);
  }

  String _withScopeHelp(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('access denied') ||
        normalized.contains('permission') ||
        normalized.contains('scope')) {
      return '$message Required Customer Account scopes: '
          'customer_read_customers and customer_write_customers.';
    }
    return message;
  }
}

class CustomerProfileFailure implements Exception {
  const CustomerProfileFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
