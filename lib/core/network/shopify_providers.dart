import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/shopify_config.dart';
import 'shopify_storefront_client.dart';

final shopifyConfigProvider = Provider<ShopifyConfig>(
  (ref) => ShopifyConfig.fromEnvironment(),
  // Compile-time settings cannot change while the app is running.
  retry: (_, _) => null,
);

final shopifyStorefrontClientProvider = Provider<ShopifyStorefrontClient>((
  ref,
) {
  final client = ShopifyStorefrontClient(ref.watch(shopifyConfigProvider));
  ref.onDispose(client.close);
  return client;
});
