import '../errors/shopify_failure.dart';

class ShopifyConfig {
  const ShopifyConfig({
    required this.storeDomain,
    required this.apiVersion,
    required this.storefrontToken,
  });

  factory ShopifyConfig.fromEnvironment() {
    const config = ShopifyConfig(
      storeDomain: String.fromEnvironment('SHOPIFY_STORE_DOMAIN'),
      apiVersion: String.fromEnvironment('SHOPIFY_API_VERSION'),
      storefrontToken: String.fromEnvironment('SHOPIFY_STOREFRONT_TOKEN'),
    );
    config.validate();
    return config;
  }

  final String storeDomain;
  final String apiVersion;
  final String storefrontToken;

  Uri get endpoint => Uri.https(storeDomain, '/api/$apiVersion/graphql.json');

  void validate() {
    final missingKeys = <String>[
      if (storeDomain.trim().isEmpty) 'SHOPIFY_STORE_DOMAIN',
      if (apiVersion.trim().isEmpty) 'SHOPIFY_API_VERSION',
      if (storefrontToken.trim().isEmpty) 'SHOPIFY_STOREFRONT_TOKEN',
    ];

    if (missingKeys.isNotEmpty) {
      throw ShopifyConfigurationFailure(
        'Missing runtime configuration: ${missingKeys.join(', ')}.',
      );
    }
  }
}
