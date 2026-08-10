import '../../../core/config/pricing_config.dart';
import '../models/product_details.dart';
import '../models/product_variant_resolver.dart';

class ProductSelectionController {
  ProductSelectionController(this.product)
    : _selectedVariant = product.selectedVariant,
      _includeVat = false,
      _quantity = product.selectedVariant.quantityRule.minimum;

  final ProductDetails product;

  ProductVariant _selectedVariant;
  bool _includeVat;
  int _quantity;

  ProductVariant get selectedVariant => _selectedVariant;
  bool get includeVat => _includeVat;
  int get quantity => _quantity;
  double? get unitPrice => _selectedVariant.unitPrice;
  double get displayedVariantPrice {
    return PricingConfig.priceForVatState(
      exVatPrice: _selectedVariant.priceExVat,
      includeVat: _includeVat,
    );
  }

  double? get displayedUnitPrice {
    final piecesPerPack = _selectedVariant.piecesPerPack;
    return piecesPerPack == null ? null : displayedVariantPrice / piecesPerPack;
  }

  double get totalPrice => displayedVariantPrice * _quantity;
  int? get totalUnits {
    final piecesPerPack = _selectedVariant.piecesPerPack;
    return piecesPerPack == null ? null : piecesPerPack * _quantity;
  }

  bool get canDecrease => _quantity > _selectedVariant.quantityRule.minimum;
  bool get canIncrease => _selectedVariant.quantityRule.canIncrease(_quantity);

  List<String> get galleryImages {
    final variantImage = _selectedVariant.imageSource;
    if (variantImage.isEmpty) {
      return product.images;
    }
    return [
      variantImage,
      ...product.images.where((image) => image != variantImage),
    ];
  }

  String? selectedValue(String optionName) {
    return _selectedVariant.optionValue(optionName);
  }

  bool isOptionValueAvailable(String optionName, String value) {
    final optionIndex = product.options.indexWhere(
      (option) => option.name == optionName,
    );
    if (optionIndex < 0) return false;

    final requiredOptions = <String, String>{};
    for (var index = 0; index <= optionIndex; index++) {
      final option = product.options[index];
      final selectedValue = option.name == optionName
          ? value
          : _selectedVariant.optionValue(option.name);
      if (selectedValue != null) requiredOptions[option.name] = selectedValue;
    }
    return resolveVariantForOptions(
          product: product,
          selectedOptions: requiredOptions,
        ) !=
        null;
  }

  void selectOption(String optionName, String value) {
    if (!isOptionValueAvailable(optionName, value)) return;

    final selectedOptions = {
      for (final option in product.options)
        if (_selectedVariant.optionValue(option.name) != null)
          option.name: _selectedVariant.optionValue(option.name)!,
      optionName: value,
    };
    final exactVariant = resolveVariantForOptions(
      product: product,
      selectedOptions: selectedOptions,
    );
    if (exactVariant != null) {
      _selectVariant(exactVariant);
      return;
    }

    final optionIndex = product.options.indexWhere(
      (option) => option.name == optionName,
    );
    final requiredOptions = <String, String>{};
    for (var index = 0; index <= optionIndex; index++) {
      final option = product.options[index];
      final optionValue = option.name == optionName
          ? value
          : selectedOptions[option.name];
      if (optionValue != null) requiredOptions[option.name] = optionValue;
    }
    final fallback = resolveVariantForOptions(
      product: product,
      selectedOptions: requiredOptions,
    );
    if (fallback != null) _selectVariant(fallback);
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

    final variant =
        resolveProductVariant(
          product: product,
          size: size,
          lid: _selectedVariant.lid,
        ) ??
        firstAvailableVariantForSize(product: product, size: size)!;
    _selectVariant(variant);
  }

  void selectLid(String lid) {
    final variant = resolveProductVariant(
      product: product,
      size: _selectedVariant.size,
      lid: lid,
    );
    if (variant != null) {
      _selectVariant(variant);
    }
  }

  void toggleIncludeVat() {
    _includeVat = !_includeVat;
  }

  void increaseQuantity() {
    _quantity = _selectedVariant.quantityRule.increase(_quantity);
  }

  void decreaseQuantity() {
    _quantity = _selectedVariant.quantityRule.decrease(_quantity);
  }

  void _selectVariant(ProductVariant variant) {
    if (_selectedVariant.id == variant.id) return;
    _selectedVariant = variant;
    _quantity = variant.quantityRule.minimum;
  }
}
