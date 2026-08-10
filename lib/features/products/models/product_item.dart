class ProductItem {
  const ProductItem({
    required this.id,
    required this.handle,
    required this.collectionHandle,
    required this.collectionTitle,
    required this.title,
    this.quantity,
    required this.price,
    this.currencyCode = 'GBP',
    this.unitPrice,
    this.imageAsset,
    this.imageUrl,
    this.imageAltText,
    this.availableForSale = true,
    this.variants = const [],
    this.variantSizes = const [],
    this.searchKeywords = const [],
  });

  final String id;
  final String handle;
  final String collectionHandle;
  final String collectionTitle;
  final String title;
  final int? quantity;
  final double price;
  final String currencyCode;
  final double? unitPrice;
  final String? imageAsset;
  final String? imageUrl;
  final String? imageAltText;
  final bool availableForSale;
  final List<ProductVariantItem> variants;
  final List<String> variantSizes;
  final List<String> searchKeywords;
}

class ProductVariantItem {
  const ProductVariantItem({
    required this.id,
    required this.title,
    required this.availableForSale,
    required this.price,
    required this.currencyCode,
    required this.selectedOptions,
  });

  final String id;
  final String title;
  final bool availableForSale;
  final double price;
  final String currencyCode;
  final List<ProductSelectedOption> selectedOptions;
}

class ProductSelectedOption {
  const ProductSelectedOption({required this.name, required this.value});

  final String name;
  final String value;
}
