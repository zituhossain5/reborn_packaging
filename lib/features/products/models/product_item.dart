class ProductItem {
  const ProductItem({
    required this.id,
    required this.handle,
    required this.title,
    required this.quantity,
    required this.price,
    required this.unitPrice,
    required this.imageAsset,
  });

  final String id;
  final String handle;
  final String title;
  final int quantity;
  final double price;
  final double unitPrice;
  final String imageAsset;
}
