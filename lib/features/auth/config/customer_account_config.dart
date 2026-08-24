class CustomerAccountConfig {
  const CustomerAccountConfig({
    required this.storeDomain,
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
  });

  factory CustomerAccountConfig.fromEnvironment() {
    const rawScopes = String.fromEnvironment(
      'SHOPIFY_CUSTOMER_ACCOUNT_SCOPES',
      defaultValue: 'openid email customer-account-api:full',
    );
    return CustomerAccountConfig(
      storeDomain: const String.fromEnvironment('SHOPIFY_STORE_DOMAIN'),
      clientId: const String.fromEnvironment(
        'SHOPIFY_CUSTOMER_ACCOUNT_CLIENT_ID',
      ),
      redirectUri: Uri.tryParse(
        const String.fromEnvironment('SHOPIFY_CUSTOMER_ACCOUNT_REDIRECT_URI'),
      ),
      scopes: rawScopes
          .split(RegExp(r'\s+'))
          .where((scope) => scope.isNotEmpty)
          .toList(growable: false),
    );
  }

  final String storeDomain;
  final String clientId;
  final Uri? redirectUri;
  final List<String> scopes;

  Uri get openIdDiscoveryUri =>
      Uri.https(storeDomain, '/.well-known/openid-configuration');

  Uri get apiDiscoveryUri =>
      Uri.https(storeDomain, '/.well-known/customer-account-api');

  void validate() {
    final missing = <String>[
      if (storeDomain.trim().isEmpty) 'SHOPIFY_STORE_DOMAIN',
      if (clientId.trim().isEmpty) 'SHOPIFY_CUSTOMER_ACCOUNT_CLIENT_ID',
      if (redirectUri == null) 'SHOPIFY_CUSTOMER_ACCOUNT_REDIRECT_URI',
    ];
    if (missing.isNotEmpty) {
      throw CustomerAuthException(
        'Missing customer account configuration: ${missing.join(', ')}.',
      );
    }

    final uri = redirectUri!;
    if (!uri.scheme.startsWith('shop.') || uri.host.isEmpty) {
      throw const CustomerAuthException(
        'The customer account callback must be the exact mobile callback URI '
        'registered in Shopify.',
      );
    }
    if (!scopes.contains('openid') ||
        !scopes.contains('email') ||
        !scopes.contains('customer-account-api:full')) {
      throw const CustomerAuthException(
        'Customer Account scopes must include openid, email, and '
        'customer-account-api:full.',
      );
    }
  }
}

class CustomerAuthException implements Exception {
  const CustomerAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CustomerAuthCanceledException extends CustomerAuthException {
  const CustomerAuthCanceledException() : super('Sign in was canceled.');
}
