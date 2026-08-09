import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../cart/models/cart_summary.dart';
import '../../cart/state/cart_controller.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key});

  static const _mockOrderNumber = '#RP-20843';
  static const _estimatedArrival = 'Tomorrow by 5PM';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final itemCount = cart.items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
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
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final topSpacing = ((constraints.maxHeight - 458) / 2).clamp(
                24.0,
                139.0,
              );

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: topSpacing),
                        const _SuccessMessage(),
                        const SizedBox(height: AppSpacing.md),
                        _OrderSummary(
                          orderNumber: _mockOrderNumber,
                          itemCount: itemCount,
                          total: summary.total,
                          estimatedArrival: _estimatedArrival,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _OrderActionButton(
                          label: 'Continue shopping',
                          primary: true,
                          onTap: () {
                            ref.read(cartControllerProvider.notifier).clear();
                            context.go('/home');
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _OrderActionButton(
                          label: 'View order details',
                          onTap: () {},
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.orderSuccessBackground,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/icons/order_success_check.svg',
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.tiny),
        const Text('Order placed!', style: AppTypography.orderPlacedTitle),
        const SizedBox(height: AppSpacing.tiny),
        const Text(
          'Your order has been confirmed and will be dispatched '
          'for next-day delivery.',
          textAlign: TextAlign.center,
          style: AppTypography.orderConfirmation,
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.orderNumber,
    required this.itemCount,
    required this.total,
    required this.estimatedArrival,
  });

  final String orderNumber;
  final int itemCount;
  final double total;
  final String estimatedArrival;

  @override
  Widget build(BuildContext context) {
    final itemLabel = '$itemCount ${itemCount == 1 ? 'product' : 'products'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SummaryRow(
              label: 'Order number',
              value: orderNumber,
              emphasized: true,
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Items', value: itemLabel),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Total', value: formatGbp(total)),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Estimated arrival', value: estimatedArrival),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTypography.orderSummaryLabel)),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.right,
            style: emphasized
                ? AppTypography.orderSummaryEmphasis
                : AppTypography.orderSummaryValue,
          ),
        ),
      ],
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary ? AppColors.primary : AppColors.white,
            border: primary ? null : Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            label,
            style: primary
                ? AppTypography.orderActionPrimary
                : AppTypography.orderActionSecondary,
          ),
        ),
      ),
    );
  }
}
