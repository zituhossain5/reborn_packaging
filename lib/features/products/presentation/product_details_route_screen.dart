import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../home/widgets/home_header.dart';
import '../state/product_details_provider.dart';
import 'product_details_screen.dart';

class ProductDetailsRouteScreen extends ConsumerWidget {
  const ProductDetailsRouteScreen({required this.productHandle, super.key});

  final String productHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailsProvider(productHandle));
    return product.when(
      data: (value) => value == null
          ? _ProductDetailsState(
              message: 'Product not found.',
              onRetry: () =>
                  ref.invalidate(productDetailsProvider(productHandle)),
            )
          : ProductDetailsScreen(product: value),
      loading: () => const _ProductDetailsState(isLoading: true),
      error: (error, stackTrace) => _ProductDetailsState(
        message: 'Unable to load product.',
        onRetry: () => ref.invalidate(productDetailsProvider(productHandle)),
      ),
    );
  }
}

class _ProductDetailsState extends StatelessWidget {
  const _ProductDetailsState({
    this.message,
    this.onRetry,
    this.isLoading = false,
  });

  final String? message;
  final VoidCallback? onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeHeader(onBack: context.pop, showShadow: true),
            Expanded(
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message ?? 'Unable to load product.',
                            style: AppTypography.searchNoResults,
                          ),
                          if (onRetry != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            FilledButton(
                              onPressed: onRetry,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
