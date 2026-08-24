import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../auth/config/customer_account_config.dart';
import '../../auth/data/customer_account_discovery_service.dart';
import '../models/customer_order_summary.dart';

abstract interface class CustomerOrdersRepository {
  Future<CustomerOrderPage> fetchOrders({
    required String accessToken,
    String? after,
  });
}

class ShopifyCustomerOrdersRepository implements CustomerOrdersRepository {
  ShopifyCustomerOrdersRepository({
    required CustomerAccountConfig config,
    CustomerAccountDiscoveryService discoveryService =
        const CustomerAccountDiscoveryService(),
    Duration timeout = const Duration(seconds: 15),
  }) : this._(config, discoveryService, timeout);

  ShopifyCustomerOrdersRepository._(
    this._config,
    this._discoveryService,
    this._timeout,
  );

  static const pageSize = 20;

  static const customerOrdersQuery = r'''
    query CustomerOrders($first: Int!, $after: String) {
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
            totalPrice {
              amount
              currencyCode
            }
            lineItems(first: 250) {
              nodes {
                quantity
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  ''';

  final CustomerAccountConfig _config;
  final CustomerAccountDiscoveryService _discoveryService;
  final Duration _timeout;

  @override
  Future<CustomerOrderPage> fetchOrders({
    required String accessToken,
    String? after,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw const CustomerOrdersFailure('Sign in to load your orders.');
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
          'query': customerOrdersQuery,
          'variables': {'first': pageSize, 'after': after},
        }),
      );

      final response = await request.close().timeout(_timeout);
      final body = await utf8.decoder.bind(response).join().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CustomerOrdersFailure(
          response.statusCode == 401
              ? 'Your account session has expired. Please sign in again.'
              : 'Unable to load your orders. Please try again.',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const CustomerOrdersFailure(
          'Shopify returned invalid order history data.',
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
        if (kDebugMode) {
          debugPrint('Customer Account order history failed: $details');
        }
        throw CustomerOrdersFailure(
          kDebugMode
              ? 'Customer Account order history failed: $details'
              : 'Unable to load your Shopify orders. Please try again.',
        );
      }
      final data = decoded['data'];
      final customer = data is Map<String, dynamic> ? data['customer'] : null;
      final orders = customer is Map<String, dynamic>
          ? customer['orders']
          : null;
      if (orders is! Map<String, dynamic>) {
        throw const CustomerOrdersFailure(
          'Shopify order history is unavailable for this account.',
        );
      }
      return CustomerOrderPage.fromShopifyJson(orders);
    } on CustomerOrdersFailure {
      rethrow;
    } on TimeoutException {
      throw const CustomerOrdersFailure(
        'Loading your orders timed out. Please try again.',
      );
    } on SocketException {
      throw const CustomerOrdersFailure(
        'Unable to connect to Shopify. Check your connection and try again.',
      );
    } on FormatException {
      throw const CustomerOrdersFailure(
        'Shopify returned invalid order history data.',
      );
    } finally {
      client.close(force: true);
    }
  }
}

class CustomerOrdersFailure implements Exception {
  const CustomerOrdersFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
