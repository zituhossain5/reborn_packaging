import '../../../core/config/pricing_config.dart';
import '../models/product_details.dart';
import '../models/product_variant_resolver.dart';

class ProductSelectionController {
  ProductSelectionController(this.product)
    : _selectedVariant = product.selectedVariant,
      _includeVat = false,
      _quantity = product.quantityRule.minimum;

  final ProductDetails product;

  ProductVariant _selectedVariant;
  bool _includeVat;
  int _quantity;

  ProductVariant get selectedVariant => _selectedVariant;
  bool get includeVat => _includeVat;
  int get quantity => _quantity;
  double get unitPrice => _selectedVariant.unitPrice;
  double get displayedVariantPrice {
    return PricingConfig.priceForVatState(
      exVatPrice: _selectedVariant.priceExVat,
      includeVat: _includeVat,
    );
  }

  double get displayedUnitPrice {
    return displayedVariantPrice / _selectedVariant.piecesPerPack;
  }

  double get totalPrice => displayedVariantPrice * _quantity;
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

  void toggleIncludeVat() {
    _includeVat = !_includeVat;
  }

  void increaseQuantity() {
    _quantity = product.quantityRule.increase(_quantity);
  }

  void decreaseQuantity() {
    _quantity = product.quantityRule.decrease(_quantity);
  }
}
