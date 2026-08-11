import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../config/customer_account_config.dart';
import '../models/customer_account_discovery.dart';

class CustomerAccountDiscoveryService {
  const CustomerAccountDiscoveryService();

  static const _timeout = Duration(seconds: 15);

  Future<CustomerAccountDiscovery> discover(
    CustomerAccountConfig config,
  ) async {
    final responses = await Future.wait([
      _getJson(config.openIdDiscoveryUri),
      _getJson(config.apiDiscoveryUri),
    ]);
    final openId = responses[0];
    final api = responses[1];

    return CustomerAccountDiscovery(
      authorizationEndpoint: _requiredHttpsUri(
        openId,
        'authorization_endpoint',
      ),
      tokenEndpoint: _requiredHttpsUri(openId, 'token_endpoint'),
      logoutEndpoint: _requiredHttpsUri(openId, 'end_session_endpoint'),
      graphqlEndpoint: _requiredHttpsUri(api, 'graphql_api'),
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(uri).timeout(_timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'RebornPackaging/1.0');
      final response = await request.close().timeout(_timeout);
      final body = await utf8.decoder.bind(response).join().timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CustomerAuthException(
          'Shopify account discovery failed (${response.statusCode}).',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const CustomerAuthException(
          'Shopify account discovery returned an invalid response.',
        );
      }
      return decoded;
    } on CustomerAuthException {
      rethrow;
    } on TimeoutException {
      throw const CustomerAuthException(
        'Shopify account discovery timed out. Please try again.',
      );
    } catch (_) {
      throw const CustomerAuthException(
        'Unable to connect to Shopify customer accounts.',
      );
    } finally {
      client.close(force: true);
    }
  }

  Uri _requiredHttpsUri(Map<String, dynamic> json, String key) {
    final uri = Uri.tryParse(json[key] as String? ?? '');
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const CustomerAuthException(
        'Shopify account discovery is missing a required endpoint.',
      );
    }
    return uri;
  }
}
