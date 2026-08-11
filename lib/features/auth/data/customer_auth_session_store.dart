import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/customer_auth_session.dart';

class CustomerAuthSessionStore {
  const CustomerAuthSessionStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _sessionKey = 'shopify_customer_account_session';
  final FlutterSecureStorage _storage;

  Future<CustomerAuthSession?> read() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null) return null;
    try {
      return CustomerAuthSession.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> write(CustomerAuthSession session) {
    return _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
