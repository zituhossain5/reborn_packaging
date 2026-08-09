import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../cart/models/cart_summary.dart';
import '../../cart/state/cart_controller.dart';
import '../widgets/checkout_header.dart';
import '../widgets/checkout_steps.dart';
import '../widgets/payment_card.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final summary = CartSummary.calculate(
      items: cart.items,
      requestedDiscount: cart.discountAmount,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        bottomNavigationBar: _PayNowBar(
          total: summary.total,
          onPay: () => context.push('/checkout/confirmation'),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CheckoutHeader(onBack: context.pop),
              const CheckoutSteps(currentStep: 2),
              const Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: PaymentCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayNowBar extends StatelessWidget {
  const _PayNowBar({required this.total, required this.onPay});

  final double total;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
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
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Semantics(
          button: true,
          label: 'Pay now',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPay,
            child: Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                'Pay now — ${formatGbp(total)}',
                style: AppTypography.cartCheckoutButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
