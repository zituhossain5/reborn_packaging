import 'product_details.dart';

ProductVariant? resolveProductVariant({
  required ProductDetails product,
  required String size,
  required String lid,
}) {
  for (final variant in product.variants) {
    if (variant.size == size && variant.lid == lid && variant.isAvailable) {
      return variant;
    }
  }
  return null;
}

ProductVariant? firstAvailableVariantForSize({
  required ProductDetails product,
  required String size,
}) {
  for (final variant in product.variants) {
    if (variant.size == size && variant.isAvailable) {
      return variant;
    }
  }
  return null;
}

ProductVariant? resolveVariantForOptions({
  required ProductDetails product,
  required Map<String, String> selectedOptions,
  bool availableOnly = true,
}) {
  for (final variant in product.variants) {
    if (availableOnly && !variant.isAvailable) continue;
    final matches = selectedOptions.entries.every(
      (entry) => variant.optionValue(entry.key) == entry.value,
    );
    if (matches) return variant;
  }
  return null;
}
