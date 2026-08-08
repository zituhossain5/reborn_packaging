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
