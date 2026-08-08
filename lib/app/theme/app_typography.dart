import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const textTheme = TextTheme(
    titleLarge: TextStyle(
      color: AppColors.primary,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
  );
}
