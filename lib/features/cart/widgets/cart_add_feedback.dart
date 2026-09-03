import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';

void showAddedToCartFeedback(BuildContext context) {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(milliseconds: 2500),
        content: const Text('Added to cart'),
        action: SnackBarAction(
          label: 'View cart',
          textColor: AppColors.white,
          onPressed: () {
            messenger.hideCurrentSnackBar();
            if (context.mounted) context.go('/cart');
          },
        ),
      ),
    );
}
