import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/customer_auth_session.dart';
import '../../auth/state/customer_auth_controller.dart';
import '../data/customer_profile_repository.dart';
import '../models/account_models.dart';
import '../models/shopify_customer.dart';

final customerProfileRepositoryProvider = Provider<CustomerProfileRepository>(
  (ref) => ShopifyCustomerProfileRepository(
    config: ref.watch(customerAccountConfigProvider),
  ),
);

final customerProfileProvider =
    AsyncNotifierProvider<CustomerProfileController, ShopifyCustomer>(
      CustomerProfileController.new,
    );

class CustomerProfileController extends AsyncNotifier<ShopifyCustomer> {
  bool _mutationPending = false;

  @override
  Future<ShopifyCustomer> build() async {
    final session = await ref.watch(customerAuthControllerProvider.future);
    if (session == null) {
      throw const CustomerProfileFailure('Sign in to load your account.');
    }
    return ref
        .watch(customerProfileRepositoryProvider)
        .fetchCustomer(accessToken: session.accessToken);
  }

  Future<void> refresh() async {
    final session = await _session();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(customerProfileRepositoryProvider)
          .fetchCustomer(accessToken: session.accessToken),
    );
  }

  Future<void> createAddress(CustomerAddressInput address) {
    return _mutate(
      (repository, session) => repository.createAddress(
        accessToken: session.accessToken,
        address: address,
      ),
    );
  }

  Future<void> updateAddress(
    String addressId,
    CustomerAddressInput address, {
    bool? defaultAddress,
  }) {
    return _mutate(
      (repository, session) => repository.updateAddress(
        accessToken: session.accessToken,
        addressId: addressId,
        address: address,
        defaultAddress: defaultAddress,
      ),
    );
  }

  Future<void> deleteAddress(String addressId) {
    return _mutate(
      (repository, session) => repository.deleteAddress(
        accessToken: session.accessToken,
        addressId: addressId,
      ),
    );
  }

  Future<void> setEmailMarketingSubscribed(bool subscribed) {
    return _mutate(
      (repository, session) => repository.setEmailMarketingSubscribed(
        accessToken: session.accessToken,
        subscribed: subscribed,
      ),
    );
  }

  Future<void> _mutate(
    Future<ShopifyCustomer> Function(
      CustomerProfileRepository repository,
      CustomerAuthSession session,
    )
    mutation,
  ) async {
    if (_mutationPending) {
      throw const CustomerProfileFailure(
        'Another profile update is already in progress.',
      );
    }
    _mutationPending = true;
    try {
      final session = await _session();
      final customer = await mutation(
        ref.read(customerProfileRepositoryProvider),
        session,
      );
      state = AsyncData(customer);
    } finally {
      _mutationPending = false;
    }
  }

  Future<CustomerAuthSession> _session() async {
    final session = await ref.read(customerAuthControllerProvider.future);
    if (session == null) {
      throw const CustomerProfileFailure('Sign in to update your account.');
    }
    return session;
  }
}
