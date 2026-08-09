class CartItem {
  const CartItem({
    required this.productId,
    required this.productHandle,
    required this.productTitle,
    required this.variantId,
    required this.size,
    required this.lid,
    required this.imageAsset,
    required this.piecesPerPack,
    required this.priceExVat,
    required this.quantity,
  });

  final String productId;
  final String productHandle;
  final String productTitle;
  final String variantId;
  final String size;
  final String lid;
  final String imageAsset;
  final int piecesPerPack;
  final double priceExVat;
  final int quantity;

  double get linePrice => priceExVat * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      productHandle: productHandle,
      productTitle: productTitle,
      variantId: variantId,
      size: size,
      lid: lid,
      imageAsset: imageAsset,
      piecesPerPack: piecesPerPack,
      priceExVat: priceExVat,
      quantity: quantity ?? this.quantity,
    );
  }
}
