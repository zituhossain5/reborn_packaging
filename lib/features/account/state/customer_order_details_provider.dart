import 'package:flutter/foundation.dart';
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

final customerOrderLookupRetryDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 1),
);

final customerOrderDetailsProvider =
    FutureProvider.family<CustomerOrderDetails, String>((ref, orderId) async {
      final repository = ref.read(customerOrderRepositoryProvider);
      final retryDelay = ref.read(customerOrderLookupRetryDelayProvider);
      final session = await ref.read(customerAuthControllerProvider.future);
      if (session == null) {
        throw const CustomerOrderFailure(
          'Sign in to view your Shopify order details.',
        );
      }
      final identifier = ShopifyCheckoutOrderIdentifier.parse(orderId);
      const maximumAttempts = 8;
      for (var attempt = 1; attempt <= maximumAttempts; attempt++) {
        if (kDebugMode) {
          debugPrint(
            'Customer order lookup attempt: $attempt/$maximumAttempts',
          );
        }
        if (identifier.supportsDirectLookup) {
          try {
            final order = await repository.fetchOrder(
              orderId: identifier.source,
              accessToken: session.accessToken,
            );
            if (kDebugMode) debugPrint('Customer order match found: true');
            return order;
          } on CustomerOrderNotFoundFailure {
            // Newly completed orders can take a moment to propagate.
          }
        }
        final recentOrder = await repository.findRecentOrder(
          orderId: identifier.source,
          accessToken: session.accessToken,
        );
        if (recentOrder != null) {
          if (kDebugMode) debugPrint('Customer order match found: true');
          return recentOrder;
        }
        if (attempt < maximumAttempts) await Future<void>.delayed(retryDelay);
      }
      if (kDebugMode) debugPrint('Customer order match found: false');
      throw const CustomerOrderNotFoundFailure();
    });
