import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/widgets/cart_quantity_badge.dart';
import '../../auth/state/customer_auth_controller.dart';

enum ShopNavigationItem { shop, cart, account }

class ShopBottomNavigation extends ConsumerWidget {
  const ShopBottomNavigation({super.key});

  static const _contentHeight = 55.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartQuantity = ref.watch(cartTotalQuantityProvider);
    final isAuthenticated =
        ref.watch(customerAuthControllerProvider).value != null;
    final activeItem = _activeItemForPath(GoRouterState.of(context).uri.path);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.navigationShadow,
            offset: Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _contentHeight,
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              top: AppSpacing.sm,
              right: AppSpacing.md,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableItemWidth = constraints.maxWidth / 3;
                final itemWidth = availableItemWidth < 110
                    ? availableItemWidth
                    : 110.0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _NavigationItem(
                        label: 'SHOP',
                        assetPath: activeItem == ShopNavigationItem.shop
                            ? 'assets/icons/shop.svg'
                            : 'assets/icons/shop_outline.svg',
                        selected: activeItem == ShopNavigationItem.shop,
                        iconPadding: const EdgeInsets.all(3.75),
                        onTap: () => context.go('/home'),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _NavigationItem(
                        label: 'CART',
                        assetPath: activeItem == ShopNavigationItem.cart
                            ? 'assets/icons/cart_bag_filled.svg'
                            : 'assets/icons/cart.svg',
                        selected: activeItem == ShopNavigationItem.cart,
                        iconPadding: const EdgeInsets.fromLTRB(
                          1.685,
                          1.687,
                          1.685,
                          3.938,
                        ),
                        badgeCount: cartQuantity,
                        onTap: () => context.go('/cart'),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _NavigationItem(
                        label: 'ACCOUNT',
                        assetPath: activeItem == ShopNavigationItem.account
                            ? 'assets/icons/account_filled.svg'
                            : 'assets/icons/account.svg',
                        selected: activeItem == ShopNavigationItem.account,
                        iconPadding: activeItem == ShopNavigationItem.account
                            ? const EdgeInsets.all(2.25)
                            : const EdgeInsets.all(2.438),
                        onTap: () => context.go(
                          isAuthenticated ? '/account' : '/login',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ShopNavigationItem _activeItemForPath(String path) {
    if (path == '/login' || path.startsWith('/account')) {
      return ShopNavigationItem.account;
    }
    if (path.startsWith('/cart')) {
      return ShopNavigationItem.cart;
    }
    return ShopNavigationItem.shop;
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.assetPath,
    required this.selected,
    required this.iconPadding,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final String assetPath;
  final bool selected;
  final EdgeInsets iconPadding;
  final VoidCallback? onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: ShopBottomNavigation._iconSize,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox.square(
                          dimension: ShopBottomNavigation._iconSize,
                          child: Padding(
                            padding: iconPadding,
                            child: SvgPicture.asset(
                              assetPath,
                              colorFilter: ColorFilter.mode(
                                selected
                                    ? AppColors.primary
                                    : AppColors.secondaryText,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (badgeCount != null && badgeCount! > 0)
                        Positioned(
                          left: constraints.maxWidth / 2 + 4.5,
                          top: -4,
                          child: CartQuantityBadge(quantity: badgeCount!),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: selected
                  ? AppTypography.navigationActiveLabel
                  : AppTypography.navigationInactiveLabel,
            ),
          ],
        ),
      ),
    );
  }
}
