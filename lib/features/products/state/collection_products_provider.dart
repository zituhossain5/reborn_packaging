import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/shopify_providers.dart';
import '../data/shopify_collection_products_repository.dart';
import '../models/product_page.dart';

final shopifyCollectionProductsRepositoryProvider =
    Provider<ShopifyCollectionProductsRepository>(
      (ref) => ShopifyCollectionProductsRepository(
        ref.watch(shopifyStorefrontClientProvider),
      ),
    );

final collectionProductsProvider =
    FutureProvider.family<ProductCatalog, String>(
      (ref, collectionHandle) => ref
          .watch(shopifyCollectionProductsRepositoryProvider)
          .fetchAll(collectionHandle),
    );
