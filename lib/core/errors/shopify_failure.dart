sealed class ShopifyFailure implements Exception {
  const ShopifyFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ShopifyConfigurationFailure extends ShopifyFailure {
  const ShopifyConfigurationFailure(super.message);
}

final class ShopifyNetworkFailure extends ShopifyFailure {
  const ShopifyNetworkFailure(super.message);
}

final class ShopifyTimeoutFailure extends ShopifyFailure {
  const ShopifyTimeoutFailure(super.message);
}

final class ShopifyHttpFailure extends ShopifyFailure {
  const ShopifyHttpFailure({required this.statusCode})
    : super('Shopify request failed with HTTP status $statusCode.');

  final int statusCode;
}

final class ShopifyGraphqlFailure extends ShopifyFailure {
  ShopifyGraphqlFailure(this.errors)
    : super('Shopify returned GraphQL errors: ${errors.join('; ')}');

  final List<String> errors;
}

final class ShopifyResponseFailure extends ShopifyFailure {
  const ShopifyResponseFailure(super.message);
}
