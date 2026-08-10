import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/cart/data/cart_id_store.dart';
import 'package:reborn_packaging/features/cart/data/shopify_cart_repository.dart';
import 'package:reborn_packaging/features/cart/state/cart_controller.dart';
import 'package:reborn_packaging/features/products/models/product_details.dart';
import 'package:reborn_packaging/features/products/state/product_selection_controller.dart';

import 'support/fake_cart.dart';

void main() {
  test(
    'Default Title keeps and submits the real selected Shopify variant',
    () async {
      final product = _singleVariantProduct(quantityAvailable: 10);
      final selection = ProductSelectionController(product);
      final repository = FakeCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(repository),
          cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
        ],
      );
      addTearDown(container.dispose);

      expect(product.selectableOptions, isEmpty);
      expect(selection.selectedVariant.id, _variantId);
      expect(selection.quantity, 1);
      expect(
        await container
            .read(cartControllerProvider.notifier)
            .addVariant(
              product: product,
              variant: selection.selectedVariant,
              quantity: selection.quantity,
            ),
        isTrue,
      );
      expect(repository.lastMerchandiseId, _variantId);
      expect(container.read(cartControllerProvider).totalQuantity, 1);
    },
  );

  test(
    'null quantityAvailable does not reject an available Shopify variant',
    () async {
      final product = _singleVariantProduct();
      final repository = FakeCartRepository();
      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(repository),
          cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
        ],
      );
      addTearDown(container.dispose);

      expect(
        await container
            .read(cartControllerProvider.notifier)
            .addVariant(
              product: product,
              variant: product.selectedVariant,
              quantity: 1,
            ),
        isTrue,
      );
      expect(repository.lastMerchandiseId, _variantId);
    },
  );
}

const _variantId = 'gid://shopify/ProductVariant/55521921171831';

ProductDetails _singleVariantProduct({int? quantityAvailable}) {
  const rule = ProductQuantityRule(minimum: 1, increment: 1);
  final variant = ProductVariant(
    id: _variantId,
    size: '',
    lid: '',
    price: 25.99,
    availableForSale: true,
    quantityAvailable: quantityAvailable,
    title: 'Default Title',
    selectedOptions: const [
      ProductSelectedOption(name: 'Title', value: 'Default Title'),
    ],
    quantityRule: rule,
  );
  return ProductDetails(
    id: 'gid://shopify/Product/123',
    handle: '500ml-bagasse-buddha-style-bowl-300-pieces',
    title: '500ml Bagasse Buddha Style Bowl | 300 Pieces',
    images: const [],
    currency: 'GBP',
    selectedVariantId: _variantId,
    variants: [variant],
    sizes: const [],
    lidOptions: const [],
    quantityRule: rule,
    description: const [],
    features: const [],
    specifications: const [],
    options: const [
      ProductOption(
        id: 'gid://shopify/ProductOption/1',
        name: 'Title',
        values: ['Default Title'],
      ),
    ],
  );
}
