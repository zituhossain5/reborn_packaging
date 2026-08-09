class ProductItem {
  const ProductItem({
    required this.id,
    required this.handle,
    required this.collectionHandle,
    required this.collectionTitle,
    required this.title,
    required this.quantity,
    required this.price,
    required this.unitPrice,
    required this.imageAsset,
    required this.variantSizes,
    required this.searchKeywords,
  });

  final String id;
  final String handle;
  final String collectionHandle;
  final String collectionTitle;
  final String title;
  final int quantity;
  final double price;
  final double unitPrice;
  final String imageAsset;
  final List<String> variantSizes;
  final List<String> searchKeywords;
}
