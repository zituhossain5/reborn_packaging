import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/auth/state/mock_auth_controller.dart';

void main() {
  test('mock authentication remains in memory for the provider container', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(mockAuthControllerProvider), isFalse);

    container.read(mockAuthControllerProvider.notifier).signIn();

    expect(container.read(mockAuthControllerProvider), isTrue);
  });
}
