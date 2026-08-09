import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/account_models.dart';

class AccountOrderCard extends StatelessWidget {
  const AccountOrderCard({required this.order, super.key});

  final AccountOrder order;

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == AccountOrderStatus.pending;
    final statusColor = isPending ? AppColors.shippingAccent : AppColors.stock;
    final statusBackground = isPending
        ? AppColors.accountStatusPendingBackground
        : AppColors.accountStatusDeliveredBackground;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.number, style: AppTypography.accountOrderValue),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.tiny),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      order.statusLabel,
                      style: AppTypography.accountOrderStatus.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text(order.dateLabel, style: AppTypography.accountOrderMeta),
                const SizedBox(width: AppSpacing.tiny),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.lightText,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(dimension: 3),
                ),
                const SizedBox(width: AppSpacing.tiny),
                Text(
                  order.itemCountLabel,
                  style: AppTypography.accountOrderMeta,
                ),
                const Spacer(),
                Text(
                  '£${order.total.toStringAsFixed(2)}',
                  style: AppTypography.accountOrderValue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
