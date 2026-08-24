import 'account_models.dart';

class ShopifyCustomer {
  const ShopifyCustomer({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailMarketingState,
    required this.addresses,
  });

  factory ShopifyCustomer.fromShopifyJson(Map<String, dynamic> json) {
    final emailAddress = json['emailAddress'];
    final defaultAddress = json['defaultAddress'];
    final defaultAddressId = defaultAddress is Map<String, dynamic>
        ? defaultAddress['id'] as String?
        : null;
    final addressConnection = json['addresses'];
    final addressNodes = addressConnection is Map<String, dynamic>
        ? addressConnection['nodes']
        : null;
    return ShopifyCustomer(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: emailAddress is Map<String, dynamic>
          ? emailAddress['emailAddress'] as String? ?? ''
          : '',
      emailMarketingState: emailAddress is Map<String, dynamic>
          ? emailAddress['marketingState'] as String? ?? 'NOT_SUBSCRIBED'
          : 'NOT_SUBSCRIBED',
      addresses: addressNodes is List
          ? addressNodes
                .whereType<Map<String, dynamic>>()
                .map(
                  (address) => _addressFromShopifyJson(
                    address,
                    isDefault: address['id'] == defaultAddressId,
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final String id;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String email;
  final String emailMarketingState;
  final List<CustomerAddress> addresses;

  bool get marketingEmailsEnabled => emailMarketingState == 'SUBSCRIBED';

  String get resolvedName {
    final displayed = displayName?.trim() ?? '';
    if (displayed.isNotEmpty) return displayed;

    final fullName = [
      firstName?.trim() ?? '',
      lastName?.trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
    if (fullName.isNotEmpty) return fullName;

    final emailName = email.split('@').first.trim();
    return emailName.isEmpty ? 'Shopify customer' : emailName;
  }

  String get initials {
    final parts = resolvedName
        .split(RegExp(r'[\s._-]+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  AccountUser toAccountUser() {
    return AccountUser(initials: initials, name: resolvedName, email: email);
  }
}

CustomerAddress _addressFromShopifyJson(
  Map<String, dynamic> json, {
  required bool isDefault,
}) {
  return CustomerAddress(
    id: json['id'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    address1: json['address1'] as String? ?? '',
    address2: json['address2'] as String? ?? '',
    city: json['city'] as String? ?? '',
    postcode: json['zip'] as String? ?? '',
    country: json['country'] as String? ?? '',
    territoryCode: json['territoryCode'] as String? ?? '',
    province: json['province'] as String? ?? '',
    zoneCode: json['zoneCode'] as String? ?? '',
    phoneNumber: json['phoneNumber'] as String? ?? '',
    formatted: (json['formatted'] as List? ?? const [])
        .whereType<String>()
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false),
    isDefault: isDefault,
  );
}
