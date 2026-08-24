import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/customer_auth_controller.dart';
import '../data/customer_profile_repository.dart';
import '../models/shopify_customer.dart';

final customerProfileRepositoryProvider = Provider<CustomerProfileRepository>(
  (ref) => ShopifyCustomerProfileRepository(
    config: ref.watch(customerAccountConfigProvider),
  ),
);

final customerProfileProvider = FutureProvider<ShopifyCustomer>((ref) async {
  final session = await ref.watch(customerAuthControllerProvider.future);
  if (session == null) {
    throw const CustomerProfileFailure('Sign in to load your account.');
  }
  return ref
      .watch(customerProfileRepositoryProvider)
      .fetchCustomer(accessToken: session.accessToken);
});
