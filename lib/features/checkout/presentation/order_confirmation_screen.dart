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
import '../../account/models/customer_order_details.dart';
import '../../account/state/customer_order_details_provider.dart';
import '../services/shopify_checkout_launcher.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key, this.completion});

  final ShopifyCheckoutCompletion? completion;

  static const _mockOrderNumber = '#RP-20843';
  static const _estimatedArrival = 'Tomorrow by 5PM';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final mockItemCount = cart.items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
    final summary = CartSummary.calculate(
      items: cart.items,
      requestedDiscount: cart.discountAmount,
    );
    final isRealCheckout = completion != null;
    final orderId = completion?.orderId?.trim();
    final canLoadOrderDetails =
        isRealCheckout &&
        orderId != null &&
        orderId.isNotEmpty &&
        ref.watch(isCustomerAccountAuthenticatedProvider);
    final orderDetails = canLoadOrderDetails
        ? ref.watch(customerOrderDetailsProvider(orderId))
        : null;
    final resolvedOrder = orderDetails?.value;
    final itemCount = isRealCheckout
        ? _resolvedItemCount(resolvedOrder) ?? completion!.itemCount
        : mockItemCount;
    final total = isRealCheckout
        ? resolvedOrder?.totalPrice.amount ?? completion!.totalAmount
        : summary.total;
    final currencyCode = isRealCheckout
        ? resolvedOrder?.totalPrice.currencyCode ?? completion?.currencyCode
        : completion?.currencyCode;
    // Checkout Kit's order ID is authoritative for API lookup but is not the
    // customer-facing Shopify order name (for example, #1182).
    final orderReference = isRealCheckout
        ? _orderNumber(resolvedOrder)
        : _mockOrderNumber;
    final estimatedArrival = isRealCheckout
        ? _estimatedArrivalLabel(context, resolvedOrder)
        : _estimatedArrival;

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
                        _SuccessMessage(realCheckout: isRealCheckout),
                        const SizedBox(height: AppSpacing.md),
                        _OrderSummary(
                          orderReference: orderReference,
                          isLoadingOrderMetadata:
                              orderDetails?.isLoading ?? false,
                          itemCount: itemCount,
                          total: total,
                          currencyCode: currencyCode,
                          estimatedArrival: estimatedArrival,
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
                          onTap: () =>
                              _viewOrderDetails(context, ref, resolvedOrder),
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

  void _viewOrderDetails(
    BuildContext context,
    WidgetRef ref,
    CustomerOrderDetails? resolvedOrder,
  ) {
    if (!ref.read(isCustomerAccountAuthenticatedProvider)) {
      _showDetailsMessage(
        context,
        'Order details will be available after account integration.',
      );
      return;
    }
    final orderId = resolvedOrder?.id.trim();
    if (orderId == null || orderId.isEmpty) {
      _showDetailsMessage(context, 'Order details are not available yet.');
      return;
    }
    context.push('/account/orders/details', extra: orderId);
  }

  static int? _resolvedItemCount(CustomerOrderDetails? order) {
    if (order == null) return null;
    return order.lineItems.fold<int>(
      0,
      (total, lineItem) => total + lineItem.quantity,
    );
  }

  static String? _orderNumber(CustomerOrderDetails? order) {
    final name = order?.name.trim();
    if (name != null && name.isNotEmpty) return name;
    final confirmationNumber = order?.confirmationNumber?.trim();
    return confirmationNumber == null || confirmationNumber.isEmpty
        ? null
        : confirmationNumber;
  }

  static String? _estimatedArrivalLabel(
    BuildContext context,
    CustomerOrderDetails? order,
  ) {
    final estimatedArrivalDates =
        order?.fulfillments
            .map((fulfillment) => fulfillment.estimatedDeliveryAt)
            .whereType<DateTime>()
            .toList()
          ?..sort();
    if (estimatedArrivalDates == null || estimatedArrivalDates.isEmpty) {
      return null;
    }
    return MaterialLocalizations.of(
      context,
    ).formatMediumDate(estimatedArrivalDates.first.toLocal());
  }

  static void _showDetailsMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({required this.realCheckout});

  final bool realCheckout;

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
        Text(
          realCheckout
              ? 'Your order has been confirmed.'
              : 'Your order has been confirmed and will be dispatched '
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
    required this.orderReference,
    required this.isLoadingOrderMetadata,
    required this.itemCount,
    required this.total,
    required this.currencyCode,
    required this.estimatedArrival,
  });

  final String? orderReference;
  final bool isLoadingOrderMetadata;
  final int? itemCount;
  final double? total;
  final String? currencyCode;
  final String? estimatedArrival;

  @override
  Widget build(BuildContext context) {
    final itemLabel = itemCount == null
        ? null
        : '$itemCount ${itemCount == 1 ? 'product' : 'products'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          if (orderReference != null || isLoadingOrderMetadata) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SummaryRow(
                label: 'Order number',
                value: orderReference ?? 'Loading...',
                emphasized: orderReference != null,
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (itemLabel != null) _SummaryRow(label: 'Items', value: itemLabel),
          if (itemLabel != null && total != null)
            const SizedBox(height: AppSpacing.sm),
          if (total != null)
            _SummaryRow(
              label: 'Total',
              value: _formatAmount(total!, currencyCode),
            ),
          if (estimatedArrival != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(label: 'Estimated arrival', value: estimatedArrival!),
          ],
        ],
      ),
    );
  }

  static String _formatAmount(double amount, String? currencyCode) {
    if (currencyCode == null || currencyCode == 'GBP') {
      return formatGbp(amount);
    }
    return '$currencyCode ${amount.toStringAsFixed(2)}';
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
