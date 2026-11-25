import 'dart:convert';
import 'dart:io';

import 'package:reborn_packaging/core/config/shopify_config.dart';
import 'package:reborn_packaging/core/errors/shopify_failure.dart';
import 'package:reborn_packaging/features/auth/config/customer_account_config.dart';

void main(List<String> args) {
  try {
    final defines = _decodeDefines(Platform.environment['DART_DEFINES'] ?? '');
    final storefront = ShopifyConfig(
      storeDomain: defines['SHOPIFY_STORE_DOMAIN'] ?? '',
      apiVersion: defines['SHOPIFY_API_VERSION'] ?? '',
      storefrontToken: defines['SHOPIFY_STOREFRONT_TOKEN'] ?? '',
    );
    storefront.validate();

    final redirect = defines['SHOPIFY_CUSTOMER_ACCOUNT_REDIRECT_URI'] ?? '';
    final rawScopes =
        defines['SHOPIFY_CUSTOMER_ACCOUNT_SCOPES'] ??
        CustomerAccountConfig.defaultScopes;
    final customer = CustomerAccountConfig(
      storeDomain: storefront.storeDomain,
      clientId: defines['SHOPIFY_CUSTOMER_ACCOUNT_CLIENT_ID'] ?? '',
      redirectUri: redirect.trim().isEmpty ? null : Uri.tryParse(redirect),
      scopes: rawScopes.split(RegExp(r'\s+')),
    );
    customer.validate();

    final urlTypes = args.length == 1 ? jsonDecode(args.single) : null;
    final callbackRegistered =
        urlTypes is List &&
        urlTypes.whereType<Map<String, dynamic>>().any((type) {
          final schemes = type['CFBundleURLSchemes'];
          return schemes is List &&
              schemes.contains(customer.redirectUri!.scheme);
        });
    if (!callbackRegistered) {
      _fail(
        'SHOPIFY_CUSTOMER_ACCOUNT_REDIRECT_URI must match a URL scheme in Runner Info.plist.',
      );
    }
  } on ShopifyConfigurationFailure catch (failure) {
    _fail(failure.message);
  } on CustomerAuthException catch (failure) {
    _fail(failure.message);
  } on FormatException {
    _fail('Could not read compile-time Dart defines or Runner URL types.');
  }
}

Map<String, String> _decodeDefines(String encoded) {
  final defines = <String, String>{};
  for (final entry in encoded.split(',')) {
    if (entry.isEmpty) continue;
    final definition = utf8.decode(base64.decode(entry));
    final separator = definition.indexOf('=');
    if (separator <= 0) throw const FormatException();
    final key = definition.substring(0, separator);
    final value = definition.substring(separator + 1);
    if (key.startsWith('SHOPIFY_') &&
        defines.containsKey(key) &&
        defines[key] != value) {
      throw const FormatException();
    }
    defines[key] = value;
  }
  return defines;
}

void _fail(String message) {
  stderr.writeln('error: iOS release configuration: $message');
  stderr.writeln('Build with --dart-define-from-file=config/prod.json.');
  exitCode = 1;
}
