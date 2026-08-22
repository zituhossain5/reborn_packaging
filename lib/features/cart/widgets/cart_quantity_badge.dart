import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class CartQuantityBadge extends StatefulWidget {
  const CartQuantityBadge({required this.quantity, super.key});

  final int quantity;

  @override
  State<CartQuantityBadge> createState() => _CartQuantityBadgeState();
}

class _CartQuantityBadgeState extends State<CartQuantityBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.2), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1), weight: 55),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(CartQuantityBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity > oldWidget.quantity) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quantity <= 0) {
      return const SizedBox.shrink();
    }

    final label = widget.quantity > 99 ? '99+' : '${widget.quantity}';

    return ScaleTransition(
      scale: _scale,
      child: Semantics(
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
      ),
    );
  }
}
