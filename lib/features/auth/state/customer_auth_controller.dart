import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/customer_account_config.dart';
import '../data/customer_auth_repository.dart';
import '../models/customer_auth_session.dart';

final customerAccountConfigProvider = Provider<CustomerAccountConfig>(
  (ref) => CustomerAccountConfig.fromEnvironment(),
);

final customerAuthRepositoryProvider = Provider<CustomerAuthRepository>((ref) {
  return ShopifyCustomerAuthRepository(
    config: ref.watch(customerAccountConfigProvider),
  );
});

final customerAuthControllerProvider =
    AsyncNotifierProvider<CustomerAuthController, CustomerAuthSession?>(
      CustomerAuthController.new,
    );

class CustomerAuthController extends AsyncNotifier<CustomerAuthSession?> {
  @override
  Future<CustomerAuthSession?> build() {
    return ref.read(customerAuthRepositoryProvider).restoreSession();
  }

  Future<bool> signIn({String? loginHint}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          ref.read(customerAuthRepositoryProvider).signIn(loginHint: loginHint),
    );
    return state.hasValue && state.value != null;
  }

  Future<CustomerAuthSession?> refreshSessionForCheckout() async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(customerAuthRepositoryProvider)
          .restoreSession();
      state = AsyncData(session);
      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    final currentSession = state.value;
    state = const AsyncLoading();
    await ref.read(customerAuthRepositoryProvider).signOut(currentSession);
    state = const AsyncData(null);
  }
}
