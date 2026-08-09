import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/cart/state/cart_controller.dart';
import 'package:reborn_packaging/features/cart/models/cart_item.dart';
import 'package:reborn_packaging/features/cart/models/cart_summary.dart';
import 'package:reborn_packaging/features/cart/widgets/cart_quantity_badge.dart';
import 'package:reborn_packaging/features/products/data/mock_product_details.dart';

void main() {
  test(
    'cart state merges matching variants and combines different variants',
    () {
      final product = mockKraftRoundBowlsProduct;
      final firstVariant = product.selectedVariant;
      final secondVariant = product.variants.firstWhere(
        (variant) => variant.id != firstVariant.id && variant.isAvailable,
      );

      final state = const CartState()
          .addVariant(product: product, variant: firstVariant, quantity: 1)
          .addVariant(product: product, variant: firstVariant, quantity: 1)
          .addVariant(product: product, variant: firstVariant, quantity: 3)
          .addVariant(product: product, variant: secondVariant, quantity: 2);

      expect(state.items, hasLength(2));
      expect(state.items.first.quantity, 5);
      expect(state.items.last.quantity, 2);
      expect(state.totalQuantity, 7);
      expect(state.items.first.productTitle, '500ml Kraft Round Bowls');
      expect(state.items.first.piecesPerPack, 600);
      expect(state.items.first.priceExVat, 54.95);
    },
  );

  test('cart quantities respect one and removal updates totals', () {
    final product = mockKraftRoundBowlsProduct;
    final variant = product.selectedVariant;
    final added = const CartState().addVariant(
      product: product,
      variant: variant,
      quantity: 1,
    );

    final unchanged = added.decreaseQuantity(variant.id);
    final increased = unchanged.increaseQuantity(variant.id);
    final removed = increased.removeVariant(variant.id);

    expect(unchanged.items.single.quantity, 1);
    expect(increased.items.single.quantity, 2);
    expect(increased.totalQuantity, 2);
    expect(removed.items, isEmpty);
    expect(removed.totalQuantity, 0);
  });

  test('cart summary calculates shipping threshold and reactive totals', () {
    const firstItem = CartItem(
      productId: 'one',
      productHandle: 'one',
      productTitle: 'First',
      variantId: 'one',
      size: '500ml',
      lid: 'Without Lid',
      imageAsset: 'first.png',
      piecesPerPack: 600,
      priceExVat: 41.95,
      quantity: 1,
    );
    const secondItem = CartItem(
      productId: 'two',
      productHandle: 'two',
      productTitle: 'Second',
      variantId: 'two',
      size: 'Large',
      lid: 'Without Lid',
      imageAsset: 'second.png',
      piecesPerPack: 600,
      priceExVat: 25.99,
      quantity: 1,
    );

    final belowThreshold = CartSummary.calculate(
      items: const [firstItem, secondItem],
    );
    final aboveThreshold = CartSummary.calculate(
      items: [firstItem, secondItem.copyWith(quantity: 3)],
      requestedDiscount: 8,
    );

    expect(belowThreshold.subtotal, 67.94);
    expect(belowThreshold.freeShippingRemaining, 32.06);
    expect(belowThreshold.freeShippingProgress, closeTo(0.6794, 0.0001));
    expect(belowThreshold.showsFreeShippingProgress, isTrue);
    expect(aboveThreshold.subtotal, 119.92);
    expect(aboveThreshold.discount, 8);
    expect(aboveThreshold.shipping, 0);
    expect(aboveThreshold.showsFreeShippingProgress, isFalse);
  });

  testWidgets('cart badge hides zero and caps large totals', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CartQuantityBadge(quantity: 0)),
    );

    expect(find.byKey(const ValueKey('cart_quantity_badge')), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(home: CartQuantityBadge(quantity: 100)),
    );

    expect(find.byKey(const ValueKey('cart_quantity_badge')), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
  });
}
