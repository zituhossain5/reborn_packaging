import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_models.dart';

const mockAccountUser = AccountUser(
  initials: 'MW',
  name: 'Michelle Wilson',
  email: 'michelle03@gmail.com',
);

const mockAccountAddress = CustomerAddress(
  id: 'mock-address-1',
  firstName: 'Michelle',
  lastName: 'Wilson',
  address1: 'Airport Way, 34',
  address2: '',
  city: 'Luton',
  postcode: 'LU2 9LY',
  country: 'United Kingdom',
  isDefault: true,
);

const populatedMockAccountState = MockAccountState(
  user: mockAccountUser,
  orders: [],
  addresses: [mockAccountAddress],
  marketingEmailsEnabled: true,
);

const emptyMockAccountState = MockAccountState(
  user: mockAccountUser,
  orders: [],
  addresses: [],
  marketingEmailsEnabled: false,
);

final mockAccountStateProvider =
    NotifierProvider<MockAccountController, MockAccountState>(
      MockAccountController.new,
    );

class MockAccountController extends Notifier<MockAccountState> {
  @override
  MockAccountState build() => populatedMockAccountState;

  void setMarketingEmailsEnabled(bool value) {
    state = MockAccountState(
      user: state.user,
      orders: state.orders,
      addresses: state.addresses,
      marketingEmailsEnabled: value,
    );
  }

  void updateEmail(String email) {
    state = MockAccountState(
      user: AccountUser(
        initials: state.user.initials,
        name: state.user.name,
        email: email,
      ),
      orders: state.orders,
      addresses: state.addresses,
      marketingEmailsEnabled: state.marketingEmailsEnabled,
    );
  }

  void addAddress(CustomerAddress address) {
    state = MockAccountState(
      user: state.user,
      orders: state.orders,
      addresses: [...state.addresses, address],
      marketingEmailsEnabled: state.marketingEmailsEnabled,
    );
  }

  void updateAddress(CustomerAddress address) {
    state = MockAccountState(
      user: state.user,
      orders: state.orders,
      addresses: [
        for (final current in state.addresses)
          if (current.id == address.id) address else current,
      ],
      marketingEmailsEnabled: state.marketingEmailsEnabled,
    );
  }

  void resetSession() => state = populatedMockAccountState;
}
