import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/config/cart_pricing_config.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../checkout/services/shopify_checkout_launcher.dart';
import '../../home/widgets/shop_bottom_navigation.dart';
import '../models/cart_item.dart';
import '../models/cart_summary.dart';
import '../state/cart_controller.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _noteController = TextEditingController();
  final _discountController = TextEditingController();
  bool _noteIsExpanded = false;
  bool _checkoutIsOpening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noteController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(cartControllerProvider.notifier).restore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final summary = cart.cart == null
        ? CartSummary.calculate(items: const [])
        : CartSummary.fromShopifyCart(cart.cart!);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        bottomNavigationBar: _CartBottomArea(
          hasItems: cart.items.isNotEmpty,
          total: summary.total,
          onCheckout: cart.isRestoring || cart.isMutating || _checkoutIsOpening
              ? null
              : _openShopifyCheckout,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _CartHeader(itemCount: cart.itemCount),
              Expanded(
                child: cart.isRestoring
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : cart.errorMessage != null && cart.items.isEmpty
                    ? _CartError(
                        message: cart.errorMessage!,
                        onRetry: () =>
                            ref.read(cartControllerProvider.notifier).restore(),
                      )
                    : cart.items.isEmpty
                    ? const _EmptyCart()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        children: [
                          if (cart.errorMessage != null) ...[
                            Text(
                              cart.errorMessage!,
                              style: AppTypography.cartShippingMessage,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          _CartItems(
                            items: cart.items,
                            mutationPending: cart.isMutating,
                          ),
                          if (summary.showsFreeShippingProgress) ...[
                            const SizedBox(height: AppSpacing.md),
                            _FreeShippingCard(summary: summary),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          _OrderNoteCard(
                            expanded: _noteIsExpanded,
                            controller: _noteController,
                            onToggle: () => setState(
                              () => _noteIsExpanded = !_noteIsExpanded,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _OrderSummaryCard(summary: summary),
                          const SizedBox(height: AppSpacing.md),
                          _DiscountCard(
                            controller: _discountController,
                            onApply: cart.isMutating ? null : _applyDiscount,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyDiscount() async {
    FocusScope.of(context).unfocus();
    final applied = await ref
        .read(cartControllerProvider.notifier)
        .applyDiscountCode(_discountController.text);
    if (!mounted) return;
    final message = applied
        ? 'Discount code applied.'
        : ref.read(cartControllerProvider).errorMessage ??
              'This discount code is not applicable.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openShopifyCheckout() async {
    if (_checkoutIsOpening) return;
    setState(() => _checkoutIsOpening = true);

    try {
      final controller = ref.read(cartControllerProvider.notifier);
      await controller.restore();
      if (!mounted) return;

      final state = ref.read(cartControllerProvider);
      final cart = state.cart;
      if (cart == null || cart.lines.isEmpty) {
        _showCheckoutError(
          state.errorMessage ?? 'Your Shopify cart is empty. Please retry.',
        );
        return;
      }

      if (cart.checkoutUrl.trim().isEmpty) {
        _showCheckoutError(
          'Shopify checkout is unavailable right now. Please retry.',
        );
        return;
      }

      final checkoutResult = await ref
          .read(shopifyCheckoutLauncherProvider)
          .present(cart.checkoutUrl);
      if (!mounted) return;

      switch (checkoutResult.status) {
        case ShopifyCheckoutStatus.completed:
          await ref.read(cartControllerProvider.notifier).clear();
          if (mounted) context.go('/checkout/confirmation');
        case ShopifyCheckoutStatus.canceled:
          break;
        case ShopifyCheckoutStatus.failed:
          _showCheckoutError(
            checkoutResult.message ??
                'Unable to open Shopify checkout. Please retry.',
          );
        case ShopifyCheckoutStatus.externalOpened:
          break;
      }
    } catch (_) {
      if (mounted) {
        _showCheckoutError('Unable to open Shopify checkout. Please retry.');
      }
    } finally {
      if (mounted) {
        setState(() => _checkoutIsOpening = false);
      }
    }
  }

  void _showCheckoutError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CartError extends StatelessWidget {
  const _CartError({required this.message, required this.onRetry});

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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final itemLabel = itemCount == 1 ? 'item' : 'items';
    return ColoredBox(
      color: AppColors.white,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              const Text('My Cart', style: AppTypography.cartHeaderTitle),
              const SizedBox(width: AppSpacing.tiny),
              Text(
                '($itemCount $itemLabel)',
                style: AppTypography.cartHeaderCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItems extends ConsumerWidget {
  const _CartItems({required this.items, required this.mutationPending});

  final List<CartItem> items;
  final bool mutationPending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(cartControllerProvider.notifier);
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _CartItemCard(
            item: items[index],
            onDecrease: mutationPending
                ? null
                : () => controller.decreaseQuantity(items[index].lineId),
            onIncrease: mutationPending
                ? null
                : () => controller.increaseQuantity(items[index].lineId),
            onDelete: mutationPending
                ? null
                : () => controller.removeLine(items[index].lineId),
          ),
          if (index < items.length - 1) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onDelete,
  });

  final CartItem item;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          if (item.imageAsset.startsWith('http'))
            Image.network(
              item.imageAsset,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            )
          else if (item.imageAsset.isNotEmpty)
            Image.asset(
              item.imageAsset,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            )
          else
            const SizedBox.square(dimension: 64),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.cartItemTitle,
                          ),
                          const SizedBox(height: AppSpacing.tiny),
                          if (item.piecesPerPack != null)
                            Text(
                              '${item.piecesPerPack} QTY PER CASE',
                              style: AppTypography.cartPackQuantity,
                            ),
                        ],
                      ),
                    ),
                    _SvgTouchButton(
                      semanticsLabel: 'Remove ${item.productTitle}',
                      assetPath: 'assets/icons/cart_trash.svg',
                      iconSize: 18,
                      onTap: onDelete,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatGbp(item.linePrice),
                      style: AppTypography.productPrice,
                    ),
                    _CartQuantityControl(
                      quantity: item.quantity,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartQuantityControl extends StatelessWidget {
  const _CartQuantityControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 34,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuantityButton(
            semanticsLabel: 'Decrease cart quantity',
            assetPath: 'assets/icons/cart_minus.svg',
            onTap: onDecrease,
          ),
          Text('$quantity', style: AppTypography.quantityValue),
          _QuantityButton(
            semanticsLabel: 'Increase cart quantity',
            assetPath: 'assets/icons/cart_plus.svg',
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.semanticsLabel,
    required this.assetPath,
    required this.onTap,
  });

  final String semanticsLabel;
  final String assetPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          padding: const EdgeInsets.all(AppSpacing.tiny),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight2,
            borderRadius: BorderRadius.circular(5),
          ),
          child: SvgPicture.asset(
            assetPath,
            colorFilter: const ColorFilter.mode(
              AppColors.secondaryText,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _FreeShippingCard extends StatelessWidget {
  const _FreeShippingCard({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 16,
                child: SvgPicture.asset(
                  'assets/icons/cart_truck.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.shippingAccent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppTypography.cartShippingMessage,
                    children: [
                      const TextSpan(text: 'Add '),
                      TextSpan(
                        text: formatGbp(summary.freeShippingRemaining),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' more for free shipping'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.compact),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: summary.freeShippingProgress,
                backgroundColor: AppColors.shippingTrack,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.shippingAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatGbp(summary.subtotal),
                style: AppTypography.cartShippingCaption,
              ),
              Text(
                '\u00A3${CartPricingConfig.freeShippingThreshold.toStringAsFixed(0)} free',
                style: AppTypography.cartShippingCaption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderNoteCard extends StatelessWidget {
  const _OrderNoteCard({
    required this.expanded,
    required this.controller,
    required this.onToggle,
  });

  final bool expanded;
  final TextEditingController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: expanded,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 16,
                    child: SvgPicture.asset(
                      'assets/icons/cart_note.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.secondaryText,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Expanded(
                    child: Text(
                      'Add order note',
                      style: AppTypography.cartNote,
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: expanded ? 0.5 : 0,
                    child: SizedBox.square(
                      dimension: 14,
                      child: SvgPicture.asset(
                        'assets/icons/cart_chevron.svg',
                        colorFilter: const ColorFilter.mode(
                          AppColors.lightText,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: SizedBox(
                      height: 72,
                      child: TextField(
                        controller: controller,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        style: AppTypography.cartDiscountInput,
                        decoration: InputDecoration(
                          hintText: 'Special instructions for your order...',
                          hintStyle: AppTypography.cartDiscountInput.copyWith(
                            color: AppColors.lightText,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                          contentPadding: const EdgeInsets.all(AppSpacing.xs),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.summary});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ORDER SUMMARY',
              style: AppTypography.cartSummaryHeading,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Subtotal', value: summary.subtotal),
          if (summary.discount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Discount',
              value: summary.discount,
              isNegative: true,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Shipping',
            value: summary.shipping,
            unavailable: !summary.shippingAvailable,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Estimated taxes',
            value: summary.estimatedTaxes,
            unavailable: !summary.estimatedTaxesAvailable,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: AppTypography.cartTotalLabel),
              Text(
                formatGbp(summary.total),
                style: AppTypography.cartTotalValue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isNegative = false,
    this.unavailable = false,
  });

  final String label;
  final double value;
  final bool isNegative;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.cartSummaryLabel)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          unavailable
              ? 'At checkout'
              : '${isNegative ? '-' : ''}${formatGbp(value)}',
          style: AppTypography.cartSummaryValue,
        ),
      ],
    );
  }
}

class _DiscountCard extends StatelessWidget {
  const _DiscountCard({required this.controller, required this.onApply});

  final TextEditingController controller;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onApply?.call(),
                style: AppTypography.cartDiscountInput,
                decoration: InputDecoration(
                  hintText: 'Discount code',
                  hintStyle: AppTypography.cartDiscountInput.copyWith(
                    color: AppColors.lightText,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 7,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onApply,
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: const Text(
                  'APPLY',
                  style: AppTypography.cartApplyButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBottomArea extends StatelessWidget {
  const _CartBottomArea({
    required this.hasItems,
    required this.total,
    required this.onCheckout,
  });

  final bool hasItems;
  final double total;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasItems)
          ColoredBox(
            color: AppColors.backgroundLight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Semantics(
                button: true,
                label: 'Proceed to checkout',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCheckout,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      'Proceed to checkout — ${formatGbp(total)}',
                      style: AppTypography.cartCheckoutButton,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const ShopBottomNavigation(),
      ],
    );
  }
}

class _SvgTouchButton extends StatelessWidget {
  const _SvgTouchButton({
    required this.semanticsLabel,
    required this.assetPath,
    required this.iconSize,
    required this.onTap,
  });

  final String semanticsLabel;
  final String assetPath;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.tiny),
          child: SizedBox.square(
            dimension: iconSize,
            child: SvgPicture.asset(
              assetPath,
              colorFilter: const ColorFilter.mode(
                AppColors.lightText,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your cart is empty', style: AppTypography.cartNote),
    );
  }
}
