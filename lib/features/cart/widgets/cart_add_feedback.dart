import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';

Timer? _addedToCartDismissTimer;
Object? _activeAddedToCartToken;

void showAddedToCartFeedback(BuildContext context) {
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final token = Object();
  _activeAddedToCartToken = token;
  _addedToCartDismissTimer?.cancel();

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
            _addedToCartDismissTimer?.cancel();
            _addedToCartDismissTimer = null;
            _activeAddedToCartToken = null;
            messenger.hideCurrentSnackBar();
            if (context.mounted) context.go('/cart');
          },
        ),
      ),
    );

  _addedToCartDismissTimer = Timer(const Duration(milliseconds: 2500), () {
    if (!identical(_activeAddedToCartToken, token)) return;
    _activeAddedToCartToken = null;
    _addedToCartDismissTimer = null;
    if (messenger.mounted) {
      messenger.hideCurrentSnackBar();
    }
  });
}
