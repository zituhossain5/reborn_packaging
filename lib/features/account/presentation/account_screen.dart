import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/state/customer_auth_controller.dart';
import '../../auth/state/post_login_intent.dart';
import '../../home/widgets/shop_bottom_navigation.dart';
import '../models/account_models.dart';
import '../state/customer_orders_provider.dart';
import '../state/customer_profile_provider.dart';
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
  bool _marketingIsUpdating = false;

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

    final customer = ref.watch(customerProfileProvider);
    if (customer.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: ShopBottomNavigation(),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (customer.hasError) {
      return Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: const ShopBottomNavigation(),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customer.error.toString(),
                    textAlign: TextAlign.center,
                    style: AppTypography.accountEmptyBody,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => ref.invalidate(customerProfileProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final profile = customer.requireValue;
    final accountUser = profile.toAccountUser();

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const ShopBottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AccountHeader(
              user: accountUser,
              selectedTab: _selectedTab,
              onTabChanged: (tab) => setState(() => _selectedTab = tab),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.backgroundLight,
                child: _selectedTab == _AccountTab.order
                    ? const _OrderBody()
                    : AccountProfile(
                        customer: profile,
                        marketingIsUpdating: _marketingIsUpdating,
                        onEditEmail: _showEmailEditingUnavailable,
                        onAddAddress: () => showAddressSheet(
                          context,
                          user: accountUser,
                          onSave: _createAddress,
                        ),
                        onEditAddress: (currentAddress) => showAddressSheet(
                          context,
                          user: accountUser,
                          address: currentAddress,
                          onSave: (address) =>
                              _updateAddress(currentAddress.id, address),
                        ),
                        onMarketingChanged: _updateMarketingPreference,
                        onSignOut: () async {
                          await ref
                              .read(customerAuthControllerProvider.notifier)
                              .signOut();
                          ref.invalidate(customerProfileProvider);
                          ref.invalidate(customerOrdersProvider);
                          ref
                              .read(pendingPostLoginIntentProvider.notifier)
                              .clear();
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

  Future<String?> _createAddress(CustomerAddressInput address) async {
    try {
      await ref.read(customerProfileProvider.notifier).createAddress(address);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> _updateAddress(
    String addressId,
    CustomerAddressInput address,
  ) async {
    try {
      await ref
          .read(customerProfileProvider.notifier)
          .updateAddress(addressId, address);
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> _updateMarketingPreference(bool subscribed) async {
    if (_marketingIsUpdating) return;
    setState(() => _marketingIsUpdating = true);
    try {
      await ref
          .read(customerProfileProvider.notifier)
          .setEmailMarketingSubscribed(subscribed);
    } catch (error) {
      if (mounted) _showProfileMessage(error.toString());
    } finally {
      if (mounted) setState(() => _marketingIsUpdating = false);
    }
  }

  void _showEmailEditingUnavailable() {
    _showProfileMessage(
      'Email changes are not supported by the current Shopify Customer '
      'Account API.',
    );
  }

  void _showProfileMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

class _OrderBody extends ConsumerWidget {
  const _OrderBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(customerOrdersProvider);
    return orders.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _OrdersError(
        message: error.toString(),
        onRetry: () => ref.invalidate(customerOrdersProvider),
      ),
      data: (data) {
        if (data.orders.isEmpty) return const _EmptyOrders();
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 240) {
              ref.read(customerOrdersProvider.notifier).loadMore();
            }
            return false;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              14,
              AppSpacing.md,
              AppSpacing.md,
            ),
            children: [
              const Text(
                'Recent orders',
                style: AppTypography.accountOrdersHeading,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (var index = 0; index < data.orders.length; index++) ...[
                AccountOrderCard(
                  order: data.orders[index],
                  onTap: () => context.push(
                    '/account/orders/details',
                    extra: data.orders[index].id,
                  ),
                ),
                if (index < data.orders.length - 1)
                  const SizedBox(height: AppSpacing.xs),
              ],
              if (data.isLoadingMore) ...[
                const SizedBox(height: AppSpacing.md),
                const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
              if (data.loadMoreError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () =>
                      ref.read(customerOrdersProvider.notifier).loadMore(),
                  child: const Text('Retry loading more orders'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.accountEmptyBody,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
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
