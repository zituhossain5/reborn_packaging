import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({
    required this.totalPrice,
    required this.onAddToCart,
    super.key,
  });

  final double totalPrice;
  final VoidCallback onAddToCart;

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
        height: 56 + effectiveBottomInset,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total price',
                      maxLines: 1,
                      style: AppTypography.bottomBarCaption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\u00A3${totalPrice.toStringAsFixed(2)}',
                      maxLines: 1,
                      style: AppTypography.productDetailsPrice,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Add to cart',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAddToCart,
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.compact),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 17.5,
                            height: 15.625,
                            child: SvgPicture.asset(
                              'assets/icons/add_to_cart_bag.svg',
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.compact),
                          const Text(
                            'ADD TO CART',
                            style: AppTypography.bottomBarButton,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
