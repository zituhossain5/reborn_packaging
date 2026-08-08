import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class RebornPackagingApp extends StatelessWidget {
  const RebornPackagingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reborn Packaging',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
