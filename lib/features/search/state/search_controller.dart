import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/shopify_failure.dart';
import '../../products/models/product_item.dart';
import '../../products/models/product_page.dart';
import '../data/product_search_repository.dart';

final searchControllerProvider =
    NotifierProvider.autoDispose<SearchController, SearchState>(
      SearchController.new,
    );

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isDebouncing = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.pageInfo = const ProductPageInfo(hasNextPage: false, endCursor: null),
  });

  final String query;
  final List<ProductItem> results;
  final bool isDebouncing;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final ProductPageInfo pageInfo;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get canLoadMore =>
      hasQuery &&
      !hasError &&
      !isLoading &&
      !isLoadingMore &&
      pageInfo.hasNextPage;
}

class SearchController extends Notifier<SearchState> {
  static const debounceDuration = Duration(milliseconds: 300);
  static const pageSize = 20;

  Timer? _debounce;
  var _requestSerial = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void setQuery(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = SearchState(query: query, isDebouncing: true);
    _debounce = Timer(debounceDuration, () {
      unawaited(_search(query));
    });
  }

  void clear() {
    _debounce?.cancel();
    _requestSerial++;
    state = const SearchState();
  }

  Future<void> retry() async {
    final query = state.query;
    if (query.trim().isEmpty) return;
    _debounce?.cancel();
    await _search(query);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    final requestId = ++_requestSerial;
    final query = state.query;
    final previousResults = state.results;
    state = SearchState(
      query: query,
      results: previousResults,
      isLoadingMore: true,
      pageInfo: state.pageInfo,
    );

    try {
      final page = await ref
          .read(productSearchRepositoryProvider)
          .searchPage(
            query: query,
            first: pageSize,
            after: state.pageInfo.endCursor,
          );
      if (requestId != _requestSerial) return;

      state = SearchState(
        query: query,
        results: [...previousResults, ...page.items],
        pageInfo: page.pageInfo,
      );
    } on ShopifyFailure catch (failure) {
      if (requestId != _requestSerial) return;
      state = SearchState(
        query: query,
        results: previousResults,
        errorMessage: failure.message,
        pageInfo: state.pageInfo,
      );
    }
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestSerial;
    state = SearchState(query: query, isLoading: true);

    try {
      final page = await ref
          .read(productSearchRepositoryProvider)
          .searchPage(query: query, first: pageSize);
      if (requestId != _requestSerial) return;

      state = SearchState(
        query: query,
        results: page.items,
        pageInfo: page.pageInfo,
      );
    } on ShopifyFailure catch (failure) {
      if (requestId != _requestSerial) return;
      state = SearchState(query: query, errorMessage: failure.message);
    }
  }
}
