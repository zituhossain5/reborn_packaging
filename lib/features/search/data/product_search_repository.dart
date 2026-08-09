import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/data/mock_products.dart';
import '../../products/models/product_item.dart';

final productSearchRepositoryProvider = Provider<ProductSearchRepository>(
  (ref) => const LocalProductSearchRepository(),
);

abstract interface class ProductSearchRepository {
  List<ProductItem> search(String query);
}

class LocalProductSearchRepository implements ProductSearchRepository {
  const LocalProductSearchRepository();

  @override
  List<ProductItem> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    return [
      for (final product in mockProductCatalog)
        if (_matches(product: product, query: normalizedQuery)) product,
    ];
  }

  bool _matches({required ProductItem product, required String query}) {
    final searchableValues = [
      product.title,
      product.collectionTitle,
      product.collectionHandle,
      ...product.variantSizes,
      ...product.searchKeywords,
    ];

    return searchableValues.any((value) => value.toLowerCase().contains(query));
  }
}
