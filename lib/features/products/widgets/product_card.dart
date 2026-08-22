import 'dart:async';
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
  static const _buttonTop = AppSpacing.sm + _imageSize + AppSpacing.sm + 60;

  final ProductItem product;
  final VoidCallback? onTap;
  final FutureOr<void> Function()? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              key: ValueKey('product_card_body_${product.handle}'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppSpacing.sm),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final imageSize = math.min(
                        _imageSize,
                        constraints.maxWidth,
                      );

                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: _imageSize,
                            child: Center(
                              child: SizedBox.square(
                                dimension: imageSize,
                                child: _ProductImage(product: product),
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
          ),
          Positioned(
            right: AppSpacing.sm,
            top: _buttonTop,
            child: _AddToCartButton(
              key: ValueKey('product_card_add_to_cart_${product.handle}'),
              label: 'Add ${product.title} to cart',
              enabled: product.availableForSale,
              onTap: onAddToCart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.clip,
          style: AppTypography.productTitle,
        ),
        const SizedBox(height: AppSpacing.tiny),
        SizedBox(
          height: 15,
          child: product.quantity == null
              ? null
              : Text(
                  '${product.quantity} QTY',
                  maxLines: 1,
                  style: AppTypography.productQuantity,
                ),
        ),
        const SizedBox(height: AppSpacing.compact),
        Text(
          '${_currencyPrefix(product.currencyCode)}${product.price.toStringAsFixed(2)}',
          maxLines: 1,
          style: AppTypography.productPrice,
        ),
        SizedBox(
          height: 13,
          child: product.unitPrice == null
              ? null
              : Text(
                  '${_currencyPrefix(product.currencyCode)}${product.unitPrice!.toStringAsFixed(3)} / piece',
                  maxLines: 1,
                  style: AppTypography.productUnitPrice,
                ),
        ),
      ],
    );
  }

  String _currencyPrefix(String currencyCode) {
    return currencyCode == 'GBP' ? '\u00A3' : '$currencyCode ';
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductItem product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        semanticLabel: product.imageAltText,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
      );
    }

    final imageAsset = product.imageAsset;
    if (imageAsset != null && imageAsset.isNotEmpty) {
      return Image.asset(imageAsset, fit: BoxFit.cover);
    }

    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.image_not_supported_outlined,
      color: AppColors.lightText,
      size: 24,
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton({
    required this.label,
    required this.enabled,
    this.onTap,
    super.key,
  });

  final String label;
  final bool enabled;
  final FutureOr<void> Function()? onTap;

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  var _pressed = false;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled && !_isLoading,
      label: _isLoading ? 'Adding to cart' : widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled && !_isLoading ? _handleTap : null,
        onTapDown: widget.enabled && !_isLoading
            ? (_) => _setPressed(true)
            : null,
        onTapUp: widget.enabled && !_isLoading
            ? (_) => _setPressed(false)
            : null,
        onTapCancel: widget.enabled && !_isLoading
            ? () => _setPressed(false)
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Container(
            width: ProductCard._buttonSize,
            height: ProductCard._buttonSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : SizedBox.square(
                    dimension: ProductCard._bagIconSize,
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
    );
  }

  Future<void> _handleTap() async {
    final onTap = widget.onTap;
    if (onTap == null || _isLoading) return;

    setState(() {
      _pressed = false;
      _isLoading = true;
    });
    try {
      await onTap();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setPressed(bool pressed) {
    if (_pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }
}
