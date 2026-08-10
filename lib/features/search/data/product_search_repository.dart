import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/shopify_failure.dart';
import '../../../core/network/shopify_providers.dart';
import '../../../core/network/shopify_storefront_client.dart';
import '../../products/models/product_item.dart';
import '../../products/models/product_page.dart';

final productSearchRepositoryProvider = Provider<ProductSearchRepository>(
  (ref) => ShopifyProductSearchRepository(
    ref.watch(shopifyStorefrontClientProvider),
  ),
);

abstract interface class ProductSearchRepository {
  Future<ProductPage> searchPage({
    required String query,
    int first,
    String? after,
  });
}

class ShopifyProductSearchRepository implements ProductSearchRepository {
  const ShopifyProductSearchRepository(this._client);

  static const productSearchQuery = r'''
    query ProductSearch(
      $query: String!
      $first: Int!
      $after: String
    ) {
      search(
        query: $query
        types: [PRODUCT]
        first: $first
        after: $after
        sortKey: RELEVANCE
      ) {
        nodes {
          ... on Product {
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
            collections(first: 1) {
              nodes {
                handle
                title
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
  ''';

  final ShopifyStorefrontClient _client;

  @override
  Future<ProductPage> searchPage({
    required String query,
    int first = 20,
    String? after,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return const ProductPage(
        items: [],
        pageInfo: ProductPageInfo(hasNextPage: false, endCursor: null),
      );
    }

    final data = await _client.execute(
      productSearchQuery,
      variables: {
        'query': _shopifySearchQuery(normalizedQuery),
        'first': first,
        'after': after,
      },
    );
    final search = data['search'];
    if (search is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure('Shopify search data was missing.');
    }

    final rawNodes = search['nodes'];
    final rawPageInfo = search['pageInfo'];
    if (rawNodes is! List || rawPageInfo is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'Shopify search results were invalid.',
      );
    }

    return ProductPage(
      items: rawNodes
          .whereType<Map<String, dynamic>>()
          .map(_productFromJson)
          .toList(growable: false),
      pageInfo: ProductPageInfo(
        hasNextPage: rawPageInfo['hasNextPage'] as bool? ?? false,
        endCursor: rawPageInfo['endCursor'] as String?,
      ),
    );
  }

  static String _shopifySearchQuery(String query) {
    final terms = query
        .split(RegExp(r'\s+'))
        .map(_searchTerm)
        .where((term) => term.isNotEmpty)
        .toList(growable: false);
    if (terms.isEmpty) return query;
    return terms.map((term) => '$term*').join(' ');
  }

  static String _searchTerm(String term) {
    return term.replaceAll(RegExp(r'[^\w-]'), '');
  }

  ProductItem _productFromJson(Map<String, dynamic> json) {
    final priceRange = json['priceRange'];
    final minimumPrice = priceRange is Map<String, dynamic>
        ? priceRange['minVariantPrice']
        : null;
    if (minimumPrice is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'A Shopify search product price was missing.',
      );
    }

    final amount = double.tryParse(minimumPrice['amount'] as String? ?? '');
    if (amount == null) {
      throw const ShopifyResponseFailure(
        'A Shopify search product price was invalid.',
      );
    }

    final featuredImage = json['featuredImage'];
    final image = featuredImage is Map<String, dynamic> ? featuredImage : null;
    final collection = _firstCollection(json['collections']);

    return ProductItem(
      id: json['id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      collectionHandle: collection?.handle ?? '',
      collectionTitle: collection?.title ?? '',
      title: json['title'] as String? ?? '',
      availableForSale: json['availableForSale'] as bool? ?? false,
      price: amount,
      currencyCode: minimumPrice['currencyCode'] as String? ?? '',
      imageUrl: image?['url'] as String?,
      imageAltText: image?['altText'] as String?,
    );
  }

  _SearchCollection? _firstCollection(Object? rawCollections) {
    final nodes = rawCollections is Map<String, dynamic>
        ? rawCollections['nodes']
        : null;
    if (nodes is! List || nodes.isEmpty) return null;

    final first = nodes.whereType<Map<String, dynamic>>().firstOrNull;
    if (first == null) return null;

    return _SearchCollection(
      handle: first['handle'] as String? ?? '',
      title: first['title'] as String? ?? '',
    );
  }
}

class _SearchCollection {
  const _SearchCollection({required this.handle, required this.title});

  final String handle;
  final String title;
}
