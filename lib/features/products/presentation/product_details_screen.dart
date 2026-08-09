import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../home/widgets/home_header.dart';
import '../models/product_details.dart';
import '../state/product_selection_controller.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/product_feature_item.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_option_chip.dart';
import '../widgets/product_specification_row.dart';
import '../widgets/quantity_selector.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({required this.product, super.key});

  final ProductDetails product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
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
          onAddToCart: () {},
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              HomeHeader(onBack: context.pop, showCart: true, showShadow: true),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProductImageGallery(
                        key: ValueKey(_selectedVariant.imageAsset),
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
                              _ProductDescription(product: product),
                              const SizedBox(height: 20),
                              const _SectionDivider(),
                              const SizedBox(height: 20),
                              _ProductFeatures(product: product),
                              const SizedBox(height: 20),
                              const _SectionDivider(),
                              const SizedBox(height: 20),
                              _ProductSpecifications(product: product),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProductOptionGroup(
          label: 'SIZE',
          children: [
            for (final size in product.sizes)
              ProductOptionChip(
                label: size,
                selected: size == _selectedVariant.size,
                enabled: _sizeIsAvailable(size),
                onTap: () => _selectSize(size),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _ProductOptionGroup(
          label: 'LID OPTION',
          children: [
            for (final lidOption in product.lidOptions)
              ProductOptionChip(
                label: lidOption,
                selected: lidOption == _selectedVariant.lid,
                enabled: _lidIsAvailable(lidOption),
                onTap: () => _selectLid(lidOption),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('QUANTITY', style: AppTypography.productOptionLabel),
        const SizedBox(height: AppSpacing.sm),
        QuantitySelector(
          quantity: _selection.quantity,
          totalUnits: _selection.totalUnits,
          canDecrease: _selection.canDecrease,
          onDecrease: _decreaseQuantity,
          onIncrease: _increaseQuantity,
        ),
      ],
    );
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
  final double displayUnitPrice;
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
        Text(
          '${variant.piecesPerPack} QTY',
          style: AppTypography.productDetailsQuantity,
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
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                '\u00A3${displayUnitPrice.toStringAsFixed(4)} / piece',
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
          Text.rich(
            TextSpan(
              children: [
                for (final segment in product.description[index].segments)
                  TextSpan(
                    text: segment.text,
                    style: segment.emphasized
                        ? AppTypography.productDescriptionEmphasis
                        : AppTypography.productDescriptionBody,
                  ),
              ],
            ),
          ),
          if (index < product.description.length - 1)
            const SizedBox(height: 19.2),
        ],
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
  const _ProductSpecifications({required this.product});

  final ProductDetails product;

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
        for (var index = 0; index < product.specifications.length; index++) ...[
          ProductSpecificationRow(specification: product.specifications[index]),
          if (index < product.specifications.length - 1)
            const SizedBox(height: 14),
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
