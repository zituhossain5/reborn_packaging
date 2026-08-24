import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/money_formatter.dart';
import '../models/customer_order_details.dart';
import '../state/customer_order_details_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(customerOrderDetailsProvider(orderId));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Text('Order details', style: AppTypography.accountName),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: order.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _OrderError(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(customerOrderDetailsProvider(orderId)),
          ),
          data: (value) => _OrderDetailsBody(order: value),
        ),
      ),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({required this.order});

  final CustomerOrderDetails order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _DetailsCard(
          children: [
            Text(order.name, style: AppTypography.accountOrdersHeading),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              _formatDate(order.createdAt),
              style: AppTypography.accountOrderMeta,
            ),
            if (order.confirmationNumber != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                label: 'Confirmation',
                value: order.confirmationNumber!,
              ),
            ],
            if (order.financialStatus != null)
              _DetailRow(
                label: 'Payment',
                value: _humanize(order.financialStatus!),
              ),
            _DetailRow(
              label: 'Fulfillment',
              value: _humanize(order.fulfillmentStatus),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('ITEMS', style: AppTypography.accountSectionLabel),
        const SizedBox(height: AppSpacing.xs),
        _DetailsCard(
          children: [
            for (var index = 0; index < order.lineItems.length; index++) ...[
              _LineItem(item: order.lineItems[index]),
              if (index < order.lineItems.length - 1)
                const Divider(
                  height: AppSpacing.lg,
                  color: AppColors.borderLight,
                ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('TOTALS', style: AppTypography.accountSectionLabel),
        const SizedBox(height: AppSpacing.xs),
        _DetailsCard(
          children: [
            if (order.subtotal != null)
              _DetailRow(label: 'Subtotal', value: _money(order.subtotal!)),
            if (order.totalShipping != null)
              _DetailRow(
                label: 'Shipping',
                value: _money(order.totalShipping!),
              ),
            if (order.totalTax != null)
              _DetailRow(label: 'Tax', value: _money(order.totalTax!)),
            const Divider(height: AppSpacing.md, color: AppColors.borderLight),
            _DetailRow(
              label: 'Total',
              value: _money(order.totalPrice),
              emphasized: true,
            ),
          ],
        ),
        if (order.shippingAddress != null) ...[
          const SizedBox(height: AppSpacing.md),
          const Text(
            'SHIPPING ADDRESS',
            style: AppTypography.accountSectionLabel,
          ),
          const SizedBox(height: AppSpacing.xs),
          _DetailsCard(
            children: [
              Text(
                order.shippingAddress!.formatted.join('\n'),
                style: AppTypography.accountAddressBody,
              ),
            ],
          ),
        ],
        if (order.fulfillments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('TRACKING', style: AppTypography.accountSectionLabel),
          const SizedBox(height: AppSpacing.xs),
          _DetailsCard(
            children: [
              for (final fulfillment in order.fulfillments)
                _FulfillmentDetails(fulfillment: fulfillment),
            ],
          ),
        ],
      ],
    );
  }

  static String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static String _humanize(String value) {
    final words = value.toLowerCase().split('_');
    return words
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static String _money(ShopifyOrderMoney money) {
    return money.currencyCode == 'GBP'
        ? formatGbp(money.amount)
        : '${money.currencyCode} ${money.amount.toStringAsFixed(2)}';
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTypography.orderSummaryLabel)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: emphasized
                  ? AppTypography.orderSummaryEmphasis
                  : AppTypography.orderSummaryValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.item});

  final CustomerOrderLineItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            child: Image.network(
              item.imageUrl!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.square(dimension: 56),
            ),
          ),
        if (item.imageUrl != null) const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: AppTypography.accountProfileValue),
              if (item.variantTitle != null &&
                  item.variantTitle != 'Default Title')
                Text(item.variantTitle!, style: AppTypography.accountOrderMeta),
              Text(
                'Qty ${item.quantity}',
                style: AppTypography.accountOrderMeta,
              ),
            ],
          ),
        ),
        if (item.totalPrice != null)
          Text(
            _OrderDetailsBody._money(item.totalPrice!),
            style: AppTypography.accountOrderValue,
          ),
      ],
    );
  }
}

class _FulfillmentDetails extends StatelessWidget {
  const _FulfillmentDetails({required this.fulfillment});

  final CustomerOrderFulfillment fulfillment;

  @override
  Widget build(BuildContext context) {
    final status = fulfillment.latestShipmentStatus ?? fulfillment.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (status != null)
          Text(
            _OrderDetailsBody._humanize(status),
            style: AppTypography.accountProfileValue,
          ),
        for (final tracking in fulfillment.trackingInformation)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              [
                tracking.company,
                tracking.number,
              ].whereType<String>().join(' - '),
              style: AppTypography.accountAddressBody,
            ),
          ),
      ],
    );
  }
}

class _OrderError extends StatelessWidget {
  const _OrderError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.accountEmptyBody,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
