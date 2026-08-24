import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/account/data/customer_profile_repository.dart';
import 'package:reborn_packaging/features/account/models/account_models.dart';
import 'package:reborn_packaging/features/account/models/shopify_customer.dart';
import 'package:reborn_packaging/features/account/state/customer_profile_provider.dart';
import 'package:reborn_packaging/features/auth/data/customer_auth_repository.dart';
import 'package:reborn_packaging/features/auth/models/customer_auth_session.dart';
import 'package:reborn_packaging/features/auth/state/customer_auth_controller.dart';

void main() {
  test('Shopify customer parses addresses, default and marketing state', () {
    final customer = ShopifyCustomer.fromShopifyJson({
      'id': 'gid://shopify/Customer/1',
      'displayName': 'Real Customer',
      'firstName': 'Real',
      'lastName': 'Customer',
      'emailAddress': {
        'emailAddress': 'real@example.com',
        'marketingState': 'SUBSCRIBED',
      },
      'defaultAddress': {'id': 'gid://shopify/CustomerAddress/2'},
      'addresses': {
        'nodes': [
          _addressJson('gid://shopify/CustomerAddress/1', 'London'),
          _addressJson('gid://shopify/CustomerAddress/2', 'Luton'),
        ],
      },
    });

    expect(customer.email, 'real@example.com');
    expect(customer.marketingEmailsEnabled, isTrue);
    expect(customer.addresses, hasLength(2));
    expect(customer.addresses.first.isDefault, isFalse);
    expect(customer.addresses.last.isDefault, isTrue);
    expect(customer.addresses.last.territoryCode, 'GB');
  });

  test('profile mutations refresh authoritative Shopify customer', () async {
    final repository = _FakeCustomerProfileRepository();
    final container = ProviderContainer(
      overrides: [
        customerAuthRepositoryProvider.overrideWithValue(
          const _SignedInCustomerAuthRepository(),
        ),
        customerProfileRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(customerProfileProvider.future);
    const input = CustomerAddressInput(
      firstName: 'Real',
      lastName: 'Customer',
      address1: '1 High Street',
      address2: '',
      city: 'London',
      postcode: 'SW1A 1AA',
      territoryCode: 'GB',
    );
    await container.read(customerProfileProvider.notifier).createAddress(input);
    await container
        .read(customerProfileProvider.notifier)
        .setEmailMarketingSubscribed(true);

    expect(repository.createdAddress, input);
    expect(repository.marketingSubscribed, isTrue);
    expect(
      container.read(customerProfileProvider).requireValue.addresses,
      hasLength(1),
    );
    expect(
      container
          .read(customerProfileProvider)
          .requireValue
          .marketingEmailsEnabled,
      isTrue,
    );
  });
}

Map<String, Object?> _addressJson(String id, String city) => {
  'id': id,
  'firstName': 'Real',
  'lastName': 'Customer',
  'address1': '1 High Street',
  'address2': '',
  'city': city,
  'province': 'England',
  'zoneCode': '',
  'zip': 'SW1A 1AA',
  'country': 'United Kingdom',
  'territoryCode': 'GB',
  'phoneNumber': '',
  'formatted': ['1 High Street', '$city SW1A 1AA', 'United Kingdom'],
};

class _SignedInCustomerAuthRepository implements CustomerAuthRepository {
  const _SignedInCustomerAuthRepository();

  @override
  Future<CustomerAuthSession?> restoreSession() async => CustomerAuthSession(
    accessToken: 'customer-account-token',
    refreshToken: 'refresh-token',
    idToken: 'id-token',
    expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
  );

  @override
  Future<CustomerAuthSession> signIn({String? loginHint}) async {
    return (await restoreSession())!;
  }

  @override
  Future<void> signOut(CustomerAuthSession? session) async {}
}

class _FakeCustomerProfileRepository implements CustomerProfileRepository {
  ShopifyCustomer customer = _customer();
  CustomerAddressInput? createdAddress;
  bool? marketingSubscribed;

  @override
  Future<ShopifyCustomer> fetchCustomer({required String accessToken}) async {
    return customer;
  }

  @override
  Future<ShopifyCustomer> createAddress({
    required String accessToken,
    required CustomerAddressInput address,
    bool defaultAddress = false,
  }) async {
    createdAddress = address;
    customer = _customer(
      addresses: [
        CustomerAddress(
          id: 'gid://shopify/CustomerAddress/1',
          firstName: address.firstName,
          lastName: address.lastName,
          address1: address.address1,
          address2: address.address2,
          city: address.city,
          postcode: address.postcode,
          country: 'United Kingdom',
          territoryCode: address.territoryCode,
          formatted: const ['1 High Street', 'London SW1A 1AA'],
          isDefault: true,
        ),
      ],
    );
    return customer;
  }

  @override
  Future<ShopifyCustomer> updateAddress({
    required String accessToken,
    required String addressId,
    required CustomerAddressInput address,
    bool? defaultAddress,
  }) async => customer;

  @override
  Future<ShopifyCustomer> deleteAddress({
    required String accessToken,
    required String addressId,
  }) async => customer;

  @override
  Future<ShopifyCustomer> setEmailMarketingSubscribed({
    required String accessToken,
    required bool subscribed,
  }) async {
    marketingSubscribed = subscribed;
    customer = _customer(
      addresses: customer.addresses,
      marketingState: subscribed ? 'SUBSCRIBED' : 'UNSUBSCRIBED',
    );
    return customer;
  }
}

ShopifyCustomer _customer({
  List<CustomerAddress> addresses = const [],
  String marketingState = 'NOT_SUBSCRIBED',
}) {
  return ShopifyCustomer(
    id: 'gid://shopify/Customer/1',
    displayName: 'Real Customer',
    firstName: 'Real',
    lastName: 'Customer',
    email: 'real@example.com',
    emailMarketingState: marketingState,
    addresses: addresses,
  );
}
