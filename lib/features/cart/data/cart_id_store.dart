import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final cartIdStoreProvider = Provider<CartIdStore>(
  (ref) => SecureCartIdStore(),
);

abstract interface class CartIdStore {
  Future<String?> read();
  Future<void> save(String cartId);
  Future<void> clear();
}

class SecureCartIdStore implements CartIdStore {
  SecureCartIdStore({FlutterSecureStorage storage = const FlutterSecureStorage()})
    : _storage = storage;

  static const _cartIdKey = 'shopify_storefront_cart_id';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    final securedId = await _storage.read(key: _cartIdKey);
    if (securedId != null && securedId.isNotEmpty) return securedId;

    // Migrate carts persisted by older app versions out of plaintext storage.
    final preferences = await SharedPreferences.getInstance();
    final legacyId = preferences.getString(_cartIdKey);
    if (legacyId == null || legacyId.isEmpty) return null;
    await _storage.write(key: _cartIdKey, value: legacyId);
    await preferences.remove(_cartIdKey);
    return legacyId;
  }

  @override
  Future<void> save(String cartId) async {
    await _storage.write(key: _cartIdKey, value: cartId);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_cartIdKey);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _cartIdKey);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_cartIdKey);
  }
}
