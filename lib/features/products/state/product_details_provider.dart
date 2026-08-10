import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/shopify_providers.dart';
import '../data/shopify_product_details_repository.dart';
import '../models/product_details.dart';

final shopifyProductDetailsRepositoryProvider =
    Provider<ShopifyProductDetailsRepository>(
      (ref) => ShopifyProductDetailsRepository(
        ref.watch(shopifyStorefrontClientProvider),
      ),
    );

final productDetailsProvider = FutureProvider.family<ProductDetails?, String>(
  (ref, handle) =>
      ref.watch(shopifyProductDetailsRepositoryProvider).fetchByHandle(handle),
);
