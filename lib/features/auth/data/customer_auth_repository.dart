import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../config/customer_account_config.dart';
import '../models/customer_account_discovery.dart';
import '../models/customer_auth_session.dart';
import 'customer_account_discovery_service.dart';
import 'customer_auth_session_store.dart';

abstract interface class CustomerAuthRepository {
  Future<CustomerAuthSession?> restoreSession();

  Future<CustomerAuthSession> signIn({String? loginHint});

  Future<void> signOut(CustomerAuthSession? session);
}

class ShopifyCustomerAuthRepository implements CustomerAuthRepository {
  ShopifyCustomerAuthRepository({
    required CustomerAccountConfig config,
    CustomerAccountDiscoveryService discoveryService =
        const CustomerAccountDiscoveryService(),
    CustomerAuthSessionStore sessionStore = const CustomerAuthSessionStore(),
    FlutterAppAuth appAuth = const FlutterAppAuth(),
  }) : this._(config, discoveryService, sessionStore, appAuth);

  ShopifyCustomerAuthRepository._(
    this._config,
    this._discoveryService,
    this._sessionStore,
    this._appAuth,
  );

  final CustomerAccountConfig _config;
  final CustomerAccountDiscoveryService _discoveryService;
  final CustomerAuthSessionStore _sessionStore;
  final FlutterAppAuth _appAuth;

  CustomerAccountDiscovery? _discovery;

  @override
  Future<CustomerAuthSession?> restoreSession() async {
    final session = await _sessionStore.read();
    if (session == null || !session.isExpired) return session;
    if (session.refreshToken == null || session.refreshToken!.isEmpty) {
      await _sessionStore.clear();
      return null;
    }

    try {
      return await _refresh(session.refreshToken!);
    } catch (_) {
      await _sessionStore.clear();
      return null;
    }
  }

  @override
  Future<CustomerAuthSession> signIn({String? loginHint}) async {
    _config.validate();
    final discovery = await _getDiscovery();
    try {
      final response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _config.clientId,
          _config.redirectUri!.toString(),
          serviceConfiguration: _serviceConfiguration(discovery),
          scopes: _config.scopes,
          loginHint: _normalizedLoginHint(loginHint),
          promptValues: const ['login'],
        ),
      );
      final session = _sessionFromResponse(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        idToken: response.idToken,
        expiresAt: response.accessTokenExpirationDateTime,
      );
      await _sessionStore.write(session);
      return session;
    } on FlutterAppAuthUserCancelledException {
      throw const CustomerAuthCanceledException();
    } on FlutterAppAuthPlatformException catch (error) {
      if (kDebugMode) {
        throw CustomerAuthException(_safeAppAuthFailure(error));
      }
      throw const CustomerAuthException(
        'Shopify sign in could not be completed. Please try again.',
      );
    } on CustomerAuthException {
      rethrow;
    } catch (_) {
      throw const CustomerAuthException(
        'Shopify sign in could not be completed. Please try again.',
      );
    }
  }

  String? _normalizedLoginHint(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _safeAppAuthFailure(FlutterAppAuthPlatformException exception) {
    final details = exception.platformErrorDetails;
    final code = details.error ?? details.code ?? exception.code;
    final rawDescription = details.errorDescription ?? exception.message;
    final description = rawDescription
        ?.replaceAll(RegExp(r'https?://\S+'), '[redacted URL]')
        .replaceAllMapped(
          RegExp(
            r'(code|token|verifier|state|redirect_uri)=[^&\s]+',
            caseSensitive: false,
          ),
          (match) => '${match.group(1)}=[redacted]',
        )
        .trim();
    return description == null || description.isEmpty
        ? 'Shopify sign in failed ($code).'
        : 'Shopify sign in failed ($code): $description';
  }

  @override
  Future<void> signOut(CustomerAuthSession? session) async {
    try {
      if (session != null && session.idToken.isNotEmpty) {
        _config.validate();
        final discovery = await _getDiscovery();
        final logoutUri = discovery.logoutEndpoint.replace(
          queryParameters: {'id_token_hint': session.idToken},
        );
        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 15);
        try {
          final request = await client.getUrl(logoutUri);
          request.headers.set(
            HttpHeaders.userAgentHeader,
            'RebornPackaging/1.0',
          );
          await request.close().timeout(const Duration(seconds: 15));
        } finally {
          client.close(force: true);
        }
      }
    } catch (_) {
      // Local session removal must still complete if Shopify is unreachable.
    } finally {
      await _sessionStore.clear();
    }
  }

  Future<CustomerAuthSession> _refresh(String refreshToken) async {
    _config.validate();
    final discovery = await _getDiscovery();
    final response = await _appAuth.token(
      TokenRequest(
        _config.clientId,
        _config.redirectUri!.toString(),
        refreshToken: refreshToken,
        serviceConfiguration: _serviceConfiguration(discovery),
        scopes: _config.scopes,
      ),
    );
    final session = _sessionFromResponse(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken ?? refreshToken,
      idToken: response.idToken,
      expiresAt: response.accessTokenExpirationDateTime,
    );
    await _sessionStore.write(session);
    return session;
  }

  Future<CustomerAccountDiscovery> _getDiscovery() async {
    return _discovery ??= await _discoveryService.discover(_config);
  }

  AuthorizationServiceConfiguration _serviceConfiguration(
    CustomerAccountDiscovery discovery,
  ) {
    return AuthorizationServiceConfiguration(
      authorizationEndpoint: discovery.authorizationEndpoint.toString(),
      tokenEndpoint: discovery.tokenEndpoint.toString(),
      endSessionEndpoint: discovery.logoutEndpoint.toString(),
    );
  }

  CustomerAuthSession _sessionFromResponse({
    required String? accessToken,
    required String? refreshToken,
    required String? idToken,
    required DateTime? expiresAt,
  }) {
    if (accessToken == null ||
        accessToken.isEmpty ||
        idToken == null ||
        idToken.isEmpty ||
        expiresAt == null) {
      throw const CustomerAuthException(
        'Shopify returned an incomplete customer session.',
      );
    }
    return CustomerAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: expiresAt.toUtc(),
    );
  }
}
