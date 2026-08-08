import '../models/product_details.dart';
import '../models/product_variant_resolver.dart';

class ProductSelectionController {
  ProductSelectionController(this.product)
    : _selectedVariant = product.selectedVariant,
      _quantity = product.quantityRule.minimum;

  final ProductDetails product;

  ProductVariant _selectedVariant;
  int _quantity;

  ProductVariant get selectedVariant => _selectedVariant;
  int get quantity => _quantity;
  double get unitPrice => _selectedVariant.unitPrice;
  double get totalPrice => _selectedVariant.price * _quantity;
  int get totalUnits => _selectedVariant.piecesPerPack * _quantity;
  bool get canDecrease => _quantity > product.quantityRule.minimum;

  List<String> get galleryImages {
    final variantImage = _selectedVariant.imageAsset;
    if (variantImage == null) {
      return product.images;
    }
    return [
      variantImage,
      ...product.images.where((image) => image != variantImage),
    ];
  }

  bool isSizeAvailable(String size) {
    return firstAvailableVariantForSize(product: product, size: size) != null;
  }

  bool isLidAvailable(String lid) {
    return resolveProductVariant(
          product: product,
          size: _selectedVariant.size,
          lid: lid,
        ) !=
        null;
  }

  void selectSize(String size) {
    if (!isSizeAvailable(size)) {
      return;
    }

    _selectedVariant =
        resolveProductVariant(
          product: product,
          size: size,
          lid: _selectedVariant.lid,
        ) ??
        firstAvailableVariantForSize(product: product, size: size)!;
  }

  void selectLid(String lid) {
    final variant = resolveProductVariant(
      product: product,
      size: _selectedVariant.size,
      lid: lid,
    );
    if (variant != null) {
      _selectedVariant = variant;
    }
  }

  void increaseQuantity() {
    _quantity = product.quantityRule.increase(_quantity);
  }

  void decreaseQuantity() {
    _quantity = product.quantityRule.decrease(_quantity);
  }
}
