import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../home/widgets/delivery_banner.dart';
import '../../home/widgets/home_header.dart';
import '../../home/widgets/shop_bottom_navigation.dart';
import '../data/mock_products.dart';
import '../widgets/product_card.dart';

class CollectionProductsScreen extends StatelessWidget {
  const CollectionProductsScreen({
    required this.collectionTitle,
    required this.collectionHandle,
    super.key,
  });

  final String collectionTitle;
  final String collectionHandle;

  @override
  Widget build(BuildContext context) {
    final products = mockProductsForCollection(collectionHandle);

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
        bottomNavigationBar: const ShopBottomNavigation(cartBadgeCount: 2),
        body: ColoredBox(
          color: AppColors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                HomeHeader(onBack: context.pop),
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
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => ProductCard(
                                product: products[index],
                                onTap: () => context.push(
                                  '/products/${products[index].handle}',
                                ),
                              ),
                              childCount: products.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: AppSpacing.sm,
                                  mainAxisSpacing: AppSpacing.sm,
                                  mainAxisExtent: ProductCard.height,
                                ),
                          ),
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
}
