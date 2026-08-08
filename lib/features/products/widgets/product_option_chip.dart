import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class ProductOptionChip extends StatelessWidget {
  const ProductOptionChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = !enabled
        ? AppColors.borderLight
        : selected
        ? AppColors.black
        : AppColors.secondaryText;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.backgroundLight2 : AppColors.white,
            border: Border.all(
              color: selected ? AppColors.black : AppColors.borderLight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              maxLines: 1,
              style: AppTypography.productOption.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
