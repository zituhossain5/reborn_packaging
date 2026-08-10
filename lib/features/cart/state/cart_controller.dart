import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/models/product_details.dart';
import '../models/cart_item.dart';

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

final cartTotalQuantityProvider = Provider<int>((ref) {
  return ref.watch(
    cartControllerProvider.select((state) => state.totalQuantity),
  );
});

class CartState {
  const CartState({this.items = const [], this.discountAmount = 0});

  final List<CartItem> items;
  final double discountAmount;

  int get totalQuantity {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  int get itemCount => items.length;

  CartState addVariant({
    required ProductDetails product,
    required ProductVariant variant,
    required int quantity,
  }) {
    final existingIndex = items.indexWhere(
      (item) => item.variantId == variant.id,
    );

    if (existingIndex == -1) {
      return CartState(
        items: [
          ...items,
          CartItem(
            productId: product.id,
            productHandle: product.handle,
            productTitle: _cartTitle(product.title, variant.size),
            variantId: variant.id,
            size: variant.size,
            lid: variant.lid,
            imageAsset: variant.imageSource.isNotEmpty
                ? variant.imageSource
                : (product.images.isEmpty ? '' : product.images.first),
            piecesPerPack: variant.piecesPerPack,
            priceExVat: variant.priceExVat,
            quantity: quantity,
          ),
        ],
        discountAmount: discountAmount,
      );
    }

    final updatedItems = [...items];
    final existingItem = updatedItems[existingIndex];
    updatedItems[existingIndex] = existingItem.copyWith(
      quantity: existingItem.quantity + quantity,
    );

    return CartState(items: updatedItems, discountAmount: discountAmount);
  }

  CartState increaseQuantity(String variantId) {
    return _updateQuantity(variantId, (quantity) => quantity + 1);
  }

  CartState decreaseQuantity(String variantId) {
    return _updateQuantity(
      variantId,
      (quantity) => quantity > 1 ? quantity - 1 : 1,
    );
  }

  CartState removeVariant(String variantId) {
    return CartState(
      items: items.where((item) => item.variantId != variantId).toList(),
      discountAmount: discountAmount,
    );
  }

  CartState applyDiscount(double amount) {
    return CartState(items: items, discountAmount: amount);
  }

  CartState _updateQuantity(
    String variantId,
    int Function(int quantity) update,
  ) {
    return CartState(
      items: [
        for (final item in items)
          if (item.variantId == variantId)
            item.copyWith(quantity: update(item.quantity))
          else
            item,
      ],
      discountAmount: discountAmount,
    );
  }

  static String _cartTitle(String productTitle, String size) {
    if (productTitle.toLowerCase().startsWith(size.toLowerCase())) {
      return productTitle;
    }
    return '$size $productTitle';
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  void addVariant({
    required ProductDetails product,
    required ProductVariant variant,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return;
    }

    state = state.addVariant(
      product: product,
      variant: variant,
      quantity: quantity,
    );
  }

  void increaseQuantity(String variantId) {
    state = state.increaseQuantity(variantId);
  }

  void decreaseQuantity(String variantId) {
    state = state.decreaseQuantity(variantId);
  }

  void removeVariant(String variantId) {
    state = state.removeVariant(variantId);
  }

  void setDiscount(double amount) {
    state = state.applyDiscount(amount < 0 ? 0 : amount);
  }

  void clear() => state = const CartState();
}
