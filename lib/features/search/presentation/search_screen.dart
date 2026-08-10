import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../products/actions/product_cart_actions.dart';
import '../../products/models/product_item.dart';
import '../../products/widgets/product_card.dart';
import '../state/search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.backgroundLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _SearchHeader(
                controller: _textController,
                hasText: search.hasQuery,
                onChanged: ref.read(searchControllerProvider.notifier).setQuery,
                onClose: _closeOrClear,
              ),
              Expanded(child: _SearchBody(search: search)),
            ],
          ),
        ),
      ),
    );
  }

  void _closeOrClear() {
    if (_textController.text.isNotEmpty) {
      _textController.clear();
      ref.read(searchControllerProvider.notifier).clear();
      return;
    }

    context.pop();
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.hasText,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.searchHeaderShadow,
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.primaryText),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(1.86),
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            colorFilter: const ColorFilter.mode(
                              AppColors.lightText,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: TextField(
                          key: const ValueKey('product_search_field'),
                          controller: controller,
                          autofocus: true,
                          onChanged: onChanged,
                          textInputAction: TextInputAction.search,
                          style: AppTypography.searchInput,
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Search products...',
                            hintStyle: AppTypography.searchPlaceholder,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Semantics(
                button: true,
                label: hasText ? 'Clear search' : 'Close search',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClose,
                  child: SizedBox.square(
                    dimension: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(3.75),
                      child: SvgPicture.asset(
                        'assets/icons/search_close.svg',
                        colorFilter: const ColorFilter.mode(
                          AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
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

class _SearchBody extends ConsumerWidget {
  const _SearchBody({required this.search});

  final SearchState search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!search.hasQuery || search.isDebouncing) {
      return const SizedBox.expand();
    }

    if (search.isLoading) {
      return const Center(
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (search.hasError && search.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                search.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.searchNoResults,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: ref.read(searchControllerProvider.notifier).retry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (search.results.isEmpty) {
      return const Center(
        child: Text('No products found', style: AppTypography.searchNoResults),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < ProductCard.height) {
          ref.read(searchControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: GridView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: search.results.length + (search.isLoadingMore ? 1 : 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          mainAxisExtent: ProductCard.height,
        ),
        itemBuilder: (context, index) {
          if (index >= search.results.length) {
            return const Center(
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final product = search.results[index];
          return ProductCard(
            product: product,
            onTap: () {
              FocusScope.of(context).unfocus();
              context.push('/products/${product.handle}');
            },
            onAddToCart: () => _addToCartOrOpenDetails(
              context: context,
              ref: ref,
              product: product,
            ),
          );
        },
      ),
    );
  }

  void _addToCartOrOpenDetails({
    required BuildContext context,
    required WidgetRef ref,
    required ProductItem product,
  }) {
    final added = addProductItemDefaultVariantToCart(
      ref: ref,
      product: product,
    );

    if (!added) {
      FocusScope.of(context).unfocus();
      context.push('/products/${product.handle}');
    }
  }
}
