import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/cart/data/cart_id_store.dart';
import 'package:reborn_packaging/features/cart/data/shopify_cart_repository.dart';
import 'package:reborn_packaging/features/cart/state/cart_controller.dart';
import 'package:reborn_packaging/features/cart/widgets/cart_quantity_badge.dart';
import 'package:reborn_packaging/features/products/data/mock_product_details.dart';

import 'support/fake_cart.dart';

void main() {
  test(
    'Shopify cart creates lazily, merges variants, updates and removes lines',
    () async {
      final repository = FakeCartRepository();
      final idStore = MemoryCartIdStore();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(repository),
          cartIdStoreProvider.overrideWithValue(idStore),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(cartControllerProvider.notifier);
      final product = mockKraftRoundBowlsProduct;
      final first = product.selectedVariant;
      final second = product.variants.firstWhere(
        (variant) => variant.id != first.id && variant.isAvailable,
      );

      expect(
        await controller.addVariant(
          product: product,
          variant: first,
          quantity: 1,
        ),
        isTrue,
      );
      expect(
        await controller.addVariant(
          product: product,
          variant: first,
          quantity: 2,
        ),
        isTrue,
      );
      expect(
        await controller.addVariant(
          product: product,
          variant: second,
          quantity: 1,
        ),
        isTrue,
      );
      expect(repository.createCalls, 1);
      expect(repository.addCalls, 2);
      expect(container.read(cartControllerProvider).totalQuantity, 4);
      expect(container.read(cartControllerProvider).items, hasLength(2));
      expect(idStore.value, contains('?key='));

      final firstLine = container.read(cartControllerProvider).items.first;
      await controller.increaseQuantity(firstLine.lineId);
      expect(repository.updateCalls, 1);
      await controller.removeLine(firstLine.lineId);
      expect(repository.removeCalls, 1);
      expect(container.read(cartControllerProvider).items, hasLength(1));
    },
  );

  test('saved full cart ID restores Shopify state', () async {
    final repository = FakeCartRepository();
    final created = await repository.createCart(
      merchandiseId: mockKraftRoundBowlsProduct.selectedVariant.id,
      quantity: 3,
    );
    final idStore = MemoryCartIdStore()..value = created.id;
    final container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(repository),
        cartIdStoreProvider.overrideWithValue(idStore),
      ],
    );
    addTearDown(container.dispose);

    container.read(cartControllerProvider);
    await container.read(cartControllerProvider.notifier).restore();
    expect(container.read(cartControllerProvider).totalQuantity, 3);
    expect(idStore.value, created.id);
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

  test('checkout buyer identity refreshes the centralized cart', () async {
    final repository = FakeCartRepository();
    final container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(repository),
        cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(cartControllerProvider.notifier);
    await controller.addVariant(
      product: mockKraftRoundBowlsProduct,
      variant: mockKraftRoundBowlsProduct.selectedVariant,
      quantity: 1,
    );

    expect(
      await controller.updateBuyerIdentity('customer-account-oauth-token'),
      isTrue,
    );
    expect(
      repository.lastCustomerAccessToken,
      'customer-account-oauth-token',
    );
  });
}
