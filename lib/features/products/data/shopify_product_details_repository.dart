import '../../../core/errors/shopify_failure.dart';
import '../../../core/network/shopify_storefront_client.dart';
import '../models/product_details.dart';
import 'product_description_html_parser.dart';

class ShopifyProductDetailsRepository {
  const ShopifyProductDetailsRepository(this._client);

  static const productDetailsQuery = r'''
    query ProductDetails(
      $handle: String!
      $variantsFirst: Int!
      $variantsAfter: String
    ) {
      product(handle: $handle) {
        id
        handle
        title
        description
        descriptionHtml
        availableForSale
        featuredImage { url altText }
        images(first: 50) { nodes { url altText } }
        options { id name values }
        variants(first: $variantsFirst, after: $variantsAfter) {
          nodes {
            id
            title
            sku
            availableForSale
            quantityAvailable
            selectedOptions { name value }
            price { amount currencyCode }
            compareAtPrice { amount currencyCode }
            image { url altText }
            unitPrice { amount currencyCode }
            unitPriceMeasurement {
              measuredType
              quantityUnit
              quantityValue
              referenceUnit
              referenceValue
            }
            quantityRule { minimum maximum increment }
          }
          pageInfo { hasNextPage endCursor }
        }
      }
    }
  ''';

  final ShopifyStorefrontClient _client;

  Future<ProductDetails?> fetchByHandle(String handle) async {
    Map<String, dynamic>? productJson;
    final variants = <ProductVariant>[];
    String? cursor;
    var hasNextPage = true;

    while (hasNextPage) {
      final data = await _client.execute(
        productDetailsQuery,
        variables: {
          'handle': handle,
          'variantsFirst': 100,
          'variantsAfter': cursor,
        },
      );
      final rawProduct = data['product'];
      if (rawProduct == null) return null;
      if (rawProduct is! Map<String, dynamic>) {
        throw const ShopifyResponseFailure('Shopify product data was invalid.');
      }
      productJson ??= rawProduct;

      final connection = rawProduct['variants'];
      if (connection is! Map<String, dynamic>) {
        throw const ShopifyResponseFailure(
          'Shopify product variants were missing.',
        );
      }
      final nodes = connection['nodes'];
      final pageInfo = connection['pageInfo'];
      if (nodes is! List || pageInfo is! Map<String, dynamic>) {
        throw const ShopifyResponseFailure(
          'Shopify product variants were invalid.',
        );
      }
      variants.addAll(
        nodes.whereType<Map<String, dynamic>>().map(_variantFromJson),
      );
      hasNextPage = pageInfo['hasNextPage'] as bool? ?? false;
      cursor = pageInfo['endCursor'] as String?;
      if (hasNextPage && cursor == null) {
        throw const ShopifyResponseFailure(
          'Shopify variant pagination cursor was missing.',
        );
      }
    }

    if (variants.isEmpty) {
      throw const ShopifyResponseFailure('Shopify product has no variants.');
    }
    return _productFromJson(productJson!, variants);
  }

