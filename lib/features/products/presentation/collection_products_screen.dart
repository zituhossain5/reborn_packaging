import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/widgets/cart_add_feedback.dart';
import '../../home/widgets/delivery_banner.dart';
import '../../home/widgets/home_header.dart';
import '../../home/widgets/shop_bottom_navigation.dart';
import '../actions/product_cart_actions.dart';
import '../models/product_item.dart';
import '../models/product_page.dart';
import '../state/collection_products_provider.dart';
import '../widgets/product_card.dart';

class CollectionProductsScreen extends ConsumerWidget {
  const CollectionProductsScreen({
    required this.collectionTitle,
    required this.collectionHandle,
    super.key,
  });

  final String collectionTitle;
  final String collectionHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(collectionProductsProvider(collectionHandle));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: const ShopBottomNavigation(),
        body: ColoredBox(
          color: AppColors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HomeHeader(
                  onBack: context.pop,
                  onSearch: () => context.push('/search'),
                ),
                const DeliveryBanner(),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.backgroundLight,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.md,
                            0,
                          ),
                          sliver: SliverList.list(
                            children: [
                              Text(
                                collectionTitle.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: AppTypography.productCollectionTitle,
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                          ),
                        ),
                        ...products.when(
                          loading: () => const [
                            _CollectionProductsState(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                          error: (error, stackTrace) => [
                            _CollectionProductsState(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Unable to load products.',
                                    style: AppTypography.searchNoResults,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  FilledButton(
                                    onPressed: () => ref.invalidate(
                                      collectionProductsProvider(
                                        collectionHandle,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          data: (catalog) => [
                            if (catalog.items.isEmpty)
                              const _CollectionProductsState(
                                child: Text(
                                  'No products found.',
                                  style: AppTypography.searchNoResults,
                                ),
                              )
                            else
                              _ProductGrid(
                                catalog: catalog,
                                onProductTap: (product) =>
                                    _openProduct(context, product),
                                onAddToCart: (product) =>
                                    _addToCartOrOpenDetails(
                                      context: context,
                                      ref: ref,
                                      product: product,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addToCartOrOpenDetails({
    required BuildContext context,
    required WidgetRef ref,
    required ProductItem product,
  }) async {
    final result = await quickAddProductItemToCart(ref: ref, product: product);

    if (!context.mounted) return;
    switch (result) {
      case ProductQuickAddResult.added:
        showAddedToCartFeedback(context);
        return;
      case ProductQuickAddResult.requiresOptionSelection:
        _openProduct(context, product);
        return;
      case ProductQuickAddResult.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This product is currently unavailable.'),
          ),
        );
        return;
      case ProductQuickAddResult.failed:
        final error = ref.read(cartControllerProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Unable to add product to cart.')),
        );
        return;
    }
  }

  void _openProduct(BuildContext context, ProductItem product) {
    context.push('/products/${product.handle}', extra: collectionHandle);
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.catalog,
    required this.onProductTap,
    required this.onAddToCart,
  });

  final ProductCatalog catalog;
  final ValueChanged<ProductItem> onProductTap;
  final ValueChanged<ProductItem> onAddToCart;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = catalog.items[index];
          return ProductCard(
            product: product,
            onTap: () => onProductTap(product),
            onAddToCart: () => onAddToCart(product),
          );
        }, childCount: catalog.items.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          mainAxisExtent: ProductCard.height,
        ),
      ),
    );
  }
}

class _CollectionProductsState extends StatelessWidget {
  const _CollectionProductsState({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverToBoxAdapter(
        child: SizedBox(height: 180, child: Center(child: child)),
      ),
    );
  }
}
