import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../cart/state/cart_controller.dart';
import '../../cart/widgets/cart_add_feedback.dart';
import '../../home/widgets/home_header.dart';
import '../models/product_details.dart';
import '../state/product_selection_controller.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/product_feature_item.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_option_chip.dart';
import '../widgets/product_specification_row.dart';
import '../widgets/quantity_selector.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({required this.product, super.key});

  final ProductDetails product;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  late final ProductSelectionController _selection;

  ProductDetails get product => widget.product;
  ProductVariant get _selectedVariant => _selection.selectedVariant;

  @override
  void initState() {
    super.initState();
    _selection = ProductSelectionController(product);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
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
        bottomNavigationBar: ProductBottomBar(
          totalPrice: _selection.totalPrice,
          enabled: _selectedVariant.isAvailable && !cart.isMutating,
          isLoading: cart.isMutating,
          onAddToCart: _addToCart,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              HomeHeader(
                onBack: context.pop,
                showCart: true,
                showShadow: true,
                onCart: () => context.push('/cart'),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProductImageGallery(
                        key: ValueKey(_selectedVariant.imageSource),
                        images: _selection.galleryImages,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xxs),
                    ),
                    SliverToBoxAdapter(
                      child: ColoredBox(
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProductInformation(
                                product: product,
                                variant: _selectedVariant,
                                displayPrice: _selection.displayedVariantPrice,
                                displayUnitPrice: _selection.displayedUnitPrice,
                                includeVat: _selection.includeVat,
                                onToggleIncludeVat: _toggleIncludeVat,
                              ),
                              const SizedBox(height: 20),
                              const _SectionDivider(),
                              const SizedBox(height: 20),
                              _variantSelectors(),
                              const SizedBox(height: 20),
                              const _SectionDivider(),
                              const SizedBox(height: 20),
                              _ProductContent(
                                product: product,
                                selectedVariant: _selectedVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: ProductBottomBar.scrollPadding(context),
                      ),
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

  Widget _variantSelectors() {
    final options = product.options.isNotEmpty
        ? product.selectableOptions
        : [
            ProductOption(id: 'size', name: 'Size', values: product.sizes),
            ProductOption(id: 'lid', name: 'Lid', values: product.lidOptions),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in options) ...[
          _ProductOptionGroup(
            label: option.name.toLowerCase().contains('lid')
                ? 'LID OPTION'
                : option.name.toUpperCase(),
            children: [
              for (final value in option.values)
                ProductOptionChip(
                  label: value,
                  selected: product.options.isEmpty
                      ? (option.name == 'Size'
                            ? _selectedVariant.size == value
                            : _selectedVariant.lid == value)
                      : _selection.selectedValue(option.name) == value,
                  enabled: product.options.isEmpty
                      ? (option.name == 'Size'
                            ? _sizeIsAvailable(value)
                            : _lidIsAvailable(value))
                      : _selection.isOptionValueAvailable(option.name, value),
                  onTap: () => product.options.isEmpty
                      ? (option.name == 'Size'
                            ? _selectSize(value)
                            : _selectLid(value))
                      : _selectOption(option.name, value),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        const Text('QUANTITY', style: AppTypography.productOptionLabel),
        const SizedBox(height: AppSpacing.sm),
        QuantitySelector(
          quantity: _selection.quantity,
          totalUnits: _selection.totalUnits,
          canDecrease: _selection.canDecrease,
          canIncrease: _selection.canIncrease,
          onDecrease: _decreaseQuantity,
          onIncrease: _increaseQuantity,
        ),
      ],
    );
  }

  void _selectOption(String optionName, String value) {
    setState(() => _selection.selectOption(optionName, value));
  }

  bool _sizeIsAvailable(String size) {
    return _selection.isSizeAvailable(size);
  }

  bool _lidIsAvailable(String lidOption) {
    return _selection.isLidAvailable(lidOption);
  }

  void _selectSize(String size) {
    setState(() => _selection.selectSize(size));
  }

  void _selectLid(String lidOption) {
    setState(() => _selection.selectLid(lidOption));
  }

  void _increaseQuantity() {
    setState(_selection.increaseQuantity);
  }

  void _decreaseQuantity() {
    setState(_selection.decreaseQuantity);
  }

  void _toggleIncludeVat() {
    setState(_selection.toggleIncludeVat);
  }

  Future<void> _addToCart() async {
    final added = await ref
        .read(cartControllerProvider.notifier)
        .addVariant(
          product: product,
          variant: _selectedVariant,
          quantity: _selection.quantity,
        );
    if (!mounted) return;
    if (added) {
      showAddedToCartFeedback(context);
    } else {
      final message = ref.read(cartControllerProvider).errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({
    required this.product,
    required this.variant,
    required this.displayPrice,
    required this.displayUnitPrice,
    required this.includeVat,
    required this.onToggleIncludeVat,
  });

  final ProductDetails product;
  final ProductVariant variant;
  final double displayPrice;
  final double? displayUnitPrice;
  final bool includeVat;
  final VoidCallback onToggleIncludeVat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.tiny,
            vertical: 3,
          ),
          decoration: const BoxDecoration(
            color: AppColors.stockBackground,
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.xxs)),
          ),
          child: Text(
            variant.isAvailable ? 'In Stock' : 'Out of Stock',
            style: AppTypography.stockBadge,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(product.title, style: AppTypography.productDetailsTitle),
        const SizedBox(height: AppSpacing.xxs),
        SizedBox(
          height: 16,
          child: variant.piecesPerPack == null
              ? null
              : Text(
                  '${variant.piecesPerPack} QTY',
                  style: AppTypography.productDetailsQuantity,
                ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\u00A3${displayPrice.toStringAsFixed(2)}',
              maxLines: 1,
              style: AppTypography.productDetailsPrice,
            ),
            if (displayUnitPrice != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  '\u00A3${displayUnitPrice!.toStringAsFixed(4)} / piece',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: AppTypography.productDetailsMeta,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: AppColors.lightText,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            Text(
              includeVat ? 'Inc. VAT' : 'Ex. VAT',
              maxLines: 1,
              style: AppTypography.productDetailsLightMeta,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          button: true,
          checked: includeVat,
          label: 'Include VAT',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleIncludeVat,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.checkboxBorder),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppSpacing.xxs),
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: 16,
                    child: includeVat
                        ? const Icon(
                            Icons.check,
                            size: 13,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Text(
                  'Include VAT',
                  style: AppTypography.productDetailsMeta,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductOptionGroup extends StatelessWidget {
  const _ProductOptionGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.productOptionLabel),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.tiny,
          runSpacing: AppSpacing.tiny,
          children: children,
        ),
      ],
    );
  }
}

class _ProductContent extends StatelessWidget {
  const _ProductContent({required this.product, required this.selectedVariant});

  final ProductDetails product;
  final ProductVariant selectedVariant;

  @override
  Widget build(BuildContext context) {
    final specifications = product.specificationsForVariant(selectedVariant);
    final sections = <Widget>[
      if (product.description.isNotEmpty) _ProductDescription(product: product),
      if (product.features.isNotEmpty) _ProductFeatures(product: product),
      if (specifications.isNotEmpty)
        _ProductSpecifications(specifications: specifications),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          if (index > 0) ...[
            const SizedBox(height: 20),
            const _SectionDivider(),
            const SizedBox(height: 20),
          ],
          sections[index],
        ],
      ],
    );
  }
}

class _ProductDescription extends StatelessWidget {
  const _ProductDescription({required this.product});

  final ProductDetails product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRODUCT DESCRIPTION', style: AppTypography.sectionHeading),
        const SizedBox(height: 20),
        for (var index = 0; index < product.description.length; index++) ...[
          _ProductDescriptionBlock(block: product.description[index]),
          if (index < product.description.length - 1)
            const SizedBox(height: 19.2),
        ],
      ],
    );
  }
}

