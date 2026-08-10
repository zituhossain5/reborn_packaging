import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/state/cart_controller.dart';
import '../models/product_item.dart';

enum ProductQuickAddResult {
  added,
  requiresOptionSelection,
  unavailable,
  failed,
}

Future<bool> addProductItemDefaultVariantToCart({
  required WidgetRef ref,
  required ProductItem product,
}) async {
  final result = await quickAddProductItemToCart(ref: ref, product: product);
  return result == ProductQuickAddResult.added;
}

Future<ProductQuickAddResult> quickAddProductItemToCart({
  required WidgetRef ref,
  required ProductItem product,
}) async {
  final availableVariants = product.variants
      .where((variant) => variant.availableForSale)
      .toList(growable: false);
  if (!product.availableForSale ||
      (availableVariants.isEmpty &&
          product.quickAddVariantAvailableForSale != true)) {
    return ProductQuickAddResult.unavailable;
  }

  String? variantId;
  if (product.quickAddVariantAvailableForSale == true &&
      product.quickAddVariantId != null &&
      product.quickAddVariantId!.isNotEmpty) {
    variantId = product.quickAddVariantId;
  } else if (availableVariants.length == 1) {
    variantId = availableVariants.single.id;
  }

  if (variantId == null) {
    return ProductQuickAddResult.requiresOptionSelection;
  }
  if (product.id.startsWith('gid://shopify/Product/') &&
      !variantId.startsWith('gid://shopify/ProductVariant/')) {
    return ProductQuickAddResult.failed;
  }

  final added = await ref
      .read(cartControllerProvider.notifier)
      .addMerchandise(merchandiseId: variantId, quantity: 1);
  return added ? ProductQuickAddResult.added : ProductQuickAddResult.failed;
}
