import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class ShopBottomNavigation extends StatelessWidget {
  const ShopBottomNavigation({this.cartBadgeCount, super.key});

  static const _contentHeight = 54.0;
  static const _iconSize = 24.0;

  final int? cartBadgeCount;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final effectiveBottomInset = bottomInset > 6 ? bottomInset - 6 : 0.0;

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
      child: SizedBox(
        height: _contentHeight + effectiveBottomInset,
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
                    child: const _NavigationItem(
                      label: 'SHOP',
                      assetPath: 'assets/icons/shop.svg',
                      color: AppColors.primary,
                      iconPadding: EdgeInsets.all(3.75),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _NavigationItem(
                      label: 'CART',
                      assetPath: 'assets/icons/cart.svg',
                      color: AppColors.secondaryText,
                      iconPadding: const EdgeInsets.fromLTRB(
                        1.685,
                        1.687,
                        1.685,
                        3.938,
                      ),
                      badgeCount: cartBadgeCount,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: const _NavigationItem(
                      label: 'ACCOUNT',
                      assetPath: 'assets/icons/account.svg',
                      color: AppColors.secondaryText,
                      iconPadding: EdgeInsets.all(2.438),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.assetPath,
    required this.color,
    required this.iconPadding,
    this.badgeCount,
  });

  final String label;
  final String assetPath;
  final Color color;
  final EdgeInsets iconPadding;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: label == 'SHOP',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
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
                                color,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (badgeCount != null)
                        Positioned(
                          left: constraints.maxWidth / 2 + 4.5,
                          top: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '$badgeCount',
                              maxLines: 1,
                              style: AppTypography.navigationBadge,
                            ),
                          ),
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
              style: label == 'SHOP'
                  ? AppTypography.navigationActiveLabel
                  : AppTypography.navigationInactiveLabel,
            ),
          ],
        ),
      ),
    );
  }
}
