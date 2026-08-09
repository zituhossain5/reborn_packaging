import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/state/mock_auth_controller.dart';
import '../../home/widgets/shop_bottom_navigation.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMockAuthenticated = ref.watch(mockAuthControllerProvider);
    if (!isMockAuthenticated) {
      return const LoginScreen();
    }

    return const Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: ShopBottomNavigation(
        activeItem: ShopNavigationItem.account,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Text('Signed in', style: AppTypography.loginTitle),
        ),
      ),
    );
  }
}
