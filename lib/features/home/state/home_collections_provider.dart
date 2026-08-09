import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/shopify_config.dart';
import '../../../core/network/shopify_storefront_client.dart';
import '../data/shopify_collection_repository.dart';
import '../models/collection_page.dart';

final shopifyConfigProvider = Provider<ShopifyConfig>(
  (ref) => ShopifyConfig.fromEnvironment(),
);

final shopifyStorefrontClientProvider = Provider<ShopifyStorefrontClient>((
  ref,
) {
  final client = ShopifyStorefrontClient(ref.watch(shopifyConfigProvider));
  ref.onDispose(client.close);
  return client;
});

final shopifyCollectionRepositoryProvider =
    Provider<ShopifyCollectionRepository>(
      (ref) => ShopifyCollectionRepository(
        ref.watch(shopifyStorefrontClientProvider),
      ),
    );

final homeCollectionsProvider = FutureProvider<CollectionCatalog>(
  (ref) => ref.watch(shopifyCollectionRepositoryProvider).fetchAll(),
);