class _ProductDescriptionBlock extends StatelessWidget {
  const _ProductDescriptionBlock({required this.block});

  final ProductDescriptionParagraph block;

  @override
  Widget build(BuildContext context) {
    final text = Text.rich(
      TextSpan(
        children: [
          for (final segment in block.segments)
            TextSpan(
              text: segment.text,
              style: block.type == ProductDescriptionBlockType.heading
                  ? AppTypography.productFeatureTitle
                  : segment.emphasized
                  ? AppTypography.productDescriptionEmphasis
                  : AppTypography.productDescriptionBody,
            ),
        ],
      ),
    );

    if (block.type != ProductDescriptionBlockType.listItem) return text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•', style: AppTypography.productDescriptionBody),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: text),
      ],
    );
  }
}

class _ProductFeatures extends StatelessWidget {
  const _ProductFeatures({required this.product});

  final ProductDetails product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('KEY FEATURES', style: AppTypography.sectionHeading),
        const SizedBox(height: 20),
        for (var index = 0; index < product.features.length; index++) ...[
          ProductFeatureItem(feature: product.features[index]),
          if (index < product.features.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ProductSpecifications extends StatelessWidget {
  const _ProductSpecifications({required this.specifications});

  final List<ProductSpecification> specifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRODUCT SPECIFICATION',
          style: AppTypography.sectionHeading,
        ),
        const SizedBox(height: 20),
        for (var index = 0; index < specifications.length; index++) ...[
          ProductSpecificationRow(specification: specifications[index]),
          if (index < specifications.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 1,
      child: ColoredBox(color: AppColors.backgroundLight2),
    );
  }
}
