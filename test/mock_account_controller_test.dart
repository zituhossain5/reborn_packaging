import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/account/models/account_models.dart';
import 'package:reborn_packaging/features/account/state/mock_account_state.dart';

void main() {
  test('email update changes centralized mock account user', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(mockAccountStateProvider.notifier)
        .updateEmail('updated@example.com');

    expect(
      container.read(mockAccountStateProvider).user.email,
      'updated@example.com',
    );
  });

  test('addresses append and update independently by id', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(mockAccountStateProvider.notifier);
    const secondAddress = CustomerAddress(
      id: 'mock-address-2',
      firstName: 'Michelle',
      lastName: 'Wilson',
      address1: '10 Market Street',
      address2: '',
      city: 'London',
      postcode: 'SW1A 1AA',
      country: 'United Kingdom',
    );

    controller.addAddress(secondAddress);
    expect(container.read(mockAccountStateProvider).addresses, hasLength(2));

    controller.updateAddress(
      const CustomerAddress(
        id: 'mock-address-2',
        firstName: 'Michelle',
        lastName: 'Wilson',
        address1: '12 Market Street',
        address2: 'Flat 3',
        city: 'London',
        postcode: 'SW1A 1AA',
        country: 'United Kingdom',
      ),
    );

    final addresses = container.read(mockAccountStateProvider).addresses;
    expect(addresses.first.id, 'mock-address-1');
    expect(addresses.last.address1, '12 Market Street');
    expect(addresses.last.address2, 'Flat 3');
  });
}
