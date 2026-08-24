import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/account/models/shopify_customer.dart';

void main() {
  test('maps real Shopify customer identity for the Account UI', () {
    final customer = ShopifyCustomer.fromShopifyJson({
      'id': 'gid://shopify/Customer/1',
      'displayName': 'Zitu Hossain',
      'firstName': 'Zitu',
      'lastName': 'Hossain',
      'emailAddress': {'emailAddress': 'zitu@example.com'},
    });

    final accountUser = customer.toAccountUser();
    expect(accountUser.name, 'Zitu Hossain');
    expect(accountUser.email, 'zitu@example.com');
    expect(accountUser.initials, 'ZH');
  });

  test('falls back to the email name when Shopify has no customer name', () {
    final customer = ShopifyCustomer.fromShopifyJson({
      'id': 'gid://shopify/Customer/2',
      'emailAddress': {'emailAddress': 'hello.customer@example.com'},
    });

    expect(customer.resolvedName, 'hello.customer');
    expect(customer.initials, 'HC');
  });
}
