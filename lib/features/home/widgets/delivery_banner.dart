import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class DeliveryBanner extends StatelessWidget {
  const DeliveryBanner({super.key});

  static const _height = 38.0;
  static const _iconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary15,
      child: SizedBox(
        height: _height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              SizedBox.square(
                dimension: _iconSize,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(1.125, 3.938, 0, 2.246),
                  child: SvgPicture.asset(
                    'assets/icons/delivery_truck.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'FREE NEXT DAY DELIVERY ON ORDERS OVER \u00A3100',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: AppTypography.deliveryBanner,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
