import '../models/product_item.dart';

const _kraftRoundBowl = ProductItem(
  id: 'kraft-round-bowl-500ml',
  handle: 'kraft-round-bowls',
  title: '500ml Kraft Round Bowls',
  quantity: 600,
  price: 41.95,
  unitPrice: 0.099,
  imageAsset: 'assets/images/products/kraft_round_bowl_500ml.png',
);

const mockProductsByCollection = <String, List<ProductItem>>{
  'kraft-round-bowls': [
    _kraftRoundBowl,
    _kraftRoundBowl,
    _kraftRoundBowl,
    _kraftRoundBowl,
  ],
};

List<ProductItem> mockProductsForCollection(String collectionHandle) {
  return mockProductsByCollection[collectionHandle] ?? const [];
}
