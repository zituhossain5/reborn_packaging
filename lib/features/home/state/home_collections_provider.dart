import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;

import '../../../core/errors/shopify_failure.dart';
import '../../../core/network/shopify_providers.dart';
import '../data/shopify_collection_repository.dart';
import '../models/collection_page.dart';

final shopifyCollectionRepositoryProvider =
    Provider<ShopifyCollectionRepository>(
      (ref) => ShopifyCollectionRepository(
        ref.watch(shopifyStorefrontClientProvider),
      ),
    );

final homeCollectionsProvider = FutureProvider<CollectionCatalog>((ref) async {
  try {
    return await ref.watch(shopifyCollectionRepositoryProvider).fetchAll();
  } catch (error) {
    // Log only the failure category and HTTP status, never the response body.
    var cause = error;
    while (cause is ProviderException) {
      cause = cause.exception;
    }
    final status = cause is ShopifyHttpFailure ? ' (${cause.statusCode})' : '';
    debugPrint('Home collections load failed: ${cause.runtimeType}$status');
    rethrow;
  }
}, retry: (_, _) => null);
