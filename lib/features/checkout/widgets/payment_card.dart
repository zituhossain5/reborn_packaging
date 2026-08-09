import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../providers/checkout_provider.dart';

class PaymentCard extends ConsumerWidget {
  const PaymentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(
      checkoutProvider.select((state) => state.selectedPaymentMethod),
    );
    final controller = ref.read(checkoutProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment', style: AppTypography.checkoutSectionTitle),
          const SizedBox(height: AppSpacing.tiny),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/payment_shield.svg',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: AppSpacing.tiny),
              const Expanded(
                child: Text(
                  'All transactions are secure and encrypted.',
                  maxLines: 1,
                  style: AppTypography.paymentSecurity,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _CreditCardMethod(
            selected: selectedMethod == PaymentMethod.creditCard,
            onTap: () => controller.setPaymentMethod(PaymentMethod.creditCard),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PayPalMethod(
            selected: selectedMethod == PaymentMethod.paypal,
            onTap: () => controller.setPaymentMethod(PaymentMethod.paypal),
          ),
        ],
      ),
    );
  }
}

class _CreditCardMethod extends StatelessWidget {
  const _CreditCardMethod({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PaymentMethodContainer(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              _PaymentRadio(selected: selected),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: Text(
                  'Credit card',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.paymentMethod,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const _CardBrands(),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: selected
                ? const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.md),
                    child: _CardFields(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PayPalMethod extends StatelessWidget {
  const _PayPalMethod({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PaymentMethodContainer(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PaymentRadio(selected: selected),
              const SizedBox(width: AppSpacing.xs),
              const Text('PayPal', style: AppTypography.paymentMethod),
              const Spacer(),
              SvgPicture.asset(
                'assets/icons/payment_paypal.svg',
                width: 50,
                height: 14,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: selected
                ? const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      "You'll be redirected to PayPal to complete your purchase",
                      style: AppTypography.paymentDescription,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodContainer extends StatelessWidget {
  const _PaymentMethodContainer({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PaymentRadio extends StatelessWidget {
  const _PaymentRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.lightText,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _CardBrands extends StatelessWidget {
  const _CardBrands();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/icons/payment_visa.png', width: 28, height: 18),
        const SizedBox(width: AppSpacing.xxs),
        Image.asset('assets/icons/payment_maestro.png', width: 29, height: 18),
        const SizedBox(width: AppSpacing.xxs),
        Image.asset(
          'assets/icons/payment_mastercard.png',
          width: 28,
          height: 18,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Container(
          height: 18,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight2,
            borderRadius: BorderRadius.circular(AppSpacing.xxs),
          ),
          child: const Text('+5', style: AppTypography.paymentMore),
        ),
      ],
    );
  }
}

class _CardFields extends StatelessWidget {
  const _CardFields();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PaymentField(
          fieldKey: ValueKey('payment_card_number'),
          hint: 'Card number',
          keyboardType: TextInputType.number,
          digitsOnly: true,
          suffixAsset: 'assets/icons/payment_card_arrow.svg',
        ),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          children: [
            Expanded(
              child: _PaymentField(
                fieldKey: ValueKey('payment_expiry'),
                hint: 'MM / YY',
                keyboardType: TextInputType.datetime,
              ),
            ),
            SizedBox(width: AppSpacing.compact),
            Expanded(
              child: _PaymentField(
                fieldKey: ValueKey('payment_cvv'),
                hint: 'CVV',
                keyboardType: TextInputType.number,
                digitsOnly: true,
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const _PaymentField(
          fieldKey: ValueKey('payment_card_name'),
          hint: 'Name on card',
          keyboardType: TextInputType.name,
          capitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}

class _PaymentField extends StatelessWidget {
  const _PaymentField({
    required this.fieldKey,
    required this.hint,
    required this.keyboardType,
    this.digitsOnly = false,
    this.suffixAsset,
    this.obscureText = false,
    this.capitalization = TextCapitalization.none,
  });

  final Key fieldKey;
  final String hint;
  final TextInputType keyboardType;
  final bool digitsOnly;
  final String? suffixAsset;
  final bool obscureText;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        key: fieldKey,
        keyboardType: keyboardType,
        inputFormatters: digitsOnly
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null,
        obscureText: obscureText,
        textCapitalization: capitalization,
        enableSuggestions: false,
        autocorrect: false,
        style: AppTypography.checkoutInput,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.checkoutHint,
          isDense: true,
          contentPadding: const EdgeInsets.all(AppSpacing.sm),
          suffixIconConstraints: const BoxConstraints.tightFor(
            width: 38,
            height: 40,
          ),
          suffixIcon: suffixAsset == null
              ? null
              : Center(
                  child: SvgPicture.asset(suffixAsset!, width: 10, height: 6),
                ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderLight),
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.xs)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.xs)),
          ),
        ),
      ),
    );
  }
}
