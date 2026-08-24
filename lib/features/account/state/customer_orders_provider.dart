import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/customer_auth_controller.dart';
import '../data/customer_orders_repository.dart';
import '../models/customer_order_summary.dart';

final customerOrdersRepositoryProvider = Provider<CustomerOrdersRepository>(
  (ref) => ShopifyCustomerOrdersRepository(
    config: ref.watch(customerAccountConfigProvider),
  ),
);

final customerOrdersProvider =
    AsyncNotifierProvider<CustomerOrdersController, CustomerOrdersState>(
      CustomerOrdersController.new,
    );

class CustomerOrdersState {
  const CustomerOrdersState({
    required this.orders,
    required this.hasNextPage,
    required this.endCursor,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<CustomerOrderSummary> orders;
  final bool hasNextPage;
  final String? endCursor;
  final bool isLoadingMore;
  final String? loadMoreError;

  CustomerOrdersState copyWith({
    List<CustomerOrderSummary>? orders,
    bool? hasNextPage,
    String? endCursor,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return CustomerOrdersState(
      orders: orders ?? this.orders,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: endCursor ?? this.endCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
    );
  }
}

class CustomerOrdersController extends AsyncNotifier<CustomerOrdersState> {
  @override
  Future<CustomerOrdersState> build() async {
    final session = await ref.watch(customerAuthControllerProvider.future);
    if (session == null) {
      throw const CustomerOrdersFailure('Sign in to load your orders.');
    }
    final page = await ref
        .watch(customerOrdersRepositoryProvider)
        .fetchOrders(accessToken: session.accessToken);
    return CustomerOrdersState(
      orders: page.orders,
      hasNextPage: page.hasNextPage,
      endCursor: page.endCursor,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasNextPage ||
        current.isLoadingMore ||
        current.endCursor == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );
    try {
      final session = await ref.read(customerAuthControllerProvider.future);
      if (session == null) {
        throw const CustomerOrdersFailure('Sign in to load your orders.');
      }
      final page = await ref
          .read(customerOrdersRepositoryProvider)
          .fetchOrders(
            accessToken: session.accessToken,
            after: current.endCursor,
          );
      state = AsyncData(
        CustomerOrdersState(
          orders: [...current.orders, ...page.orders],
          hasNextPage: page.hasNextPage,
          endCursor: page.endCursor,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error.toString()),
      );
    }
  }
}
