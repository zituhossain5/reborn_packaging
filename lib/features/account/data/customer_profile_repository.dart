import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../auth/config/customer_account_config.dart';
import '../../auth/data/customer_account_discovery_service.dart';
import '../models/shopify_customer.dart';

abstract interface class CustomerProfileRepository {
  Future<ShopifyCustomer> fetchCustomer({required String accessToken});
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

  static const customerQuery = r'''
    query CustomerIdentity {
      customer {
        id
        displayName
        firstName
        lastName
        emailAddress {
          emailAddress
        }
      }
    }
  ''';

  final CustomerAccountConfig _config;
  final CustomerAccountDiscoveryService _discoveryService;
  final Duration _timeout;

  @override
  Future<ShopifyCustomer> fetchCustomer({required String accessToken}) async {
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
      request.write(jsonEncode({'query': customerQuery}));

      final response = await request.close().timeout(_timeout);
      final body = await utf8.decoder.bind(response).join().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CustomerProfileFailure(
          response.statusCode == 401
              ? 'Your account session has expired. Please sign in again.'
              : 'Unable to load your Shopify account. Please try again.',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const CustomerProfileFailure(
          'Shopify returned invalid customer data.',
        );
      }
      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw const CustomerProfileFailure(
          'Unable to load your Shopify account. Please try again.',
        );
      }
      final data = decoded['data'];
      final customer = data is Map<String, dynamic> ? data['customer'] : null;
      if (customer is! Map<String, dynamic>) {
        throw const CustomerProfileFailure(
          'The signed-in Shopify customer is unavailable.',
        );
      }
      return ShopifyCustomer.fromShopifyJson(customer);
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
}

class CustomerProfileFailure implements Exception {
  const CustomerProfileFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
