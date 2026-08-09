class AccountUser {
  const AccountUser({
    required this.initials,
    required this.name,
    required this.email,
  });

  final String initials;
  final String name;
  final String email;
}

enum AccountOrderStatus { pending, delivered }

class AccountOrder {
  const AccountOrder({
    required this.number,
    required this.dateLabel,
    required this.itemCount,
    required this.status,
    required this.total,
  });

  final String number;
  final String dateLabel;
  final int itemCount;
  final AccountOrderStatus status;
  final double total;

  String get itemCountLabel =>
      '$itemCount ${itemCount == 1 ? 'item' : 'items'}';

  String get statusLabel => switch (status) {
    AccountOrderStatus.pending => 'Pending',
    AccountOrderStatus.delivered => 'Delivered',
  };
}

class CustomerAddress {
  const CustomerAddress({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.address2,
    required this.city,
    required this.postcode,
    required this.country,
    this.isDefault = false,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String address1;
  final String address2;
  final String city;
  final String postcode;
  final String country;
  final bool isDefault;

  String get recipientName =>
      [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
}

class MockAccountState {
  const MockAccountState({
    required this.user,
    required this.orders,
    required this.addresses,
    required this.marketingEmailsEnabled,
  });

  final AccountUser user;
  final List<AccountOrder> orders;
  final List<CustomerAddress> addresses;
  final bool marketingEmailsEnabled;

  MockAccountState withOrders(List<AccountOrder> value) {
    return MockAccountState(
      user: user,
      orders: value,
      addresses: addresses,
      marketingEmailsEnabled: marketingEmailsEnabled,
    );
  }
}
