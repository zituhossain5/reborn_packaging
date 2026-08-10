class ProductDetails {
  const ProductDetails({
    required this.id,
    required this.handle,
    required this.title,
    required this.images,
    required this.currency,
    required this.selectedVariantId,
    required this.variants,
    required this.sizes,
    required this.lidOptions,
    required this.quantityRule,
    required this.description,
    required this.features,
    required this.specifications,
    this.descriptionText = '',
    this.descriptionHtml = '',
    this.availableForSale = true,
    this.featuredImage,
    this.imageItems = const [],
    this.options = const [],
  });

  final String id;
  final String handle;
  final String title;
  final List<String> images;
  final String currency;
  final String selectedVariantId;
  final List<ProductVariant> variants;
  final List<String> sizes;
  final List<String> lidOptions;
  final ProductQuantityRule quantityRule;
  final List<ProductDescriptionParagraph> description;
  final List<ProductFeature> features;
  final List<ProductSpecification> specifications;
  final String descriptionText;
  final String descriptionHtml;
  final bool availableForSale;
  final ProductImage? featuredImage;
  final List<ProductImage> imageItems;
  final List<ProductOption> options;

  List<ProductOption> get selectableOptions {
    if (variants.length == 1 && options.length == 1) {
      final option = options.single;
      final values = option.values;
      if (option.name.toLowerCase() == 'title' &&
          values.length == 1 &&
          values.single.toLowerCase() == 'default title') {
        return const [];
      }
    }
    return options;
  }

  ProductVariant get selectedVariant {
    return variants.firstWhere((variant) => variant.id == selectedVariantId);
  }

  List<ProductSpecification> specificationsForVariant(ProductVariant variant) {
    final baseSpecifications = specifications
        .where((specification) => !_isSkuSpecification(specification.label))
        .toList(growable: false);
    final sku = variant.sku?.trim();

    if (sku == null || sku.isEmpty) return baseSpecifications;

    return [
      ProductSpecification(label: 'SKU', value: sku),
      ...baseSpecifications,
    ];
  }

  static bool _isSkuSpecification(String label) {
    return label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') == 'sku';
  }
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.size,
    required this.lid,
    required this.price,
    required this.availableForSale,
    this.piecesPerPack,
    this.quantityAvailable,
    this.imageAsset,
    this.title = '',
    this.sku,
    this.selectedOptions = const [],
    this.compareAtPrice,
    this.image,
    this.shopifyUnitPrice,
    this.unitPriceMeasurement,
    this.quantityRule = const ProductQuantityRule(minimum: 1, increment: 1),
    this.currencyCode = 'GBP',
  });

  final String id;
  final String size;
  final String lid;
  final double price;
  final bool availableForSale;
  final int? piecesPerPack;
  final int? quantityAvailable;
  final String? imageAsset;
  final String title;
  final String? sku;
  final List<ProductSelectedOption> selectedOptions;
  final double? compareAtPrice;
  final ProductImage? image;
  final double? shopifyUnitPrice;
  final UnitPriceMeasurement? unitPriceMeasurement;
  final ProductQuantityRule quantityRule;
  final String currencyCode;

  double get priceExVat => price;
  double? get unitPrice {
    final packQuantity = piecesPerPack;
    return packQuantity == null ? null : price / packQuantity;
  }

  bool get isAvailable => availableForSale;

  String? optionValue(String optionName) {
    final normalizedName = optionName.toLowerCase();
    for (final option in selectedOptions) {
      if (option.name.toLowerCase() == normalizedName) return option.value;
    }
    return null;
  }

  String get imageSource => image?.url ?? imageAsset ?? '';
}

class ProductQuantityRule {
  const ProductQuantityRule({
    required this.minimum,
    required this.increment,
    this.maximum,
  });

  final int minimum;
  final int increment;
  final int? maximum;

  bool canIncrease(int quantity) {
    final nextQuantity = quantity + increment;
    return maximum == null || nextQuantity <= maximum!;
  }

  int increase(int quantity) {
    return canIncrease(quantity) ? quantity + increment : quantity;
  }

  int decrease(int quantity) {
    final nextQuantity = quantity - increment;
    return nextQuantity < minimum ? minimum : nextQuantity;
  }

  int totalUnits({required int quantity, required int piecesPerPack}) {
    return quantity * piecesPerPack;
  }
}

class ProductImage {
  const ProductImage({required this.url, this.altText});

  final String url;
  final String? altText;
}

class ProductOption {
  const ProductOption({
    required this.id,
    required this.name,
    required this.values,
  });

  final String id;
  final String name;
  final List<String> values;
}

class ProductSelectedOption {
  const ProductSelectedOption({required this.name, required this.value});

  final String name;
  final String value;
}

class UnitPriceMeasurement {
  const UnitPriceMeasurement({
    required this.measuredType,
    required this.quantityUnit,
    required this.quantityValue,
    required this.referenceUnit,
    required this.referenceValue,
  });

  final String measuredType;
  final String quantityUnit;
  final double quantityValue;
  final String referenceUnit;
  final int referenceValue;
}

enum ProductDescriptionBlockType { paragraph, heading, listItem }

class ProductDescriptionParagraph {
  const ProductDescriptionParagraph({
    required this.segments,
    this.type = ProductDescriptionBlockType.paragraph,
  });

  final List<ProductDescriptionSegment> segments;
  final ProductDescriptionBlockType type;
}

class ProductDescriptionSegment {
  const ProductDescriptionSegment(this.text, {this.emphasized = false});

  final String text;
  final bool emphasized;
}

class ProductFeature {
  const ProductFeature({required this.title, required this.description});

  final String title;
  final String description;
}

class ProductSpecification {
  const ProductSpecification({required this.label, required this.value});

  final String label;
  final String value;
}
