import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/account_models.dart';

class AccountProfile extends StatelessWidget {
  const AccountProfile({
    required this.account,
    required this.onMarketingChanged,
    required this.onEditEmail,
    required this.onAddAddress,
    required this.onEditAddress,
    required this.onSignOut,
    super.key,
  });

  final MockAccountState account;
  final ValueChanged<bool> onMarketingChanged;
  final VoidCallback onEditEmail;
  final VoidCallback onAddAddress;
  final ValueChanged<CustomerAddress> onEditAddress;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            20,
            AppSpacing.md,
            0,
          ),
          sliver: SliverList.list(
            children: [
              _ContactSection(email: account.user.email, onEdit: onEditEmail),
              const SizedBox(height: 20),
              _AddressSection(
                addresses: account.addresses,
                onAdd: onAddAddress,
                onEdit: onEditAddress,
              ),
              const SizedBox(height: 20),
              _MarketingSection(
                enabled: account.marketingEmailsEnabled,
                onChanged: onMarketingChanged,
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              20,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: onSignOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accountDanger,
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.compact,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 20,
                        child: SvgPicture.asset(
                          'assets/icons/profile_sign_out.svg',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.compact),
                      const Text(
                        'Sign out',
                        style: AppTypography.accountSignOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.email, required this.onEdit});

  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'CONTACT',
      child: _ProfileCard(
        icon: const _ProfileIcon(assetPath: 'assets/icons/profile_email.svg'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email', style: AppTypography.accountProfileCaption),
            const SizedBox(height: 2),
            Text(email, style: AppTypography.accountProfileValue),
          ],
        ),
        action: _ProfileAction(label: 'Edit', onTap: onEdit),
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({
    required this.addresses,
    required this.onAdd,
    required this.onEdit,
  });

  final List<CustomerAddress> addresses;
  final VoidCallback onAdd;
  final ValueChanged<CustomerAddress> onEdit;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'ADDRESSES',
      trailing: addresses.isEmpty
          ? null
          : _ProfileAction(
              label: 'Add',
              leadingAsset: 'assets/icons/profile_add.svg',
              onTap: onAdd,
            ),
      child: addresses.isEmpty
          ? _ProfileCard(
              icon: const _LocationIcon(),
              content: const Text(
                'No addresses added',
                style: AppTypography.accountProfileCaption,
              ),
              action: _ProfileAction(
                label: 'Add',
                leadingAsset: 'assets/icons/profile_add.svg',
                onTap: onAdd,
              ),
            )
          : Column(
              children: [
                for (var index = 0; index < addresses.length; index++) ...[
                  _AddressCard(
                    address: addresses[index],
                    onEdit: () => onEdit(addresses[index]),
                  ),
                  if (index < addresses.length - 1)
                    const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onEdit});

  final CustomerAddress address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final apartment = address.address2.isEmpty ? '' : '${address.address2}, ';
    return _ProfileCard(
      icon: const _LocationIcon(),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.recipientName, style: AppTypography.accountAddressName),
          const SizedBox(height: 2),
          Text(
            '${address.address1} $apartment${address.city}, '
            '${address.postcode},\n${address.country}',
            style: AppTypography.accountAddressBody,
          ),
        ],
      ),
      action: _ProfileAction(label: 'Edit', onTap: onEdit),
    );
  }
}

class _MarketingSection extends StatelessWidget {
  const _MarketingSection({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'MARKETING PREFERENCES',
      child: _ProfileCard(
        icon: const _ProfileIcon(assetPath: 'assets/icons/profile_bell.svg'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email notifications',
              style: AppTypography.accountProfileValue,
            ),
            SizedBox(height: 2),
            Text(
              'News, offers and updates',
              style: AppTypography.accountProfileCaption,
            ),
          ],
        ),
        action: _MarketingToggle(enabled: enabled, onChanged: onChanged),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.accountSectionLabel),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.content,
    required this.action,
  });

  final Widget icon;
  final Widget content;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.compact),
            Expanded(child: content),
            const SizedBox(width: AppSpacing.xs),
            action,
          ],
        ),
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight2,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: SvgPicture.asset(assetPath),
    );
  }
}

class _LocationIcon extends StatelessWidget {
  const _LocationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight2,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 9.87,
            top: 9.04,
            width: 16.26,
            height: 17.92,
            child: SvgPicture.asset('assets/icons/profile_location.svg'),
          ),
          Positioned(
            left: 14.46,
            top: 13.63,
            width: 7.08,
            height: 7.08,
            child: SvgPicture.asset('assets/icons/profile_location_center.svg'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.label,
    required this.onTap,
    this.leadingAsset,
  });

  final String label;
  final VoidCallback onTap;
  final String? leadingAsset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppSpacing.tiny),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingAsset != null) ...[
              SizedBox.square(
                dimension: AppSpacing.sm,
                child: SvgPicture.asset(leadingAsset!),
              ),
              const SizedBox(width: AppSpacing.tiny),
            ],
            Text(label, style: AppTypography.accountProfileAction),
          ],
        ),
      ),
    );
  }
}

class _MarketingToggle extends StatelessWidget {
  const _MarketingToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: enabled,
      label: 'Email notifications',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!enabled),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 42,
          height: 24,
          padding: const EdgeInsets.all(AppSpacing.xxs),
          alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: enabled ? AppColors.stock : AppColors.accountToggleOff,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A101828),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
                BoxShadow(
                  color: Color(0x0F101828),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: SizedBox.square(dimension: 16),
          ),
        ),
      ),
    );
  }
}
