import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final cartIdStoreProvider = Provider<CartIdStore>(
  (ref) => SharedPreferencesCartIdStore(),
);

abstract interface class CartIdStore {
  Future<String?> read();
  Future<void> save(String cartId);
  Future<void> clear();
}

class SharedPreferencesCartIdStore implements CartIdStore {
  static const _cartIdKey = 'shopify_storefront_cart_id';

  @override
  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_cartIdKey);
  }

  @override
  Future<void> save(String cartId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cartIdKey, cartId);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_cartIdKey);
  }
}
