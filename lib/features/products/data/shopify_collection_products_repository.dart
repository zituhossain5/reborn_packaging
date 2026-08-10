import '../../../core/errors/shopify_failure.dart';
import '../../../core/network/shopify_storefront_client.dart';
import '../models/product_item.dart';
import '../models/product_page.dart';

class ShopifyCollectionProductsRepository {
  const ShopifyCollectionProductsRepository(this._client);

  static const collectionProductsQuery = r'''
    query CollectionProducts(
      $handle: String!
      $first: Int!
      $after: String
    ) {
      collection(handle: $handle) {
        id
        handle
        title
        products(first: $first, after: $after) {
          nodes {
            id
            handle
            title
            availableForSale
            featuredImage {
              url
              altText
            }
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
            variants(first: 20) {
              nodes {
                id
                title
                availableForSale
                price {
                  amount
                  currencyCode
                }
                selectedOptions {
                  name
                  value
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  ''';

  final ShopifyStorefrontClient _client;

  Future<ProductPage> fetchPage({
    required String collectionHandle,
    int first = 50,
    String? after,
  }) async {
    final data = await _client.execute(
      collectionProductsQuery,
      variables: {'handle': collectionHandle, 'first': first, 'after': after},
    );
    final collection = data['collection'];
    if (collection == null) {
      throw ShopifyResponseFailure(
        'Shopify collection "$collectionHandle" was not found.',
      );
    }
    if (collection is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'Shopify collection data was invalid.',
      );
    }

    final products = collection['products'];
    if (products is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'Shopify collection products were missing.',
      );
    }
    final rawNodes = products['nodes'];
    final rawPageInfo = products['pageInfo'];
    if (rawNodes is! List || rawPageInfo is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'Shopify collection products were invalid.',
      );
    }

    final collectionHandleValue = collection['handle'] as String? ?? '';
    final collectionTitle = collection['title'] as String? ?? '';
    final items = rawNodes
        .whereType<Map<String, dynamic>>()
        .map(
          (node) => _productFromJson(
            node,
            collectionHandle: collectionHandleValue,
            collectionTitle: collectionTitle,
          ),
        )
        .toList(growable: false);

    return ProductPage(
      items: items,
      pageInfo: ProductPageInfo(
        hasNextPage: rawPageInfo['hasNextPage'] as bool? ?? false,
        endCursor: rawPageInfo['endCursor'] as String?,
      ),
    );
  }

  Future<ProductCatalog> fetchAll(String collectionHandle) async {
    final items = <ProductItem>[];
    String? cursor;
    var pagesFetched = 0;
    ProductPageInfo pageInfo;

    do {
      final page = await fetchPage(
        collectionHandle: collectionHandle,
        after: cursor,
      );
      items.addAll(page.items);
      pageInfo = page.pageInfo;
      pagesFetched++;

      if (pageInfo.hasNextPage && pageInfo.endCursor == null) {
        throw const ShopifyResponseFailure(
          'Shopify product pagination cursor was missing.',
        );
      }
      cursor = pageInfo.endCursor;
    } while (pageInfo.hasNextPage);

    return ProductCatalog(
      items: List.unmodifiable(items),
      pageInfo: pageInfo,
      pagesFetched: pagesFetched,
    );
  }

  ProductItem _productFromJson(
    Map<String, dynamic> json, {
    required String collectionHandle,
    required String collectionTitle,
  }) {
    final priceRange = json['priceRange'];
    final minimumPrice = priceRange is Map<String, dynamic>
        ? priceRange['minVariantPrice']
        : null;
    if (minimumPrice is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'A Shopify product price was missing.',
      );
    }

    final amount = double.tryParse(minimumPrice['amount'] as String? ?? '');
    if (amount == null) {
      throw const ShopifyResponseFailure(
        'A Shopify product price was invalid.',
      );
    }

    final featuredImage = json['featuredImage'];
    final image = featuredImage is Map<String, dynamic> ? featuredImage : null;
    final variantsConnection = json['variants'];
    final rawVariants = variantsConnection is Map<String, dynamic>
        ? variantsConnection['nodes']
        : null;

    return ProductItem(
      id: json['id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      collectionHandle: collectionHandle,
      collectionTitle: collectionTitle,
      title: json['title'] as String? ?? '',
      availableForSale: json['availableForSale'] as bool? ?? false,
      price: amount,
      currencyCode: minimumPrice['currencyCode'] as String? ?? '',
      imageUrl: image?['url'] as String?,
      imageAltText: image?['altText'] as String?,
      variants: rawVariants is List
          ? rawVariants
                .whereType<Map<String, dynamic>>()
                .map(_variantFromJson)
                .toList(growable: false)
          : const [],
    );
  }

  ProductVariantItem _variantFromJson(Map<String, dynamic> json) {
    final price = json['price'];
    if (price is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'A Shopify variant price was missing.',
      );
    }
    final amount = double.tryParse(price['amount'] as String? ?? '');
    if (amount == null) {
      throw const ShopifyResponseFailure(
        'A Shopify variant price was invalid.',
      );
    }

    final rawOptions = json['selectedOptions'];
    return ProductVariantItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      availableForSale: json['availableForSale'] as bool? ?? false,
      price: amount,
      currencyCode: price['currencyCode'] as String? ?? '',
      selectedOptions: rawOptions is List
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(
                  (option) => ProductSelectedOption(
                    name: option['name'] as String? ?? '',
                    value: option['value'] as String? ?? '',
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}
