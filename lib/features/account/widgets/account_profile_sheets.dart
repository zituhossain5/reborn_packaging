import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../models/account_models.dart';

Future<void> showAddressSheet(
  BuildContext context, {
  required AccountUser user,
  required Future<String?> Function(CustomerAddressInput address) onSave,
  CustomerAddress? address,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close address form',
    barrierColor: const Color(0xB3000000),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _BlurredSheetFrame(
        child: _AddressSheet(user: user, address: address, onSave: onSave),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}

class _BlurredSheetFrame extends StatelessWidget {
  const _BlurredSheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Material(
        color: Colors.transparent,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Align(alignment: Alignment.bottomCenter, child: child),
        ),
      ),
    );
  }
}

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({
    required this.user,
    required this.address,
    required this.onSave,
  });

  final AccountUser user;
  final CustomerAddress? address;
  final Future<String?> Function(CustomerAddressInput address) onSave;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  static const _countries = <String, String>{
    'United Kingdom': 'GB',
    'United States': 'US',
    'Canada': 'CA',
    'Australia': 'AU',
    'Bangladesh': 'BD',
    'India': 'IN',
    'Ireland': 'IE',
    'France': 'FR',
    'Germany': 'DE',
    'Spain': 'ES',
    'Italy': 'IT',
    'Netherlands': 'NL',
    'Belgium': 'BE',
    'UAE': 'AE',
  };

  late final TextEditingController _country;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _address1;
  late final TextEditingController _address2;
  late final TextEditingController _city;
  late final TextEditingController _postcode;
  late String _territoryCode;
  final Map<String, String> _errors = {};
  String? _submissionError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    final nameParts = widget.user.name.split(' ');
    _country = TextEditingController(
      text: address?.country ?? 'United Kingdom',
    );
    _territoryCode = address?.territoryCode.isNotEmpty == true
        ? address!.territoryCode
        : 'GB';
    _firstName = TextEditingController(
      text: address?.firstName ?? (nameParts.isEmpty ? '' : nameParts.first),
    );
    _lastName = TextEditingController(
      text: address?.lastName ?? (nameParts.length > 1 ? nameParts.last : ''),
    );
    _address1 = TextEditingController(text: address?.address1 ?? '');
    _address2 = TextEditingController(text: address?.address2 ?? '');
    _city = TextEditingController(text: address?.city ?? '');
    _postcode = TextEditingController(text: address?.postcode ?? '');
  }

  @override
  void dispose() {
    for (final controller in [
      _country,
      _firstName,
      _lastName,
      _address1,
      _address2,
      _city,
      _postcode,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final requiredFields = <String, TextEditingController>{
      'country': _country,
      'lastName': _lastName,
      'address1': _address1,
      'city': _city,
      'postcode': _postcode,
    };
    final errors = <String, String>{};
    for (final entry in requiredFields.entries) {
      if (entry.value.text.trim().isEmpty) {
        errors[entry.key] = 'Required';
      }
    }
    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(errors);
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _submissionError = null;
    });
    final error = await widget.onSave(
      CustomerAddressInput(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        address1: _address1.text.trim(),
        address2: _address2.text.trim(),
        city: _city.text.trim(),
        postcode: _postcode.text.trim(),
        territoryCode: _territoryCode,
        zoneCode: widget.address?.zoneCode ?? '',
        phoneNumber: widget.address?.phoneNumber ?? '',
      ),
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSaving = false;
      _submissionError = error;
    });
  }

  void _clearError(String key) {
    if (_errors.containsKey(key)) {
      setState(() => _errors.remove(key));
    }
  }

  Future<void> _selectCountry() async {
    final selectedCountry = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: _countries.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final country = _countries.keys.elementAt(index);
              final isSelected = country == _country.text;
              return ListTile(
                title: Text(country, style: AppTypography.accountSheetInput),
                trailing: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(country),
              );
            },
          ),
        );
      },
    );

    if (selectedCountry == null || selectedCountry == _country.text) return;
    setState(() {
      _country.text = selectedCountry;
      _territoryCode = _countries[selectedCountry] ?? 'GB';
      _errors.remove('country');
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        MediaQuery.viewPaddingOf(context).top;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: availableHeight.clamp(0, 579)),
      child: _SheetSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHeader(
              title: widget.address == null ? 'Add address' : 'Edit address',
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    _CountryRegionSelector(
                      label: 'Country / Region',
                      value: _country.text,
                      onTap: _selectCountry,
                      errorText: _errors['country'],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _SheetField(
                            label: 'First name (optional)',
                            labelStyle: AppTypography.accountSheetSplitLabel,
                            controller: _firstName,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SheetField(
                            label: 'Last name',
                            labelStyle: AppTypography.accountSheetSplitLabel,
                            controller: _lastName,
                            textInputAction: TextInputAction.next,
                            errorText: _errors['lastName'],
                            onChanged: (_) => _clearError('lastName'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SheetField(
                      label: 'Address',
                      controller: _address1,
                      hintText: 'Address',
                      textInputAction: TextInputAction.next,
                      errorText: _errors['address1'],
                      onChanged: (_) => _clearError('address1'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SheetField(
                      controller: _address2,
                      hintText: 'Apartment, suite, etc. (optional)',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SheetField(
                      label: 'City',
                      controller: _city,
                      hintText: 'City',
                      textInputAction: TextInputAction.next,
                      errorText: _errors['city'],
                      onChanged: (_) => _clearError('city'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SheetField(
                      label: 'Postcode',
                      controller: _postcode,
                      hintText: 'Postcode',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _save(),
                      errorText: _errors['postcode'],
                      onChanged: (_) => _clearError('postcode'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_submissionError != null) ...[
              Text(
                _submissionError!,
                style: AppTypography.accountProfileCaption.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            _SheetActions(
              onCancel: _isSaving ? null : () => Navigator.of(context).pop(),
              onSave: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryRegionSelector extends StatelessWidget {
  const _CountryRegionSelector({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.accountSheetLabel),
        const SizedBox(height: AppSpacing.tiny),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            onTap: onTap,
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(
                  color: errorText == null
                      ? AppColors.borderLight
                      : Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.accountSheetInput,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox.square(
                    dimension: 14,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/profile_country_chevron.svg',
                        width: 9.63,
                        height: 5.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            errorText!,
            style: AppTypography.accountProfileCaption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: child,
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.accountSheetTitle),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: SizedBox.square(
            dimension: 20,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/profile_sheet_close.svg',
                width: 12.5,
                height: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    this.label,
    this.labelStyle,
    this.hintText,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final String? label;
  final TextStyle? labelStyle;
  final String? hintText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(label!, style: labelStyle ?? AppTypography.accountSheetLabel),
          const SizedBox(height: AppSpacing.tiny),
        ],
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            style: AppTypography.accountSheetInput,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.accountSheetHint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              enabledBorder: _border(AppColors.borderLight),
              focusedBorder: _border(AppColors.primary),
              errorBorder: _border(Theme.of(context).colorScheme.error),
              focusedErrorBorder: _border(Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            errorText!,
            style: AppTypography.accountProfileCaption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      borderSide: BorderSide(color: color),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({required this.onCancel, required this.onSave});

  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
              child: const Text(
                'Cancel',
                style: AppTypography.accountSheetButton,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: SizedBox(
            height: 46,
            child: FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
              child: const Text(
                'Save',
                style: AppTypography.accountSheetPrimaryButton,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
