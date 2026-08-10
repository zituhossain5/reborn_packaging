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

final class ShopifyUserFailure extends ShopifyFailure {
  ShopifyUserFailure({required this.errors})
    : super(
        errors.map((error) => '${error.source}: ${error.message}').join('; '),
      );

  final List<ShopifyUserError> errors;

  bool get indicatesInvalidCart => errors.any((error) {
    final code = error.code?.toUpperCase() ?? '';
    final message = error.message.toLowerCase();
    return code.contains('CART') &&
            (code.contains('NOT_FOUND') || code.contains('INVALID')) ||
        message.contains('cart') &&
            (message.contains('not found') || message.contains('invalid'));
  });
}

class ShopifyUserError {
  const ShopifyUserError({
    required this.message,
    this.code,
    this.field,
    this.source = 'Shopify user error',
  });

  final String message;
  final String? code;
  final List<String>? field;
  final String source;
}
