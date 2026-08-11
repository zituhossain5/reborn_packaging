import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/state/customer_auth_controller.dart';
import '../../home/widgets/shop_bottom_navigation.dart';
import '../models/account_models.dart';
import '../state/mock_account_state.dart';
import '../widgets/account_profile.dart';
import '../widgets/account_profile_sheets.dart';
import '../widgets/account_order_card.dart';

enum _AccountTab { order, profile }

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  _AccountTab _selectedTab = _AccountTab.order;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(customerAuthControllerProvider);
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: ShopBottomNavigation(),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.value == null) {
      return const LoginScreen();
    }

    final account = ref.watch(mockAccountStateProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const ShopBottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AccountHeader(
              user: account.user,
              selectedTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.backgroundLight,
                child: _selectedTab == _AccountTab.order
                    ? _OrderBody(orders: account.orders)
                    : AccountProfile(
                        account: account,
                        onEditEmail: () async {
                          final email = await showEditEmailSheet(
                            context,
                            currentEmail: account.user.email,
                          );
                          if (email != null && mounted) {
                            ref
                                .read(mockAccountStateProvider.notifier)
                                .updateEmail(email);
                          }
                        },
                        onAddAddress: () async {
                          final address = await showAddressSheet(
                            context,
                            user: account.user,
                          );
                          if (address != null && mounted) {
                            ref
                                .read(mockAccountStateProvider.notifier)
                                .addAddress(address);
                          }
                        },
                        onEditAddress: (currentAddress) async {
                          final address = await showAddressSheet(
                            context,
                            user: account.user,
                            address: currentAddress,
                          );
                          if (address != null && mounted) {
                            ref
                                .read(mockAccountStateProvider.notifier)
                                .updateAddress(address);
                          }
                        },
                        onMarketingChanged: (value) => ref
                            .read(mockAccountStateProvider.notifier)
                            .setMarketingEmailsEnabled(value),
                        onSignOut: () async {
                          ref
                              .read(mockAccountStateProvider.notifier)
                              .resetSession();
                          await ref
                              .read(customerAuthControllerProvider.notifier)
                              .signOut();
                          if (!context.mounted) return;
                          context.go('/login');
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.user,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final AccountUser user;
  final _AccountTab selectedTab;
  final ValueChanged<_AccountTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    user.initials,
                    style: AppTypography.accountAvatar,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: AppTypography.accountName),
                    const SizedBox(height: 2),
                    Text(user.email, style: AppTypography.accountEmail),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.tiny),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _AccountTabButton(
                      label: 'Orders',
                      selected: selectedTab == _AccountTab.order,
                      onTap: () => onTabChanged(_AccountTab.order),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.tiny),
                  Expanded(
                    child: _AccountTabButton(
                      label: 'Profile',
                      selected: selectedTab == _AccountTab.profile,
                      onTap: () => onTabChanged(_AccountTab.profile),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTabButton extends StatelessWidget {
  const _AccountTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.backgroundLight2,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: Text(
            label,
            style: selected
                ? AppTypography.accountTabActive
                : AppTypography.accountTabInactive,
          ),
        ),
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.orders});

  final List<AccountOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyOrders();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        14,
        AppSpacing.md,
        AppSpacing.md,
      ),
      children: [
        const Text('Recent orders', style: AppTypography.accountOrdersHeading),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < orders.length; index++) ...[
          AccountOrderCard(order: orders[index]),
          if (index < orders.length - 1) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _EmptyOrderIcon(),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'No orders yet',
                textAlign: TextAlign.center,
                style: AppTypography.accountEmptyTitle,
              ),
              const SizedBox(height: AppSpacing.xxs),
              const SizedBox(
                width: 271,
                child: Text(
                  'Once you place an order, it will appear here for easy tracking.',
                  textAlign: TextAlign.center,
                  style: AppTypography.accountEmptyBody,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () => context.go('/home'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.compact,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                  ),
                  child: const Text(
                    'Shop now',
                    style: AppTypography.accountShopButton,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrderIcon extends StatelessWidget {
  const _EmptyOrderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.accountStatusDeliveredBackground,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 27,
            top: 29.67,
            width: 26,
            height: 24.66,
            child: SvgPicture.asset('assets/icons/empty_order_package.svg'),
          ),
          Positioned(
            left: 36.33,
            top: 25.67,
            width: 7.34,
            height: 11.34,
            child: SvgPicture.asset('assets/icons/empty_order_receive.svg'),
          ),
        ],
      ),
    );
  }
}
