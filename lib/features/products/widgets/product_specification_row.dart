import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/product_details.dart';

class ProductSpecificationRow extends StatelessWidget {
  const ProductSpecificationRow({required this.specification, super.key});

  final ProductSpecification specification;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 94,
          child: Text(
            specification.label,
            style: AppTypography.productSpecificationLabel,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            specification.value,
            style: AppTypography.productSpecificationValue,
          ),
        ),
      ],
    );
  }
}
