import 'product_item.dart';

class ProductPageInfo {
  const ProductPageInfo({required this.hasNextPage, required this.endCursor});

  final bool hasNextPage;
  final String? endCursor;
}

class ProductPage {
  const ProductPage({required this.items, required this.pageInfo});

  final List<ProductItem> items;
  final ProductPageInfo pageInfo;
}

class ProductCatalog {
  const ProductCatalog({
    required this.items,
    required this.pageInfo,
    required this.pagesFetched,
  });

  final List<ProductItem> items;
  final ProductPageInfo pageInfo;
  final int pagesFetched;
}
