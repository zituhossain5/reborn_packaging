import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../data/mock_collections.dart';
import '../widgets/collection_grid.dart';
import '../widgets/collection_section_header.dart';
import '../widgets/delivery_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/shop_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _collectionCount = 25;

  @override
  Widget build(BuildContext context) {
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
                const HomeHeader(),
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
                            AppSpacing.md,
                          ),
                          sliver: SliverList.list(
                            children: [
                              const CollectionSectionHeader(
                                collectionCount: _collectionCount,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              CollectionGrid(
                                items: mockCollections,
                                onItemTap: (item) {
                                  if (item.handle != 'kraft-round-bowls') {
                                    return;
                                  }

                                  context.push(
                                    '/collections/${item.handle}',
                                    extra: item.title,
                                  );
                                },
                              ),
                            ],
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
