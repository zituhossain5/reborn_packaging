import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    required this.quantity,
    required this.totalUnits,
    required this.canDecrease,
    required this.onDecrease,
    required this.onIncrease,
    super.key,
  });

  final int quantity;
  final int totalUnits;
  final bool canDecrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 272,
      height: 42,
      child: Row(
        children: [
          Container(
            width: 132,
            height: 42,
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuantityButton(
                  semanticLabel: 'Decrease quantity',
                  assetPath: 'assets/icons/quantity_minus.svg',
                  enabled: canDecrease,
                  onTap: onDecrease,
                  isMinus: true,
                ),
                Text('$quantity', style: AppTypography.quantityValue),
                _QuantityButton(
                  semanticLabel: 'Increase quantity',
                  assetPath: 'assets/icons/quantity_plus.svg',
                  enabled: true,
                  onTap: onIncrease,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.compact),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total quantity',
                  maxLines: 1,
                  style: AppTypography.quantityCaption,
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalUnits units',
                  maxLines: 1,
                  style: AppTypography.quantityValue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.semanticLabel,
    required this.assetPath,
    required this.enabled,
    required this.onTap,
    this.isMinus = false,
  });

  final String semanticLabel;
  final String assetPath;
  final bool enabled;
  final VoidCallback onTap;
  final bool isMinus;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight2,
            borderRadius: BorderRadius.circular(5),
          ),
          child: SizedBox(
            width: 12.5,
            height: isMinus ? 1.5 : 12.5,
            child: SvgPicture.asset(assetPath),
          ),
        ),
      ),
    );
  }
}
