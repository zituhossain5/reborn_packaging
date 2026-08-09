import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockAuthControllerProvider = NotifierProvider<MockAuthController, bool>(
  MockAuthController.new,
);

/// Development-only in-memory authentication state.
///
/// This deliberately does not store credentials or tokens and must be replaced
/// when the Shopify customer account flow is integrated.
class MockAuthController extends Notifier<bool> {
  @override
  bool build() => false;

  void signIn() => state = true;

  void signOut() => state = false;
}
