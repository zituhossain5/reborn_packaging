import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class ExpressCheckout extends StatelessWidget {
  const ExpressCheckout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'EXPRESS CHECKOUT',
          style: AppTypography.checkoutExpressLabel,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: const [
            Expanded(
              child: _ExpressButton(
                label: 'Shop Pay',
                color: AppColors.shopPay,
                assetPath: 'assets/icons/shop_pay.svg',
                logoWidth: 42,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _ExpressButton(
                label: 'PayPal',
                color: AppColors.payPal,
                assetPath: 'assets/icons/paypal.svg',
                logoWidth: 66,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _ExpressButton(
                label: 'Google Pay',
                color: AppColors.black,
                assetPath: 'assets/icons/google_pay.svg',
                logoWidth: 45,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpressButton extends StatelessWidget {
  const _ExpressButton({
    required this.label,
    required this.color,
    required this.assetPath,
    required this.logoWidth,
  });

  final String label;
  final Color color;
  final String assetPath;
  final double logoWidth;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.compact),
          ),
          child: SizedBox(
            width: logoWidth,
            height: 18,
            child: SvgPicture.asset(assetPath),
          ),
        ),
      ),
    );
  }
}

class CheckoutOrDivider extends StatelessWidget {
  const CheckoutOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('OR', style: AppTypography.checkoutExpressLabel),
        ),
        Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }
}
