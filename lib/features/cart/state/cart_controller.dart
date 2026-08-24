import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/shopify_failure.dart';
import '../../products/models/product_details.dart';
import '../data/cart_id_store.dart';
import '../data/shopify_cart_repository.dart';
import '../models/cart_item.dart';
import '../models/shopify_cart.dart';

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

final cartTotalQuantityProvider = Provider<int>(
  (ref) =>
      ref.watch(cartControllerProvider.select((state) => state.totalQuantity)),
);

class CartState {
  const CartState({
    this.cart,
    this.isRestoring = false,
    this.isMutating = false,
    this.errorMessage,
  });

  final ShopifyCart? cart;
  final bool isRestoring;
  final bool isMutating;
  final String? errorMessage;

  List<CartItem> get items => cart?.lines ?? const [];
  int get totalQuantity => cart?.totalQuantity ?? 0;
  int get itemCount => items.length;
  double get discountAmount => 0;

  CartState copyWith({
    Object? cart = _unchanged,
    bool? isRestoring,
    bool? isMutating,
    Object? errorMessage = _unchanged,
  }) {
    return CartState(
      cart: identical(cart, _unchanged) ? this.cart : cart as ShopifyCart?,
      isRestoring: isRestoring ?? this.isRestoring,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _unchanged = Object();
}

class CartController extends Notifier<CartState> {
  late final CartRepository _repository;
  late final CartIdStore _idStore;

  @override
  CartState build() {
    _repository = ref.watch(cartRepositoryProvider);
    _idStore = ref.watch(cartIdStoreProvider);
    Future.microtask(restore);
    return const CartState(isRestoring: true);
  }

  Future<void> restore() async {
    state = state.copyWith(isRestoring: true, errorMessage: null);
    try {
      final savedId = await _idStore.read();
      if (savedId == null || savedId.isEmpty) {
        state = const CartState();
        return;
      }
      final cart = await _repository.fetchCart(savedId);
      if (cart == null) {
        await _idStore.clear();
        state = const CartState();
        return;
      }
      state = CartState(cart: cart);
    } on ShopifyFailure catch (failure) {
      state = CartState(errorMessage: failure.message);
    } catch (_) {
      state = const CartState(errorMessage: 'Unable to restore your cart.');
    }
  }

  Future<bool> addVariant({
    required ProductDetails product,
    required ProductVariant variant,
    required int quantity,
  }) async {
    final validationFailure = _validateVariant(
      product: product,
      variant: variant,
      quantity: quantity,
    );
    if (validationFailure != null) {
      _setFailure(validationFailure);
      return false;
    }
    return addMerchandise(merchandiseId: variant.id, quantity: quantity);
  }

  Future<bool> addMerchandise({
    required String merchandiseId,
    required int quantity,
  }) async {
    if (quantity <= 0 || state.isMutating) return false;
    state = state.copyWith(isMutating: true, errorMessage: null);
    final existingCart = state.cart;
    final previousQuantity = existingCart?.totalQuantity ?? 0;
    try {
      final cart = existingCart == null
          ? await _repository.createCart(
              merchandiseId: merchandiseId,
              quantity: quantity,
            )
          : await _repository.addLine(
              cartId: existingCart.id,
              merchandiseId: merchandiseId,
              quantity: quantity,
            );
      await _accept(cart);
      if (cart.warnings.isNotEmpty) {
        final message = cart.warnings
            .map((warning) => warning.message)
            .join('; ');
        state = state.copyWith(errorMessage: message);
        return cart.totalQuantity > previousQuantity;
      }
      return true;
    } on ShopifyUserFailure catch (failure) {
      if (existingCart != null && failure.indicatesInvalidCart) {
        return _recreateCart(merchandiseId, quantity);
      }
      _setFailure(failure.message);
      return false;
    } on ShopifyFailure catch (failure) {
      _setFailure(failure.message);
      return false;
    } catch (error, stackTrace) {
      _setUnexpectedFailure(
        action: 'add this product to your cart',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> increaseQuantity(String lineId) async {
    final line = _line(lineId);
    if (line == null) return false;
    final next = line.quantity + line.quantityRule.increment;
    final maximum = line.quantityRule.maximum;
    if (maximum != null && next > maximum) return false;
    return _updateQuantity(line, next);
  }

  Future<bool> decreaseQuantity(String lineId) async {
    final line = _line(lineId);
    if (line == null) return false;
    final next = line.quantity - line.quantityRule.increment;
    if (next < line.quantityRule.minimum) return false;
    return _updateQuantity(line, next);
  }

  Future<bool> removeLine(String lineId) async {
    final cart = state.cart;
    if (cart == null || state.isMutating) return false;
    state = state.copyWith(isMutating: true, errorMessage: null);
    try {
      await _accept(
        await _repository.removeLine(cartId: cart.id, lineId: lineId),
      );
      return true;
    } on ShopifyFailure catch (failure) {
      await _handleMutationFailure(failure);
      return false;
    } catch (error, stackTrace) {
      _setUnexpectedFailure(
        action: 'remove this item',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> applyDiscountCode(String code) async {
    final cart = state.cart;
    if (cart == null || state.isMutating) return false;
    state = state.copyWith(isMutating: true, errorMessage: null);
    try {
      final normalized = code.trim();
      await _accept(
        await _repository.updateDiscountCodes(
          cartId: cart.id,
          discountCodes: normalized.isEmpty ? const [] : [normalized],
        ),
      );
      return state.cart?.discountCodes.every(
            (discount) => discount.applicable,
          ) ??
          false;
    } on ShopifyFailure catch (failure) {
      await _handleMutationFailure(failure);
      return false;
    } catch (error, stackTrace) {
      _setUnexpectedFailure(
        action: 'apply the discount code',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> updateBuyerIdentity(String? customerAccessToken) async {
    final cart = state.cart;
    if (cart == null || state.isMutating) return false;
    state = state.copyWith(isMutating: true, errorMessage: null);
    try {
      final updatedCart = await _repository.updateBuyerIdentity(
        cartId: cart.id,
        customerAccessToken: customerAccessToken,
      );
      final expectsAuthenticatedBuyer =
          customerAccessToken?.trim().isNotEmpty ?? false;
      if (expectsAuthenticatedBuyer && !updatedCart.hasAuthenticatedBuyer) {
        throw const ShopifyResponseFailure(
          'Shopify could not authenticate this checkout. Please sign in again.',
        );
      }
      await _accept(updatedCart);
      return true;
    } on ShopifyFailure catch (failure) {
      await _handleMutationFailure(failure);
      return false;
    } catch (error, stackTrace) {
      _setUnexpectedFailure(
        action: 'prepare checkout',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> clear() async {
    state = const CartState();
    await _idStore.clear();
  }

  Future<bool> _updateQuantity(CartLine line, int quantity) async {
    final cart = state.cart;
    if (cart == null || state.isMutating) return false;
    state = state.copyWith(isMutating: true, errorMessage: null);
    try {
      await _accept(
        await _repository.updateLine(
          cartId: cart.id,
          lineId: line.id,
          quantity: quantity,
        ),
      );
      return true;
    } on ShopifyFailure catch (failure) {
      await _handleMutationFailure(failure);
      return false;
    } catch (error, stackTrace) {
      _setUnexpectedFailure(
        action: 'update this quantity',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _recreateCart(String merchandiseId, int quantity) async {
    await _idStore.clear();
    state = const CartState(isMutating: true);
    try {
      await _accept(
        await _repository.createCart(
          merchandiseId: merchandiseId,
          quantity: quantity,
        ),
      );
      return true;
    } on ShopifyFailure catch (failure) {
      _setFailure(failure.message);
      return false;
    }
  }

  Future<void> _accept(ShopifyCart cart) async {
    await _idStore.save(cart.id);
    state = CartState(cart: cart);
  }

  Future<void> _handleMutationFailure(ShopifyFailure failure) async {
    if (failure is ShopifyUserFailure && failure.indicatesInvalidCart) {
      await _idStore.clear();
      state = const CartState(
        errorMessage:
            'Your previous cart expired. Add an item to start a new cart.',
      );
      return;
    }
    _setFailure(failure.message);
  }

  CartLine? _line(String lineId) {
    for (final line in state.items) {
      if (line.id == lineId) return line;
    }
    return null;
  }

  void _setFailure(String message) {
    state = state.copyWith(
      isRestoring: false,
      isMutating: false,
      errorMessage: message,
    );
  }

  String? _validateVariant({
    required ProductDetails product,
    required ProductVariant variant,
    required int quantity,
  }) {
    if (!product.variants.any((candidate) => candidate.id == variant.id)) {
      return 'The selected product variant is no longer available.';
    }
    if (product.id.startsWith('gid://shopify/Product/') &&
        !variant.id.startsWith('gid://shopify/ProductVariant/')) {
      return 'The selected Shopify product variant is invalid.';
    }
    if (!variant.availableForSale) {
      return 'This product variant is currently unavailable.';
    }
    final rule = variant.quantityRule;
    if (quantity < rule.minimum) {
      return 'The minimum quantity for this variant is ${rule.minimum}.';
    }
    if (rule.maximum != null && quantity > rule.maximum!) {
      return 'The maximum quantity for this variant is ${rule.maximum}.';
    }
    if ((quantity - rule.minimum) % rule.increment != 0) {
      return 'Quantity must increase in steps of ${rule.increment}.';
    }
    final available = variant.quantityAvailable;
    if (available != null && quantity > available) {
      return 'Only $available of this variant are currently available.';
    }
    return null;
  }

  void _setUnexpectedFailure({
    required String action,
    required Object error,
    required StackTrace stackTrace,
  }) {
    final safeError = _redactCartIds(error.toString());
    if (kDebugMode) {
      debugPrint('Unexpected Shopify cart error: $safeError');
      debugPrintStack(stackTrace: stackTrace);
    }
    _setFailure('Unable to $action. Please try again.');
  }

  String _redactCartIds(String value) {
    return value
        .replaceAll(
          RegExp(r'''gid://shopify/Cart/[^\s"']+'''),
          '[redacted Shopify cart ID]',
        )
        .replaceAll(RegExp(r'https?://\S+'), '[redacted URL]')
        .replaceAll(
          RegExp(
            r'(token|code|verifier|key)=([^&\s]+)',
            caseSensitive: false,
          ),
          r'$1=[redacted]',
        );
  }
}
