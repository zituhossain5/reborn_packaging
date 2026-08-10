import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/models/cart_summary.dart';
import '../../cart/state/cart_controller.dart';

class CheckoutOrderSummary extends StatefulWidget {
  const CheckoutOrderSummary({
    required this.cart,
    required this.summary,
    super.key,
  });

  final CartState cart;
  final CartSummary summary;

  @override
  State<CheckoutOrderSummary> createState() => _CheckoutOrderSummaryState();
}

class _CheckoutOrderSummaryState extends State<CheckoutOrderSummary> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final itemLabel = widget.cart.itemCount == 1 ? 'item' : 'items';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            label: 'Toggle order summary',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 16,
                    child: SvgPicture.asset(
                      'assets/icons/checkout_bag.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Order summary (${widget.cart.itemCount} $itemLabel)',
                      style: AppTypography.checkoutSummaryLabel,
                    ),
                  ),
                  Text(
                    formatGbp(widget.summary.total),
                    style: AppTypography.checkoutSummaryTotal,
                  ),
                  const SizedBox(width: AppSpacing.compact),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: SizedBox.square(
                      dimension: 14,
                      child: SvgPicture.asset(
                        'assets/icons/checkout_chevron.svg',
                        colorFilter: const ColorFilter.mode(
                          AppColors.lightText,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Column(
                      children: [
                        const Divider(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: AppSpacing.sm),
                        for (
                          var index = 0;
                          index < widget.cart.items.length;
                          index++
                        ) ...[
                          _CheckoutProductRow(item: widget.cart.items[index]),
                          if (index < widget.cart.items.length - 1)
                            const SizedBox(height: AppSpacing.xs),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: AppSpacing.sm),
                        _SummaryRow(
                          label: 'Subtotal',
                          value: widget.summary.subtotal,
                        ),
                        if (widget.summary.discount > 0) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _SummaryRow(
                            label: 'Discount',
                            value: widget.summary.discount,
                            negative: true,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xs),
                        _SummaryRow(
                          label: 'Shipping',
                          value: widget.summary.shipping,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _SummaryRow(
                          label: 'Estimated taxes',
                          value: widget.summary.estimatedTaxes,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: AppSpacing.sm),
                        _SummaryRow(
                          label: 'Total',
                          value: widget.summary.total,
                          total: true,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CheckoutProductRow extends StatelessWidget {
  const _CheckoutProductRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(
          dimension: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: item.imageAsset.startsWith('http')
                    ? Image.network(item.imageAsset, fit: BoxFit.cover)
                    : item.imageAsset.isNotEmpty
                    ? Image.asset(item.imageAsset, fit: BoxFit.cover)
                    : const SizedBox.shrink(),
              ),
              Positioned(
                right: -4,
                top: -5,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: AppTypography.navigationBadge,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.compact),
        Expanded(
          child: Text(
            item.productTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.checkoutProduct,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          formatGbp(item.linePrice),
          style: AppTypography.checkoutProduct.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.negative = false,
    this.total = false,
  });

  final String label;
  final double value;
  final bool negative;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final style = total
        ? AppTypography.checkoutSummaryRow.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          )
        : AppTypography.checkoutSummaryRow;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          '${negative ? '-' : ''}${formatGbp(value)}',
          style: style.copyWith(
            color: total ? AppColors.primary : AppColors.black,
          ),
        ),
      ],
    );
  }
}
