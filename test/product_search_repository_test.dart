import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/search/data/product_search_repository.dart';

void main() {
  test(
    'Shopify search query requests Product search with relevance ordering',
    () {
      expect(
        ShopifyProductSearchRepository.productSearchQuery,
        contains('search('),
      );
      expect(
        ShopifyProductSearchRepository.productSearchQuery,
        contains('types: [PRODUCT]'),
      );
      expect(
        ShopifyProductSearchRepository.productSearchQuery,
        contains('sortKey: RELEVANCE'),
      );
      expect(
        ShopifyProductSearchRepository.productSearchQuery,
        contains('pageInfo'),
      );
    },
  );
}
