import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/product_details.dart';

class ProductFeatureItem extends StatelessWidget {
  const ProductFeatureItem({required this.feature, super.key});

  final ProductFeature feature;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight2,
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.xs)),
          ),
          child: SizedBox.square(
            dimension: 16.25,
            child: SvgPicture.asset('assets/icons/feature_check.svg'),
          ),
        ),
        const SizedBox(width: AppSpacing.compact),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feature.title, style: AppTypography.productFeatureTitle),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                feature.description,
                style: AppTypography.productFeatureBody,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
