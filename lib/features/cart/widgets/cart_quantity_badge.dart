import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class CartQuantityBadge extends StatelessWidget {
  const CartQuantityBadge({required this.quantity, super.key});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    if (quantity <= 0) {
      return const SizedBox.shrink();
    }

    final label = quantity > 99 ? '99+' : '$quantity';

    return Semantics(
      container: true,
      label: 'Cart quantity $label',
      child: Container(
        key: const ValueKey('cart_quantity_badge'),
        height: 16,
        constraints: const BoxConstraints(minWidth: 16),
        padding: EdgeInsets.symmetric(horizontal: label.length > 1 ? 3 : 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          border: Border.all(color: AppColors.white, width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: AppTypography.navigationBadge,
        ),
      ),
    );
  }
}
