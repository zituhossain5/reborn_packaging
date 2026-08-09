import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../home/widgets/shop_bottom_navigation.dart';
import '../state/mock_auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _emailController = TextEditingController();
  bool _acceptsMarketing = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _signInWithEmail() {
    final email = _emailController.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email address.');
      return;
    }

    _completeMockSignIn();
  }

  void _completeMockSignIn() {
    ref.read(mockAuthControllerProvider.notifier).signIn();
    context.go('/account');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: const ShopBottomNavigation(
        activeItem: ShopNavigationItem.account,
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _LoginContent(
                      emailController: _emailController,
                      emailError: _emailError,
                      acceptsMarketing: _acceptsMarketing,
                      onEmailChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                      onMarketingChanged: (value) {
                        setState(() => _acceptsMarketing = value);
                      },
                      onShopPressed: _completeMockSignIn,
                      onSignInPressed: _signInWithEmail,
                    ),
                    const SizedBox(height: 58),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent({
    required this.emailController,
    required this.emailError,
    required this.acceptsMarketing,
    required this.onEmailChanged,
    required this.onMarketingChanged,
    required this.onShopPressed,
    required this.onSignInPressed,
  });

  final TextEditingController emailController;
  final String? emailError;
  final bool acceptsMarketing;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<bool> onMarketingChanged;
  final VoidCallback onShopPressed;
  final VoidCallback onSignInPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 343,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              'assets/images/reborn_logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sign in',
            textAlign: TextAlign.center,
            style: AppTypography.loginTitle,
          ),
          const SizedBox(height: AppSpacing.tiny),
          const Text(
            'Sign in or create an account',
            textAlign: TextAlign.center,
            style: AppTypography.loginSubtitle,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: onShopPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.shopPay,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.compact,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Continue with',
                    style: AppTypography.loginShopButton,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  SizedBox(
                    width: 38,
                    height: 16,
                    child: SvgPicture.asset(
                      'assets/icons/shop_pay.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _OrDivider(),
          const SizedBox(height: 20),
          const Text('Email address', style: AppTypography.loginInputLabel),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 44,
            child: TextField(
              controller: emailController,
              onChanged: onEmailChanged,
              onSubmitted: (_) => onSignInPressed(),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              style: AppTypography.loginInput,
              decoration: InputDecoration(
                hintText: 'example@gmail.com',
                hintStyle: AppTypography.loginInputHint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppSpacing.sm,
                ),
                enabledBorder: _inputBorder(AppColors.borderLight),
                focusedBorder: _inputBorder(AppColors.primary),
                errorBorder: _inputBorder(Theme.of(context).colorScheme.error),
                focusedErrorBorder: _inputBorder(
                  Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
          if (emailError != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              emailError!,
              style: AppTypography.loginCheckbox.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _MarketingCheckbox(
            value: acceptsMarketing,
            onChanged: onMarketingChanged,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 46,
            child: FilledButton(
              onPressed: onSignInPressed,
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
              child: const Text('Sign in', style: AppTypography.loginButton),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      borderSide: BorderSide(color: color),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(height: 1, color: AppColors.borderLight)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('OR', style: AppTypography.loginDivider),
        ),
        Expanded(child: Divider(height: 1, color: AppColors.borderLight)),
      ],
    );
  }
}

class _MarketingCheckbox extends StatelessWidget {
  const _MarketingCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: 'Email me with news and offers',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: AppSpacing.md,
              height: AppSpacing.md,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : AppColors.white,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.lightText,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.xxs),
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Text(
              'Email me with news and offers',
              style: AppTypography.loginCheckbox,
            ),
          ],
        ),
      ),
    );
  }
}