  ProductDetails _productFromJson(
    Map<String, dynamic> json,
    List<ProductVariant> variants,
  ) {
    final imagesConnection = json['images'];
    final imageNodes = imagesConnection is Map<String, dynamic>
        ? imagesConnection['nodes']
        : null;
    final imageItems = imageNodes is List
        ? imageNodes
              .whereType<Map<String, dynamic>>()
              .map(_imageFromJson)
              .where((image) => image.url.isNotEmpty)
              .toList(growable: false)
        : <ProductImage>[];
    final featuredJson = json['featuredImage'];
    final featuredImage = featuredJson is Map<String, dynamic>
        ? _imageFromJson(featuredJson)
        : null;
    final images = <String>[
      for (final image in imageItems) image.url,
      if (imageItems.isEmpty && featuredImage != null) featuredImage.url,
    ];
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions
              .whereType<Map<String, dynamic>>()
              .map(
                (option) => ProductOption(
                  id: option['id'] as String? ?? '',
                  name: option['name'] as String? ?? '',
                  values:
                      (option['values'] as List?)?.whereType<String>().toList(
                        growable: false,
                      ) ??
                      const [],
                ),
              )
              .toList(growable: false)
        : <ProductOption>[];
    final selectedVariant = variants.firstWhere(
      (variant) => variant.isAvailable,
      orElse: () => variants.first,
    );
    final descriptionText = json['description'] as String? ?? '';
    final descriptionHtml = json['descriptionHtml'] as String? ?? '';
    final parsedContent = const ProductDescriptionHtmlParser().parse(
      descriptionHtml,
      fallbackText: descriptionText,
    );

    return ProductDetails(
      id: json['id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      title: json['title'] as String? ?? '',
      images: images,
      currency: selectedVariant.currencyCode,
      selectedVariantId: selectedVariant.id,
      variants: List.unmodifiable(variants),
      sizes: _valuesForOption(options, 'size'),
      lidOptions: _valuesForOption(options, 'lid'),
      quantityRule: selectedVariant.quantityRule,
      description: parsedContent.description,
      features: parsedContent.features,
      specifications: parsedContent.specifications,
      descriptionText: descriptionText,
      descriptionHtml: descriptionHtml,
      availableForSale: json['availableForSale'] as bool? ?? false,
      featuredImage: featuredImage,
      imageItems: imageItems,
      options: options,
    );
  }

  ProductVariant _variantFromJson(Map<String, dynamic> json) {
    final price = _money(json['price'], required: true)!;
    final imageJson = json['image'];
    final ruleJson = json['quantityRule'];
    final measurementJson = json['unitPriceMeasurement'];
    final selectedOptions =
        (json['selectedOptions'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(
              (option) => ProductSelectedOption(
                name: option['name'] as String? ?? '',
                value: option['value'] as String? ?? '',
              ),
            )
            .toList(growable: false) ??
        const <ProductSelectedOption>[];

    return ProductVariant(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      sku: json['sku'] as String?,
      size: _selectedValue(selectedOptions, 'size') ?? '',
      lid: _selectedValue(selectedOptions, 'lid') ?? '',
      price: price.amount,
      currencyCode: price.currencyCode,
      availableForSale: json['availableForSale'] as bool? ?? false,
      quantityAvailable: json['quantityAvailable'] as int?,
      selectedOptions: selectedOptions,
      compareAtPrice: _money(json['compareAtPrice'])?.amount,
      image: imageJson is Map<String, dynamic>
          ? _imageFromJson(imageJson)
          : null,
      shopifyUnitPrice: _money(json['unitPrice'])?.amount,
      unitPriceMeasurement: measurementJson is Map<String, dynamic>
          ? UnitPriceMeasurement(
              measuredType: measurementJson['measuredType'] as String? ?? '',
              quantityUnit: measurementJson['quantityUnit'] as String? ?? '',
              quantityValue:
                  (measurementJson['quantityValue'] as num?)?.toDouble() ?? 0,
              referenceUnit: measurementJson['referenceUnit'] as String? ?? '',
              referenceValue: measurementJson['referenceValue'] as int? ?? 0,
            )
          : null,
      quantityRule: ruleJson is Map<String, dynamic>
          ? ProductQuantityRule(
              minimum: ruleJson['minimum'] as int? ?? 1,
              maximum: ruleJson['maximum'] as int?,
              increment: ruleJson['increment'] as int? ?? 1,
            )
          : const ProductQuantityRule(minimum: 1, increment: 1),
    );
  }

  ProductImage _imageFromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] as String? ?? '',
      altText: json['altText'] as String?,
    );
  }

  _Money? _money(Object? value, {bool required = false}) {
    if (value == null && !required) return null;
    if (value is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure('Shopify money data was invalid.');
    }
    final amount = double.tryParse(value['amount'] as String? ?? '');
    if (amount == null) {
      throw const ShopifyResponseFailure('Shopify money amount was invalid.');
    }
    return _Money(
      amount: amount,
      currencyCode: value['currencyCode'] as String? ?? '',
    );
  }

  List<String> _valuesForOption(List<ProductOption> options, String name) {
    for (final option in options) {
      if (option.name.toLowerCase().contains(name)) return option.values;
    }
    return const [];
  }

  String? _selectedValue(List<ProductSelectedOption> options, String name) {
    for (final option in options) {
      if (option.name.toLowerCase().contains(name)) return option.value;
    }
    return null;
  }
}

class _Money {
  const _Money({required this.amount, required this.currencyCode});

  final double amount;
  final String currencyCode;
}
