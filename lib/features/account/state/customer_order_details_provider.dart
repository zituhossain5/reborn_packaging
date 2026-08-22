import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/customer_auth_controller.dart';
import '../data/customer_order_repository.dart';
import '../models/customer_order_details.dart';

final customerOrderRepositoryProvider = Provider<CustomerOrderRepository>(
  (ref) => ShopifyCustomerOrderRepository(
    config: ref.watch(customerAccountConfigProvider),
  ),
);

final isCustomerAccountAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(customerAuthControllerProvider).value != null,
);

final customerOrderDetailsProvider = FutureProvider.autoDispose
    .family<CustomerOrderDetails, String>((ref, orderId) async {
      final session = await ref.watch(customerAuthControllerProvider.future);
      if (session == null) {
        throw const CustomerOrderFailure(
          'Sign in to view your Shopify order details.',
        );
      }
      return ref
          .watch(customerOrderRepositoryProvider)
          .fetchOrder(orderId: orderId, accessToken: session.accessToken);
    });
