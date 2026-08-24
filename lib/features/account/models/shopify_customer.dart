import 'account_models.dart';

class ShopifyCustomer {
  const ShopifyCustomer({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory ShopifyCustomer.fromShopifyJson(Map<String, dynamic> json) {
    final emailAddress = json['emailAddress'];
    return ShopifyCustomer(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: emailAddress is Map<String, dynamic>
          ? emailAddress['emailAddress'] as String? ?? ''
          : '',
    );
  }

  final String id;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String email;

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
