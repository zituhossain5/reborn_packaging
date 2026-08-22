import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../auth/config/customer_account_config.dart';
import '../../auth/data/customer_account_discovery_service.dart';
import '../models/customer_order_details.dart';

abstract interface class CustomerOrderRepository {
  Future<CustomerOrderDetails> fetchOrder({
    required String orderId,
    required String accessToken,
  });
}

class ShopifyCustomerOrderRepository implements CustomerOrderRepository {
  ShopifyCustomerOrderRepository({
    required CustomerAccountConfig config,
    CustomerAccountDiscoveryService discoveryService =
        const CustomerAccountDiscoveryService(),
    Duration timeout = const Duration(seconds: 15),
  }) : this._(config, discoveryService, timeout);

  ShopifyCustomerOrderRepository._(
    this._config,
    this._discoveryService,
    this._timeout,
  );

  static const orderQuery = r'''
    query CustomerOrderDetails($id: ID!) {
      order(id: $id) {
        id
        name
        confirmationNumber
        createdAt
        financialStatus
        fulfillmentStatus
        statusPageUrl
        lineItems(first: 100) {
          nodes {
            id
            name
            quantity
            variantTitle
            sku
            image { url altText }
            totalPrice { amount currencyCode }
          }
        }
        subtotal { amount currencyCode }
        totalShipping { amount currencyCode }
        totalTax { amount currencyCode }
        totalPrice { amount currencyCode }
        shippingAddress {
          firstName
          lastName
          formatted
        }
        fulfillments(first: 20) {
          nodes {
            id
            status
            latestShipmentStatus
            estimatedDeliveryAt
            trackingInformation { company number url }
          }
        }
      }
    }
  ''';

  final CustomerAccountConfig _config;
  final CustomerAccountDiscoveryService _discoveryService;
  final Duration _timeout;

  @override
  Future<CustomerOrderDetails> fetchOrder({
    required String orderId,
    required String accessToken,
  }) async {
    final normalizedId = _normalizeOrderId(orderId);
    if (normalizedId == null || accessToken.trim().isEmpty) {
      throw const CustomerOrderFailure('Order details are unavailable.');
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
      request.write(
        jsonEncode({
          'query': orderQuery,
          'variables': {'id': normalizedId},
        }),
      );

      final response = await request.close().timeout(_timeout);
      final body = await utf8.decoder.bind(response).join().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CustomerOrderFailure(
          response.statusCode == 401
              ? 'Your account session has expired. Please sign in again.'
              : 'Unable to load order details. Please try again.',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const CustomerOrderFailure(
          'Shopify returned an invalid order response.',
        );
      }
      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw const CustomerOrderFailure(
          'Unable to load this order. Check your account access and try again.',
        );
      }
      final data = decoded['data'];
      final order = data is Map<String, dynamic> ? data['order'] : null;
      if (order is! Map<String, dynamic>) {
        throw const CustomerOrderFailure(
          'This order is not available for the signed-in account.',
        );
      }
      return CustomerOrderDetails.fromShopifyJson(order);
    } on CustomerOrderFailure {
      rethrow;
    } on TimeoutException {
      throw const CustomerOrderFailure(
        'Loading order details timed out. Please try again.',
      );
    } on SocketException {
      throw const CustomerOrderFailure(
        'Unable to connect to Shopify. Check your connection and try again.',
      );
    } on FormatException {
      throw const CustomerOrderFailure('Shopify returned invalid order data.');
    } finally {
      client.close(force: true);
    }
  }

  // Checkout Kit can return either a Shopify GID or its numeric Order ID.
  // The raw completion value remains unchanged; this only converts the numeric
  // form into the canonical GraphQL ID required by Customer Account API.
  String? _normalizeOrderId(String value) {
    final id = value.trim();
    if (id.startsWith('gid://shopify/Order/')) return id;
    if (RegExp(r'^\d+$').hasMatch(id)) return 'gid://shopify/Order/$id';
    return null;
  }
}

class CustomerOrderFailure implements Exception {
  const CustomerOrderFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
