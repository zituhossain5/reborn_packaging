import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({required this.currentStep, super.key});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Step(number: 1, label: 'DELIVERY', reached: currentStep >= 1),
            Expanded(child: _Connector(reached: currentStep >= 2)),
            _Step(number: 2, label: 'PAYMENT', reached: currentStep >= 2),
            Expanded(child: _Connector(reached: currentStep >= 3)),
            _Step(number: 3, label: 'CONFIRM', reached: currentStep >= 3),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.reached,
  });

  final int number;
  final String label;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: reached ? AppColors.primary : AppColors.lightText,
              shape: BoxShape.circle,
            ),
            child: Text('$number', style: AppTypography.checkoutStepNumber),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            style: reached
                ? AppTypography.checkoutStepActive
                : AppTypography.checkoutStepInactive,
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.reached});

  final bool reached;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: reached ? AppColors.primary : AppColors.borderLight,
      ),
    );
  }
}
