import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const fontFamily = 'Montserrat';

  static const textTheme = TextTheme(
    titleLarge: TextStyle(
      color: AppColors.primary,
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
    ),
  );

  static const collectionSectionTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.64,
  );

  static const collectionCount = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.24,
  );

  static const deliveryBanner = TextStyle(
    color: AppColors.primary,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const collectionCardTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const productCollectionTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.96,
  );

  static const productTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productQuantity = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const productPrice = TextStyle(
    color: AppColors.primary,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productUnitPrice = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const stockBadge = TextStyle(
    color: AppColors.stock,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productDetailsTitle = TextStyle(
    color: AppColors.ink,
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productDetailsQuantity = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.72,
  );

  static const productDetailsPrice = TextStyle(
    color: AppColors.primary,
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productDetailsMeta = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productDetailsLightMeta = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productOptionLabel = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.72,
  );

  static const productOption = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const quantityValue = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.84,
  );

  static const quantityCaption = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const sectionHeading = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.84,
  );

  static const productDescriptionBody = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productDescriptionEmphasis = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.6,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productFeatureTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productFeatureBody = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productSpecificationLabel = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const productSpecificationValue = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const bottomBarCaption = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const bottomBarButton = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.84,
  );

  static const navigationActiveLabel = TextStyle(
    color: AppColors.primary,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const navigationInactiveLabel = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const navigationBadge = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.54,
  );
}
