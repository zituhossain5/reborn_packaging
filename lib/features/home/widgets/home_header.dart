import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    this.onBack,
    this.showCart = false,
    this.showShadow = false,
    super.key,
  });

  static const _height = 52.0;
  static const _logoSize = 36.0;
  static const _iconSize = 24.0;

  final VoidCallback? onBack;
  final bool showCart;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
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
                ? [_logo(), _trailingButton()]
                : [_backButton(), _logo(), _trailingButton()],
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
        onTap: () {},
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

  Widget _trailingButton() {
    return showCart ? _cartButton() : _searchButton();
  }

  Widget _cartButton() {
    return Semantics(
      button: true,
      label: 'Cart',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: SizedBox.square(
          dimension: 36,
          child: Center(
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
        ),
      ),
    );
  }
}
