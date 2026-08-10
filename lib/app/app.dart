import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/cart/state/cart_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class RebornPackagingApp extends ConsumerWidget {
  const RebornPackagingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartControllerProvider);
    return MaterialApp.router(
      title: 'Reborn Packaging',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
