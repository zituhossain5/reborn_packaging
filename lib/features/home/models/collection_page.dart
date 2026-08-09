import 'collection_item.dart';

class CollectionPageInfo {
  const CollectionPageInfo({
    required this.hasNextPage,
    required this.endCursor,
  });

  final bool hasNextPage;
  final String? endCursor;
}

class CollectionPage {
  const CollectionPage({required this.items, required this.pageInfo});

  final List<CollectionItem> items;
  final CollectionPageInfo pageInfo;
}

class CollectionCatalog {
  const CollectionCatalog({
    required this.items,
    required this.pageInfo,
    required this.pagesFetched,
  });

  final List<CollectionItem> items;
  final CollectionPageInfo pageInfo;
  final int pagesFetched;
}
