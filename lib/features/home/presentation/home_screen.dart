import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/collection_item.dart';
import '../models/collection_page.dart';
import '../state/home_collections_provider.dart';
import '../widgets/collection_grid.dart';
import '../widgets/collection_section_header.dart';
import '../widgets/delivery_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/shop_bottom_navigation.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(homeCollectionsProvider);

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
                HomeHeader(onSearch: () => context.push('/search')),
                const DeliveryBanner(),
                Expanded(
                  child: ColoredBox(
                    color: AppColors.backgroundLight,
                    child: CustomScrollView(
                      slivers: collections.when(
                        loading: () => const [
                          _HomeCollectionsState(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                        error: (error, stackTrace) => [
                          _HomeCollectionsState(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Unable to load collections.',
                                  style: AppTypography.searchNoResults,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                FilledButton(
                                  onPressed: () =>
                                      ref.invalidate(homeCollectionsProvider),
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
                          _HomeCollectionContent(
                            catalog: catalog,
                            onItemTap: (item) => context.push(
                              '/collections/${item.handle}',
                              extra: item.title,
                            ),
                          ),
                        ],
                      ),
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

class _HomeCollectionContent extends StatelessWidget {
  const _HomeCollectionContent({
    required this.catalog,
    required this.onItemTap,
  });

  final CollectionCatalog catalog;
  final ValueChanged<CollectionItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      sliver: SliverList.list(
        children: [
          CollectionSectionHeader(collectionCount: catalog.items.length),
          const SizedBox(height: AppSpacing.md),
          if (catalog.items.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No collections found.',
                  style: AppTypography.searchNoResults,
                ),
              ),
            )
          else
            CollectionGrid(items: catalog.items, onItemTap: onItemTap),
        ],
      ),
    );
  }
}

class _HomeCollectionsState extends StatelessWidget {
  const _HomeCollectionsState({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      sliver: SliverList.list(
        children: [
          const CollectionSectionHeader(),
          const SizedBox(height: AppSpacing.md),
          SizedBox(height: 180, child: Center(child: child)),
        ],
      ),
    );
  }
}
