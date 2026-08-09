import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product_item.dart';
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
  });

  final String query;
  final List<ProductItem> results;
  final bool isDebouncing;

  bool get hasQuery => query.trim().isNotEmpty;
}

class SearchController extends Notifier<SearchState> {
  static const debounceDuration = Duration(milliseconds: 300);

  Timer? _debounce;

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
      final results = ref.read(productSearchRepositoryProvider).search(query);
      state = SearchState(query: query, results: results);
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}
