import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/money_formatter.dart';
import '../providers/checkout_provider.dart';

class ContactFormCard extends ConsumerWidget {
  const ContactFormCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);
    final controller = ref.read(checkoutProvider.notifier);
    return CheckoutCard(
      title: 'Contact',
      child: Column(
        children: [
          TextFormField(
            key: const ValueKey('checkout_contact'),
            initialValue: checkout.contact,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: controller.setContact,
            validator: requiredField,
            style: AppTypography.checkoutInput,
            decoration: checkoutInputDecoration('Email or mobile number'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SizedBox.square(
                dimension: 16,
                child: Checkbox(
                  value: checkout.acceptsMarketing,
                  onChanged: (value) =>
                      controller.setAcceptsMarketing(value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(color: AppColors.lightText),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: Text(
                  'Email me with news and offers',
                  style: AppTypography.checkoutCheckbox,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DeliveryAddressFormCard extends ConsumerWidget {
  const DeliveryAddressFormCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);
    final controller = ref.read(checkoutProvider.notifier);
    return CheckoutCard(
      title: 'Delivery address',
      child: Column(
        children: [
          LabeledCheckoutField(
            label: 'Country / Region',
            child: DropdownButtonFormField<String>(
              key: const ValueKey('checkout_country'),
              initialValue: checkout.country,
              items: const [
                DropdownMenuItem(
                  value: 'United Kingdom',
                  child: Text('United Kingdom'),
                ),
              ],
              onChanged: (value) {
                if (value != null) controller.setCountry(value);
              },
              validator: requiredField,
              style: AppTypography.checkoutInput,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: AppColors.lightText,
              ),
              decoration: checkoutInputDecoration(null),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledCheckoutField(
            label: 'First name (optional)',
            child: CheckoutTextField(
              fieldKey: const ValueKey('checkout_first_name'),
              initialValue: checkout.firstName,
              hint: 'First name',
              action: TextInputAction.next,
              onChanged: controller.setFirstName,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledCheckoutField(
            label: 'Last name',
            child: CheckoutTextField(
              fieldKey: const ValueKey('checkout_last_name'),
              initialValue: checkout.lastName,
              hint: 'Last name',
              action: TextInputAction.next,
              onChanged: controller.setLastName,
              isRequired: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledCheckoutField(
            label: 'Address',
            child: Column(
              children: [
                CheckoutTextField(
                  fieldKey: const ValueKey('checkout_address'),
                  initialValue: checkout.address,
                  hint: 'Address',
                  action: TextInputAction.next,
                  onChanged: controller.setAddress,
                  isRequired: true,
                ),
                const SizedBox(height: AppSpacing.xs),
                CheckoutTextField(
                  fieldKey: const ValueKey('checkout_apartment'),
                  initialValue: checkout.apartment,
                  hint: 'Apartment, suite, etc. (optional)',
                  action: TextInputAction.next,
                  onChanged: controller.setApartment,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledCheckoutField(
            label: 'City',
            child: CheckoutTextField(
              fieldKey: const ValueKey('checkout_city'),
              initialValue: checkout.city,
              hint: 'City',
              action: TextInputAction.next,
              onChanged: controller.setCity,
              isRequired: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledCheckoutField(
            label: 'Postcode',
            child: CheckoutTextField(
              fieldKey: const ValueKey('checkout_postcode'),
              initialValue: checkout.postcode,
              hint: 'Postcode',
              action: TextInputAction.done,
              capitalization: TextCapitalization.characters,
              onChanged: controller.setPostcode,
              isRequired: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ShippingMethodCard extends StatelessWidget {
  const ShippingMethodCard({required this.shipping, super.key});

  final double shipping;

  @override
  Widget build(BuildContext context) {
    return CheckoutCard(
      title: 'Shipping method',
      gap: AppSpacing.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Standard delivery', style: AppTypography.checkoutInput),
                  SizedBox(height: 2),
                  Text(
                    '2 to 4 business days',
                    style: AppTypography.checkoutCheckbox,
                  ),
                ],
              ),
            ),
            Text(formatGbp(shipping), style: AppTypography.checkoutInput),
          ],
        ),
      ),
    );
  }
}

class CheckoutCard extends StatelessWidget {
  const CheckoutCard({
    required this.title,
    required this.child,
    this.gap = AppSpacing.md,
    super.key,
  });

  final String title;
  final Widget child;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.checkoutSectionTitle),
          SizedBox(height: gap),
          child,
        ],
      ),
    );
  }
}

class LabeledCheckoutField extends StatelessWidget {
  const LabeledCheckoutField({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.checkoutInputLabel),
        const SizedBox(height: AppSpacing.tiny),
        child,
      ],
    );
  }
}

class CheckoutTextField extends StatelessWidget {
  const CheckoutTextField({
    required this.fieldKey,
    required this.initialValue,
    required this.hint,
    required this.action,
    required this.onChanged,
    this.isRequired = false,
    this.capitalization = TextCapitalization.none,
    super.key,
  });

  final Key fieldKey;
  final String initialValue;
  final String hint;
  final TextInputAction action;
  final ValueChanged<String> onChanged;
  final bool isRequired;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      initialValue: initialValue,
      textInputAction: action,
      textCapitalization: capitalization,
      onChanged: onChanged,
      validator: isRequired ? requiredField : null,
      style: AppTypography.checkoutInput,
      decoration: checkoutInputDecoration(hint),
    );
  }
}

InputDecoration checkoutInputDecoration(String? hint) {
  const border = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.borderLight),
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.xs)),
  );
  return const InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppColors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: 10,
    ),
    hintStyle: AppTypography.checkoutHint,
    enabledBorder: border,
    focusedBorder: border,
    errorBorder: border,
    focusedErrorBorder: border,
    errorStyle: TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 10,
      height: 1.2,
    ),
  ).copyWith(hintText: hint);
}

String? requiredField(String? value) {
  return value == null || value.trim().isEmpty ? 'Required' : null;
}
