import '../../../core/errors/shopify_failure.dart';
import '../../../core/network/shopify_storefront_client.dart';
import '../models/collection_item.dart';
import '../models/collection_page.dart';

class ShopifyCollectionRepository {
  const ShopifyCollectionRepository(this._client);

  static const collectionsQuery = r'''
    query HomeCollections($first: Int!, $after: String) {
      collections(first: $first, after: $after, sortKey: TITLE) {
        nodes {
          id
          handle
          title
          image {
            url
            altText
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

  Future<CollectionPage> fetchPage({int first = 50, String? after}) async {
    final data = await _client.execute(
      collectionsQuery,
      variables: {'first': first, 'after': after},
    );
    final connection = data['collections'];
    if (connection is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'Shopify collections data was missing.',
      );
    }

    final rawNodes = connection['nodes'];
    final rawPageInfo = connection['pageInfo'];
    if (rawNodes is! List || rawPageInfo is! Map<String, dynamic>) {
      throw const ShopifyResponseFailure(
        'Shopify collections data was invalid.',
      );
    }

    final items = rawNodes
        .whereType<Map<String, dynamic>>()
        .map(CollectionItem.fromShopifyJson)
        .toList(growable: false);
    return CollectionPage(
      items: items,
      pageInfo: CollectionPageInfo(
        hasNextPage: rawPageInfo['hasNextPage'] as bool? ?? false,
        endCursor: rawPageInfo['endCursor'] as String?,
      ),
    );
  }

  Future<CollectionCatalog> fetchAll() async {
    final items = <CollectionItem>[];
    String? cursor;
    var pagesFetched = 0;
    CollectionPageInfo pageInfo;

    do {
      final page = await fetchPage(after: cursor);
      items.addAll(page.items);
      pageInfo = page.pageInfo;
      pagesFetched++;

      if (pageInfo.hasNextPage && pageInfo.endCursor == null) {
        throw const ShopifyResponseFailure(
          'Shopify pagination cursor was missing.',
        );
      }
      cursor = pageInfo.endCursor;
    } while (pageInfo.hasNextPage);

    return CollectionCatalog(
      items: List.unmodifiable(items),
      pageInfo: pageInfo,
      pagesFetched: pagesFetched,
    );
  }
}
