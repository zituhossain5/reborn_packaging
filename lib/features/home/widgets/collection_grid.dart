import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../models/collection_item.dart';
import 'collection_card.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({required this.items, this.onItemTap, super.key});

  final List<CollectionItem> items;
  final ValueChanged<CollectionItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final rowCount = (items.length / 2).ceil();

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CollectionCard(
                    item: items[rowIndex * 2],
                    onTap: onItemTap == null
                        ? null
                        : () => onItemTap!(items[rowIndex * 2]),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: rowIndex * 2 + 1 < items.length
                      ? CollectionCard(
                          item: items[rowIndex * 2 + 1],
                          onTap: onItemTap == null
                              ? null
                              : () => onItemTap!(items[rowIndex * 2 + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          if (rowIndex < rowCount - 1) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}
