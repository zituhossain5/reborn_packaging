import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/widgets/cart_quantity_badge.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    this.onBack,
    this.showCart = false,
    this.showShadow = false,
    this.onCart,
    this.onSearch,
    super.key,
  });

  static const _height = 52.0;
  static const _logoSize = 36.0;
  static const _iconSize = 24.0;

  final VoidCallback? onBack;
  final bool showCart;
  final bool showShadow;
  final VoidCallback? onCart;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartQuantity = ref.watch(cartTotalQuantityProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: AppColors.headerShadow,
                  offset: Offset(0, 3),
                  blurRadius: 8,
                ),
              ]
            : const [],
      ),
      child: SizedBox(
        height: _height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: onBack == null
                ? [_logo(), _trailingButton(cartQuantity)]
                : [_backButton(), _logo(), _trailingButton(cartQuantity)],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Image.asset(
      'assets/images/branding/reborn_symbol.png',
      width: _logoSize,
      height: _logoSize,
      fit: BoxFit.cover,
    );
  }

  Widget _backButton() {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBack,
        child: SizedBox.square(
          dimension: 36,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(9, 10.5, 9, 10.5),
            child: SvgPicture.asset(
              'assets/icons/arrow_left.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchButton() {
    return Semantics(
      button: true,
      label: 'Search',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSearch,
        child: SizedBox.square(
          dimension: _iconSize,
          child: Padding(
            padding: const EdgeInsets.all(2.4),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trailingButton(int cartQuantity) {
    return showCart ? _cartButton(cartQuantity) : _searchButton();
  }

  Widget _cartButton(int cartQuantity) {
    return Semantics(
      button: true,
      explicitChildNodes: true,
      label: 'Cart',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onCart,
        child: SizedBox.square(
          dimension: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: SizedBox(
                  width: 21,
                  height: 18.75,
                  child: SvgPicture.asset(
                    'assets/icons/add_to_cart_bag.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 0,
                child: CartQuantityBadge(quantity: cartQuantity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
