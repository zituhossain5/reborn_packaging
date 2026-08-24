import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../auth/config/customer_account_config.dart';
import '../../auth/data/customer_account_discovery_service.dart';
import '../models/customer_order_details.dart';

abstract interface class CustomerOrderRepository {
  Future<CustomerOrderDetails> fetchOrder({
    required String orderId,
    required String accessToken,
  });

  Future<CustomerOrderDetails?> findRecentOrder({
    required String orderId,
    required String accessToken,
  });
}

enum ShopifyCheckoutOrderResource { order, orderIdentity, numericOnly, other }

class ShopifyCheckoutOrderIdentifier {
  const ShopifyCheckoutOrderIdentifier._({
    required this.source,
    required this.resource,
    this.numericTail,
  });

  factory ShopifyCheckoutOrderIdentifier.parse(String value) {
    final source = value.trim();
    if (RegExp(r'^\d+$').hasMatch(source)) {
      return ShopifyCheckoutOrderIdentifier._(
        source: source,
        resource: ShopifyCheckoutOrderResource.numericOnly,
        numericTail: source,
      );
    }
    final match = RegExp(
      r'^gid://shopify/(Order|OrderIdentity)/(\d+)$',
    ).firstMatch(source);
    if (match == null) {
      return ShopifyCheckoutOrderIdentifier._(
        source: source,
        resource: ShopifyCheckoutOrderResource.other,
      );
    }
    return ShopifyCheckoutOrderIdentifier._(
      source: source,
      resource: match.group(1) == 'Order'
          ? ShopifyCheckoutOrderResource.order
          : ShopifyCheckoutOrderResource.orderIdentity,
      numericTail: match.group(2),
    );
  }

  final String source;
  final ShopifyCheckoutOrderResource resource;
  final String? numericTail;

  bool get supportsDirectLookup =>
      resource == ShopifyCheckoutOrderResource.order;

  bool matchesCustomerOrderId(String candidateId) {
    final candidate = ShopifyCheckoutOrderIdentifier.parse(candidateId);
    if (resource == ShopifyCheckoutOrderResource.order) {
      return source == candidate.source;
    }
    return resource == ShopifyCheckoutOrderResource.orderIdentity &&
        candidate.resource == ShopifyCheckoutOrderResource.order &&
        numericTail != null &&
        numericTail == candidate.numericTail;
  }
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

  static const recentOrdersQuery = r'''
    query RecentCustomerOrders($first: Int!, $after: String) {
      customer {
        orders(
          first: $first
          after: $after
          reverse: true
          sortKey: PROCESSED_AT
        ) {
          nodes {
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
          pageInfo { hasNextPage endCursor }
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
    final exactOrderId = orderId.trim();
    if (exactOrderId.isEmpty || accessToken.trim().isEmpty) {
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
          'variables': {'id': exactOrderId},
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
        final messages = errors
            .whereType<Map<String, dynamic>>()
            .map((error) => error['message'] as String? ?? '')
            .where((message) => message.isNotEmpty)
            .toList(growable: false);
        final details = messages.isEmpty
            ? 'Unknown Customer Account GraphQL error.'
            : messages.join('; ');
        final normalizedDetails = details.toLowerCase();
        if (normalizedDetails.contains('not found') ||
            normalizedDetails.contains('does not exist')) {
          throw const CustomerOrderNotFoundFailure();
        }
        throw CustomerOrderGraphqlFailure(
          kDebugMode
              ? 'Customer Account order lookup failed: $details'
              : 'Unable to load this order. Please try again.',
        );
      }
      final data = decoded['data'];
      final order = data is Map<String, dynamic> ? data['order'] : null;
      if (order is! Map<String, dynamic>) {
        throw const CustomerOrderNotFoundFailure();
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

  @override
  Future<CustomerOrderDetails?> findRecentOrder({
    required String orderId,
    required String accessToken,
  }) async {
    final checkoutIdentifier = ShopifyCheckoutOrderIdentifier.parse(orderId);
    if (checkoutIdentifier.source.isEmpty || accessToken.trim().isEmpty) {
      throw const CustomerOrderFailure('Order details are unavailable.');
    }

    _config.validate();
    final discovery = await _discoveryService.discover(_config);
    String? after;
    const maximumPages = 5;
    for (var page = 0; page < maximumPages; page++) {
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
            'query': recentOrdersQuery,
            'variables': {'first': 20, 'after': after},
          }),
        );

        final response = await request.close().timeout(_timeout);
        final body = await utf8.decoder.bind(response).join().timeout(_timeout);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw CustomerOrderFailure(
            response.statusCode == 401
                ? 'Your account session has expired. Please sign in again.'
                : 'Unable to load recent orders. Please try again.',
          );
        }

        final decoded = jsonDecode(body);
        if (decoded is! Map<String, dynamic>) {
          throw const CustomerOrderFailure(
            'Shopify returned an invalid recent orders response.',
          );
        }
        final errors = decoded['errors'];
        if (errors is List && errors.isNotEmpty) {
          final messages = errors
              .whereType<Map<String, dynamic>>()
              .map((error) => error['message'] as String? ?? '')
              .where((message) => message.isNotEmpty)
              .toList(growable: false);
          final details = messages.isEmpty
              ? 'Unknown Customer Account GraphQL error.'
              : messages.join('; ');
          throw CustomerOrderGraphqlFailure(
            kDebugMode
                ? 'Customer Account recent orders lookup failed: $details'
                : 'Unable to load recent orders. Please try again.',
          );
        }
        final data = decoded['data'];
        final customer = data is Map<String, dynamic> ? data['customer'] : null;
        final connection = customer is Map<String, dynamic>
            ? customer['orders']
            : null;
        if (connection is! Map<String, dynamic>) {
          throw const CustomerOrderGraphqlFailure(
            'Shopify order history is unavailable for this account.',
          );
        }
        final nodes = connection['nodes'];
        if (nodes is List) {
          for (final node in nodes.whereType<Map<String, dynamic>>()) {
            if (checkoutIdentifier.matchesCustomerOrderId(
              node['id'] as String? ?? '',
            )) {
              return CustomerOrderDetails.fromShopifyJson(node);
            }
          }
        }
        final pageInfo = connection['pageInfo'];
        final hasNextPage =
            pageInfo is Map<String, dynamic> &&
            (pageInfo['hasNextPage'] as bool? ?? false);
        final endCursor = pageInfo is Map<String, dynamic>
            ? pageInfo['endCursor'] as String?
            : null;
        if (!hasNextPage || endCursor == null || endCursor.isEmpty) break;
        after = endCursor;
      } on CustomerOrderFailure {
        rethrow;
      } on TimeoutException {
        throw const CustomerOrderFailure(
          'Loading recent orders timed out. Please try again.',
        );
      } on SocketException {
        throw const CustomerOrderFailure(
          'Unable to connect to Shopify. Check your connection and try again.',
        );
      } on FormatException {
        throw const CustomerOrderFailure(
          'Shopify returned invalid recent order data.',
        );
      } finally {
        client.close(force: true);
      }
    }
    return null;
  }
}

class CustomerOrderFailure implements Exception {
  const CustomerOrderFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class CustomerOrderNotFoundFailure extends CustomerOrderFailure {
  const CustomerOrderNotFoundFailure()
    : super('This order is not available for the signed-in account yet.');
}

class CustomerOrderGraphqlFailure extends CustomerOrderFailure {
  const CustomerOrderGraphqlFailure(super.message);
}
