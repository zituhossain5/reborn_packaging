import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/shopify_providers.dart';
import '../data/shopify_collection_repository.dart';
import '../models/collection_page.dart';

final shopifyCollectionRepositoryProvider =
    Provider<ShopifyCollectionRepository>(
      (ref) => ShopifyCollectionRepository(
        ref.watch(shopifyStorefrontClientProvider),
      ),
    );

final homeCollectionsProvider = FutureProvider<CollectionCatalog>(
  (ref) => ref.watch(shopifyCollectionRepositoryProvider).fetchAll(),
);
