import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';

class CollectionSectionHeader extends StatelessWidget {
  const CollectionSectionHeader({required this.collectionCount, super.key});

  final int collectionCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'PRODUCT COLLECTIONS',
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: AppTypography.collectionSectionTitle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$collectionCount collections',
          maxLines: 1,
          textAlign: TextAlign.right,
          style: AppTypography.collectionCount,
        ),
      ],
    );
  }
}
