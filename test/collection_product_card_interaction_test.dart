import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reborn_packaging/features/cart/data/cart_id_store.dart';
import 'package:reborn_packaging/features/cart/data/shopify_cart_repository.dart';
import 'package:reborn_packaging/features/products/models/product_item.dart';
import 'package:reborn_packaging/features/products/models/product_page.dart';
import 'package:reborn_packaging/features/products/presentation/collection_products_screen.dart';
import 'package:reborn_packaging/features/products/state/collection_products_provider.dart';

import 'support/fake_cart.dart';

void main() {
  testWidgets('product card body opens details', (tester) async {
    await _pumpCollectionProducts(tester, FakeCartRepository());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('product_card_body_test-single-product')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Product Details: test-single-product'), findsOneWidget);
  });

  testWidgets('product card bag adds to cart without navigating', (
    tester,
  ) async {
    final repository = FakeCartRepository();
    await _pumpCollectionProducts(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('product_card_add_to_cart_test-single-product'),
      ),
    );
    await tester.pump();

    expect(repository.lastMerchandiseId, _variantId);
    expect(find.text('Product Details: test-single-product'), findsNothing);
    expect(find.byKey(const ValueKey('cart_quantity_badge')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('product_card_add_to_cart_test-single-product'),
      ),
    );
    await tester.pump();

    expect(find.text('Product Details: test-single-product'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });
}

Future<void> _pumpCollectionProducts(
  WidgetTester tester,
  FakeCartRepository repository,
) {
  final router = GoRouter(
    initialLocation: '/collections/test-collection',
    routes: [
      GoRoute(
        path: '/collections/:handle',
        builder: (context, state) => const CollectionProductsScreen(
          collectionTitle: 'Test Collection',
          collectionHandle: 'test-collection',
        ),
      ),
      GoRoute(
        path: '/products/:handle',
        builder: (context, state) =>
            Text('Product Details: ${state.pathParameters['handle']}'),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const SizedBox.shrink(),
      ),
    ],
  );
  addTearDown(router.dispose);

  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        collectionProductsProvider.overrideWith(
          (ref, handle) async => const ProductCatalog(
            items: [_product],
            pageInfo: ProductPageInfo(hasNextPage: false, endCursor: null),
            pagesFetched: 1,
          ),
        ),
        cartRepositoryProvider.overrideWithValue(repository),
        cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

const _variantId = 'gid://shopify/ProductVariant/123';

const _product = ProductItem(
  id: 'gid://shopify/Product/456',
  handle: 'test-single-product',
  collectionHandle: 'test-collection',
  collectionTitle: 'Test Collection',
  title: 'Test Single Product',
  quantity: null,
  price: 12.34,
  quickAddVariantId: _variantId,
  quickAddVariantTitle: 'Default Title',
  quickAddVariantAvailableForSale: true,
  variants: [
    ProductVariantItem(
      id: _variantId,
      title: 'Default Title',
      availableForSale: true,
      price: 12.34,
      currencyCode: 'GBP',
      selectedOptions: [
        ProductSelectedOption(name: 'Title', value: 'Default Title'),
      ],
    ),
    ProductVariantItem(
      id: 'gid://shopify/ProductVariant/124',
      title: 'Large',
      availableForSale: true,
      price: 14.34,
      currencyCode: 'GBP',
      selectedOptions: [ProductSelectedOption(name: 'Size', value: 'Large')],
    ),
  ],
);
