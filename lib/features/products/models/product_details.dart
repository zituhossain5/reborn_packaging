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

  ProductVariant get selectedVariant {
    return variants.firstWhere((variant) => variant.id == selectedVariantId);
  }
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.size,
    required this.lid,
    required this.price,
    required this.availableForSale,
    required this.piecesPerPack,
    required this.quantityAvailable,
    this.imageAsset,
  });

  final String id;
  final String size;
  final String lid;
  final double price;
  final bool availableForSale;
  final int piecesPerPack;
  final int quantityAvailable;
  final String? imageAsset;

  double get priceExVat => price;
  double get unitPrice => price / piecesPerPack;
  bool get isAvailable => availableForSale && quantityAvailable > 0;
}

class ProductQuantityRule {
  const ProductQuantityRule({required this.minimum, required this.increment});

  final int minimum;
  final int increment;

  int increase(int quantity) => quantity + increment;

  int decrease(int quantity) {
    final nextQuantity = quantity - increment;
    return nextQuantity < minimum ? minimum : nextQuantity;
  }

  int totalUnits({required int quantity, required int piecesPerPack}) {
    return quantity * piecesPerPack;
  }
}

class ProductDescriptionParagraph {
  const ProductDescriptionParagraph({required this.segments});

  final List<ProductDescriptionSegment> segments;
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
