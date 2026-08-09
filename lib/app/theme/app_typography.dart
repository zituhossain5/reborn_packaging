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

  static const cartHeaderTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.18,
  );

  static const cartHeaderCount = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const cartItemTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const cartPackQuantity = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.44,
  );

  static const cartShippingMessage = TextStyle(
    color: AppColors.shippingAccent,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const cartShippingCaption = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.44,
  );

  static const cartNote = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const cartSummaryHeading = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.84,
  );

  static const cartSummaryLabel = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.26,
  );

  static const cartSummaryValue = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.26,
  );

  static const cartTotalLabel = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const cartTotalValue = TextStyle(
    color: AppColors.primary,
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.36,
  );

  static const cartDiscountInput = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const cartApplyButton = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const cartCheckoutButton = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const searchInput = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.4,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const searchPlaceholder = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.4,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const searchNoResults = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const checkoutStepNumber = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.12,
  );

  static const checkoutStepActive = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const checkoutStepInactive = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.66,
  );

  static const checkoutSummaryLabel = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const checkoutSummaryTotal = TextStyle(
    color: AppColors.primary,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const checkoutExpressLabel = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.72,
  );

  static const checkoutSectionTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const checkoutInputLabel = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const checkoutInput = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const checkoutHint = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const checkoutCheckbox = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const checkoutProduct = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const checkoutSummaryRow = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const paymentSecurity = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const paymentMethod = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const paymentMore = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const paymentDescription = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.26,
  );

  static const orderPlacedTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const orderConfirmation = TextStyle(
    color: AppColors.orderDescriptionText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const orderSummaryLabel = TextStyle(
    color: AppColors.orderSummaryLabelText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.26,
  );

  static const orderSummaryValue = TextStyle(
    color: AppColors.orderSummaryValueText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.26,
  );

  static const orderSummaryEmphasis = TextStyle(
    color: AppColors.orderSummaryEmphasisText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.26,
  );

  static const orderActionPrimary = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const orderActionSecondary = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const loginTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.24,
  );

  static const loginSubtitle = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.26,
  );

  static const loginShopButton = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const loginDivider = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.72,
  );

  static const loginInputLabel = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const loginInput = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const loginInputHint = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const loginCheckbox = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const loginButton = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountAvatar = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.14,
  );

  static const accountName = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.18,
  );

  static const accountEmail = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.12,
  );

  static const accountTabActive = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.14,
  );

  static const accountTabInactive = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.14,
  );

  static const accountEmptyTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountEmptyBody = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountShopButton = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountOrdersHeading = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.18,
  );

  static const accountOrderValue = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.28,
  );

  static const accountOrderMeta = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.24,
  );

  static const accountOrderStatus = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.12,
  );

  static const accountSectionLabel = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.72,
  );

  static const accountProfileCaption = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountProfileValue = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountAddressName = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const accountAddressBody = TextStyle(
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.26,
  );

  static const accountProfileAction = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.13,
  );

  static const accountSignOut = TextStyle(
    color: AppColors.accountDanger,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountSheetTitle = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountSheetLabel = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountSheetSplitLabel = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.26,
  );

  static const accountSheetInput = TextStyle(
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const accountSheetHint = TextStyle(
    color: AppColors.lightText,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.28,
  );

  static const accountSheetButton = TextStyle(
    color: AppColors.black,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const accountSheetPrimaryButton = TextStyle(
    color: AppColors.white,
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
