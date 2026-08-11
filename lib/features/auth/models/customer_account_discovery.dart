class CustomerAccountDiscovery {
  const CustomerAccountDiscovery({
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.logoutEndpoint,
    required this.graphqlEndpoint,
  });

  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri logoutEndpoint;
  final Uri graphqlEndpoint;
}
