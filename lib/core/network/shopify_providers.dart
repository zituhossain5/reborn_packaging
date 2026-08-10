import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/shopify_config.dart';
import 'shopify_storefront_client.dart';

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
