import '../models/product_item.dart';

const mockProductCatalog = <ProductItem>[
  ProductItem(
    id: 'kraft-round-bowl-500ml',
    handle: 'kraft-round-bowls',
    collectionHandle: 'kraft-round-bowls',
    collectionTitle: 'KRAFT ROUND BOWLS',
    title: '500ml Kraft Round Bowls',
    quantity: 600,
    price: 41.95,
    unitPrice: 0.099,
    imageAsset: 'assets/images/products/kraft_round_bowl_500ml.png',
    variantSizes: ['500ml', '650ml', '750ml', '1000ml'],
    searchKeywords: ['round', 'bowl', 'food container', 'kraft', 'paper'],
  ),
  ProductItem(
    id: 'kraft-rectangular-bowl-500ml',
    handle: 'kraft-rectangular-bowls',
    collectionHandle: 'kraft-rectangular-bowls',
    collectionTitle: 'KRAFT RECTANGULAR BOWLS',
    title: '500ml Kraft Rectangular Bowls',
    quantity: 300,
    price: 38.95,
    unitPrice: 0.1298,
    imageAsset: 'assets/images/collections/kraft_rectangular_bowls.png',
    variantSizes: ['500ml', '650ml', '750ml', '1000ml'],
    searchKeywords: [
      'rectangular',
      'rectangle',
      'bowl',
      'food container',
      'kraft',
      'paper',
    ],
  ),
  ProductItem(
    id: 'white-paper-napkins-33cm',
    handle: 'napkins',
    collectionHandle: 'napkins',
    collectionTitle: 'NAPKINS',
    title: '2 Ply White Paper Napkins',
    quantity: 2000,
    price: 24.95,
    unitPrice: 0.0125,
    imageAsset: 'assets/images/collections/napkins.png',
    variantSizes: ['33cm'],
    searchKeywords: ['napkin', 'serviette', 'tissue', 'white', '2 ply'],
  ),
  ProductItem(
    id: 'kraft-paper-carrier-bags-medium',
    handle: 'paper-carrier-bags',
    collectionHandle: 'paper-carrier-bags',
    collectionTitle: 'PAPER CARRIER BAGS',
    title: 'Medium Kraft Paper Carrier Bags',
    quantity: 250,
    price: 29.95,
    unitPrice: 0.1198,
    imageAsset: 'assets/images/collections/paper_carrier_bags.png',
    variantSizes: ['Small', 'Medium', 'Large'],
    searchKeywords: ['carrier', 'bag', 'takeaway', 'shopping', 'kraft'],
  ),
  ProductItem(
    id: 'kraft-boat-tray-number-5',
    handle: 'kraft-boat-trays',
    collectionHandle: 'kraft-boat-trays',
    collectionTitle: 'KRAFT BOAT TRAYS',
    title: 'No. 5 Kraft Boat Trays',
    quantity: 500,
    price: 25.99,
    unitPrice: 0.052,
    imageAsset: 'assets/images/collections/kraft_boat_trays.png',
    variantSizes: ['No. 5', 'Large'],
    searchKeywords: ['boat', 'tray', 'food tray', 'kraft', 'paper'],
  ),
  ProductItem(
    id: 'kraft-paper-coffee-cups-8oz',
    handle: 'paper-coffee-cups',
    collectionHandle: 'paper-coffee-cups',
    collectionTitle: 'PAPER COFFEE CUPS',
    title: '8oz Kraft Paper Coffee Cups',
    quantity: 500,
    price: 32.95,
    unitPrice: 0.0659,
    imageAsset: 'assets/images/collections/paper_coffee_cups.png',
    variantSizes: ['8oz', '12oz', '16oz'],
    searchKeywords: ['coffee', 'cup', 'hot drink', 'takeaway', 'kraft'],
  ),
  ProductItem(
    id: 'kraft-soup-container-16oz',
    handle: 'kraft-soup-containers',
    collectionHandle: 'soup-containers',
    collectionTitle: 'SOUP CONTAINERS',
    title: '16oz Kraft Soup Containers',
    quantity: 500,
    price: 39.95,
    unitPrice: 0.0799,
    imageAsset: 'assets/images/products/kraft_round_bowl_500ml.png',
    variantSizes: ['12oz', '16oz', '26oz'],
    searchKeywords: [
      'soup',
      'pot',
      'container',
      'hot food',
      'takeaway',
      'kraft',
      'paper',
    ],
  ),
];

List<ProductItem> mockProductsForCollection(String collectionHandle) {
  final products = [
    for (final product in mockProductCatalog)
      if (product.collectionHandle == collectionHandle) product,
  ];

  if (products.isEmpty) {
    return const [];
  }

  const minimumMockGridItems = 4;
  return List.generate(
    minimumMockGridItems,
    (index) => products[index % products.length],
  );
}
