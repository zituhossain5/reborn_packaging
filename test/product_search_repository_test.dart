import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/home/data/mock_collections.dart';
import 'package:reborn_packaging/features/products/data/mock_product_details.dart';
import 'package:reborn_packaging/features/products/data/mock_products.dart';
import 'package:reborn_packaging/features/search/data/product_search_repository.dart';

void main() {
  const repository = LocalProductSearchRepository();

  test('local search is partial and case-insensitive', () {
    expect(repository.search('round'), hasLength(1));
    expect(repository.search('napkins').single.handle, 'napkins');
    expect(repository.search('carrier').single.handle, 'paper-carrier-bags');
    expect(repository.search('coffee').single.handle, 'paper-coffee-cups');
    expect(repository.search('soup').single.handle, 'kraft-soup-containers');
  });

  test('local search includes collection and variant size metadata', () {
    expect(repository.search('kraft round bowls'), hasLength(1));
    expect(repository.search('bowls'), hasLength(2));
    expect(repository.search('500ml'), hasLength(2));
    expect(repository.search('not-a-product'), isEmpty);
  });

  test('paper search is mixed-case safe and spans matching collections', () {
    final lowerHandles = repository
        .search('paper')
        .map((product) => product.handle)
        .toSet();
    final upperHandles = repository
        .search('PAPER')
        .map((product) => product.handle)
        .toSet();

    expect(lowerHandles, contains('paper-carrier-bags'));
    expect(lowerHandles, contains('paper-coffee-cups'));
    expect(upperHandles, lowerHandles);
  });

  test('every Home collection has searchable products and product details', () {
    for (final collection in mockCollections) {
      final products = mockProductsForCollection(collection.handle);
      expect(products, isNotEmpty, reason: collection.handle);
      for (final product in products) {
        expect(mockProductDetailsForHandle(product.handle), isNotNull);
      }
    }
  });

  test(
    'global catalog includes searchable products outside Home collections',
    () {
      final homeHandles = mockCollections
          .map((collection) => collection.handle)
          .toSet();
      final soupProduct = repository.search('soup containers').single;

      expect(homeHandles, isNot(contains(soupProduct.collectionHandle)));
      expect(mockProductCatalog, contains(soupProduct));
      expect(mockProductDetailsForHandle(soupProduct.handle), isNotNull);
    },
  );
}
