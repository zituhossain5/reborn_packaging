import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/state/cart_controller.dart';
import '../data/mock_product_details.dart';
import '../models/product_details.dart';
import '../models/product_item.dart';

bool addProductItemDefaultVariantToCart({
  required WidgetRef ref,
  required ProductItem product,
}) {
  final productDetails = mockProductDetailsForHandle(product.handle);
  if (productDetails == null) {
    return false;
  }

  final variant = _selectedAvailableVariant(productDetails);
  if (variant == null) {
    return false;
  }

  ref
      .read(cartControllerProvider.notifier)
      .addVariant(product: productDetails, variant: variant, quantity: 1);
  return true;
}

ProductVariant? _selectedAvailableVariant(ProductDetails product) {
  for (final variant in product.variants) {
    if (variant.id == product.selectedVariantId && variant.isAvailable) {
      return variant;
    }
  }
  return null;
}
