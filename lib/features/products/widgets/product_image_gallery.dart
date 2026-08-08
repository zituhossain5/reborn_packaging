import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({required this.images, super.key});

  final List<String> images;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  static const _galleryHeight = 248.0;
  static const _imageSize = 210.0;
  static const _arrowSize = 36.0;
  static const _dotSize = 6.0;

  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SizedBox(
        height: _galleryHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                height: _imageSize,
                child: Row(
                  children: [
                    _GalleryArrowButton(
                      semanticLabel: 'Previous product image',
                      assetPath: 'assets/icons/gallery_previous.svg',
                      onTap: _showPrevious,
                    ),
                    Expanded(
                      child: Center(
                        child: SizedBox.square(
                          dimension: _imageSize,
                          child: Image.asset(
                            widget.images[_currentIndex],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    _GalleryArrowButton(
                      semanticLabel: 'Next product image',
                      assetPath: 'assets/icons/gallery_next.svg',
                      onTap: _showNext,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < widget.images.length; index++) ...[
                  Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? AppColors.primary
                          : AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index < widget.images.length - 1)
                    const SizedBox(width: AppSpacing.tiny),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPrevious() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  void _showNext() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.images.length;
    });
  }
}

class _GalleryArrowButton extends StatelessWidget {
  const _GalleryArrowButton({
    required this.semanticLabel,
    required this.assetPath,
    required this.onTap,
  });

  final String semanticLabel;
  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _ProductImageGalleryState._arrowSize,
          height: _ProductImageGalleryState._arrowSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 7.5,
            height: 13.75,
            child: SvgPicture.asset(assetPath),
          ),
        ),
      ),
    );
  }
}
