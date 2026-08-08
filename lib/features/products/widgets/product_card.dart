import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/product_item.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    this.onTap,
    this.onAddToCart,
    super.key,
  });

  static const height = 275.0;
  static const _imageSize = 140.0;
  static const _buttonSize = 38.0;
  static const _bagIconSize = 18.0;

  final ProductItem product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.sm)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageSize = math.min(_imageSize, constraints.maxWidth);

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: _imageSize,
                      child: Center(
                        child: SizedBox.square(
                          dimension: imageSize,
                          child: Image.asset(
                            product.imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(child: _productDetails()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _productDetails() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.clip,
              style: AppTypography.productTitle,
            ),
            const SizedBox(height: AppSpacing.tiny),
            Text(
              '${product.quantity} QTY',
              maxLines: 1,
              style: AppTypography.productQuantity,
            ),
            const SizedBox(height: AppSpacing.compact),
            Text(
              '\u00A3${product.price.toStringAsFixed(2)}',
              maxLines: 1,
              style: AppTypography.productPrice,
            ),
            Text(
              '\u00A3${product.unitPrice.toStringAsFixed(3)} / piece',
              maxLines: 1,
              style: AppTypography.productUnitPrice,
            ),
          ],
        ),
        Positioned(
          right: 0,
          top: 60,
          child: Semantics(
            button: true,
            label: 'Add ${product.title} to cart',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAddToCart ?? () {},
              child: Container(
                width: _buttonSize,
                height: _buttonSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: SizedBox.square(
                  dimension: _bagIconSize,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      1.125,
                      1.125,
                      1.125,
                      2.8125,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/add_to_cart_bag.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
