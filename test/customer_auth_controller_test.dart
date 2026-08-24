import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/auth/data/customer_auth_repository.dart';
import 'package:reborn_packaging/features/auth/models/customer_auth_session.dart';
import 'package:reborn_packaging/features/auth/state/customer_auth_controller.dart';

void main() {
  test('customer auth restores, signs in, and signs out centrally', () async {
    final repository = _FakeCustomerAuthRepository();
    final container = ProviderContainer(
      overrides: [customerAuthRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(await container.read(customerAuthControllerProvider.future), isNull);

    final signedIn = await container
        .read(customerAuthControllerProvider.notifier)
        .signIn(loginHint: 'michelle03@gmail.com');
    expect(signedIn, isTrue);
    expect(container.read(customerAuthControllerProvider).value, isNotNull);

    await container.read(customerAuthControllerProvider.notifier).signOut();
    expect(container.read(customerAuthControllerProvider).value, isNull);
    expect(repository.signOutCalled, isTrue);
  });
}

class _FakeCustomerAuthRepository implements CustomerAuthRepository {
  bool signOutCalled = false;

  @override
  Future<CustomerAuthSession?> restoreSession() async => null;

  @override
  Future<CustomerAuthSession> signIn({String? loginHint}) async {
    return CustomerAuthSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      idToken: 'id-token',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> signOut(CustomerAuthSession? session) async {
    signOutCalled = true;
  }
}
