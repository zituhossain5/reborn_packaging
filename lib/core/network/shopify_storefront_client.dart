import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config/shopify_config.dart';
import '../errors/shopify_failure.dart';

class ShopifyStorefrontClient {
  ShopifyStorefrontClient(
    this._config, {
    Duration timeout = const Duration(seconds: 15),
    HttpClient? httpClient,
  }) : _timeout = timeout,
       _httpClient = httpClient ?? HttpClient() {
    _httpClient.connectionTimeout = timeout;
  }

  final ShopifyConfig _config;
  final Duration _timeout;
  final HttpClient _httpClient;

  Future<Map<String, dynamic>> execute(
    String query, {
    Map<String, dynamic> variables = const {},
  }) async {
    try {
      final request = await _httpClient
          .postUrl(_config.endpoint)
          .timeout(_timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set(
        'X-Shopify-Storefront-Access-Token',
        _config.storefrontToken,
      );
      request.write(jsonEncode({'query': query, 'variables': variables}));

      final response = await request.close().timeout(_timeout);
      final responseBody = await utf8.decoder
          .bind(response)
          .join()
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ShopifyHttpFailure(statusCode: response.statusCode);
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) {
        throw const ShopifyResponseFailure(
          'Shopify returned an invalid response.',
        );
      }

      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw ShopifyGraphqlFailure(
          errors.map(_graphqlErrorMessage).toList(growable: false),
        );
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw const ShopifyResponseFailure(
          'Shopify response did not contain data.',
        );
      }

      return data;
    } on ShopifyFailure {
      rethrow;
    } on TimeoutException {
      throw const ShopifyTimeoutFailure('Shopify request timed out.');
    } on SocketException {
      throw const ShopifyNetworkFailure(
        'Unable to connect to the Shopify store.',
      );
    } on FormatException {
      throw const ShopifyResponseFailure(
        'Shopify returned malformed response data.',
      );
    } on HttpException {
      throw const ShopifyNetworkFailure('Shopify network request failed.');
    }
  }

  void close() => _httpClient.close(force: true);

  static String _graphqlErrorMessage(Object? error) {
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return 'Unknown GraphQL error';
  }
}
