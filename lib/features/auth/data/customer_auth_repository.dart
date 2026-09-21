import 'dart:async';
import 'dart:convert';
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

  static const Duration _networkTimeout = Duration(seconds: 20);

  final CustomerAccountConfig _config;
  final CustomerAccountDiscoveryService _discoveryService;
  final CustomerAuthSessionStore _sessionStore;
  final FlutterAppAuth _appAuth;

  CustomerAccountDiscovery? _discovery;

  @override
  Future<CustomerAuthSession?> restoreSession() async {
    final session = await _sessionStore.read();

    if (session == null || !session.isExpired) {
      return session;
    }

    // Some Shopify customer account clients can return a refresh token.
    // If one exists, continue supporting it.
    if (session.refreshToken != null && session.refreshToken!.isNotEmpty) {
      try {
        return await _refresh(session.refreshToken!);
      } catch (_) {
        // Fall through and try silent authorization below.
      }
    }

    // Shopify app clients don't normally receive refresh tokens.
    // Re-run authorization silently while the Shopify browser session exists.
    try {
      _config.validate();
      final discovery = await _getDiscovery();

      return await _authorizeAndCreateSession(
        discovery,
        promptValues: const ['none'],
      );
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
      return await _authorizeAndCreateSession(
        discovery,
        loginHint: loginHint,
        promptValues: const ['login'],
      );
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
    } catch (error) {
      if (kDebugMode) {
        throw CustomerAuthException(
          'Shopify sign in failed: ${error.runtimeType}.',
        );
      }

      throw const CustomerAuthException(
        'Shopify sign in could not be completed. Please try again.',
      );
    }
  }

  Future<CustomerAuthSession> _authorizeAndCreateSession(
    CustomerAccountDiscovery discovery, {
    String? loginHint,
    required List<String> promptValues,
  }) async {
    // Android is already working correctly in production.
    // Keep the existing automatic AppAuth token exchange there.
    if (!Platform.isIOS) {
      final response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _config.clientId,
          _config.redirectUri!.toString(),
          serviceConfiguration: _serviceConfiguration(discovery),
          scopes: _config.scopes,
          loginHint: _normalizedLoginHint(loginHint),
          promptValues: promptValues,
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
    }

    // iOS:
    // Only let AppAuth perform the authorization request and PKCE generation.
    //
    // Do NOT use authorizeAndExchangeCode() here because AppAuth iOS attempts
    // to parse Shopify's ID token during the automatic token exchange and
    // currently fails with ID Token parsing error (-14).
    final authorization = await _appAuth.authorize(
      AuthorizationRequest(
        _config.clientId,
        _config.redirectUri!.toString(),
        serviceConfiguration: _serviceConfiguration(discovery),
        scopes: _config.scopes,
        loginHint: _normalizedLoginHint(loginHint),
        promptValues: promptValues,
      ),
    );

    final authorizationCode = authorization.authorizationCode;
    final codeVerifier = authorization.codeVerifier;

    if (authorizationCode == null ||
        authorizationCode.isEmpty ||
        codeVerifier == null ||
        codeVerifier.isEmpty) {
      throw const CustomerAuthException(
        'Shopify authorization did not return the required PKCE information.',
      );
    }

    final tokenResponse = await _exchangeAuthorizationCode(
      discovery,
      authorizationCode: authorizationCode,
      codeVerifier: codeVerifier,
    );

    final session = _sessionFromTokenPayload(tokenResponse);

    await _sessionStore.write(session);

    return session;
  }

  Future<Map<String, dynamic>> _exchangeAuthorizationCode(
    CustomerAccountDiscovery discovery, {
    required String authorizationCode,
    required String codeVerifier,
  }) async {
    final client = HttpClient()..connectionTimeout = _networkTimeout;

    try {
      final request = await client
          .postUrl(discovery.tokenEndpoint)
          .timeout(_networkTimeout);

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );

      request.headers.set(HttpHeaders.userAgentHeader, 'RebornPackaging/1.0');

      final formBody = Uri(
        queryParameters: {
          'grant_type': 'authorization_code',
          'client_id': _config.clientId,
          'redirect_uri': _config.redirectUri!.toString(),
          'code': authorizationCode,
          'code_verifier': codeVerifier,
        },
      ).query;

      final encodedBody = utf8.encode(formBody);

      request.contentLength = encodedBody.length;
      request.add(encodedBody);

      final response = await request.close().timeout(_networkTimeout);

      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(_networkTimeout);

      Map<String, dynamic>? decoded;

      if (body.isNotEmpty) {
        try {
          final value = jsonDecode(body);

          if (value is Map<String, dynamic>) {
            decoded = value;
          }
        } catch (_) {
          // Handle below using a safe generic failure.
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final serverError = decoded == null
            ? null
            : _safeTokenEndpointError(decoded);

        if (kDebugMode && serverError != null) {
          throw CustomerAuthException(
            'Shopify token exchange failed '
            '(${response.statusCode}): $serverError',
          );
        }

        throw CustomerAuthException(
          'Shopify token exchange failed (${response.statusCode}).',
        );
      }

      if (decoded == null) {
        throw const CustomerAuthException(
          'Shopify returned an invalid token response.',
        );
      }

      return decoded;
    } on CustomerAuthException {
      rethrow;
    } on TimeoutException {
      throw const CustomerAuthException(
        'Shopify sign in timed out. Please try again.',
      );
    } on SocketException {
      throw const CustomerAuthException(
        'Unable to connect to Shopify. Please check your connection.',
      );
    } finally {
      client.close(force: true);
    }
  }

  CustomerAuthSession _sessionFromTokenPayload(Map<String, dynamic> payload) {
    final accessToken = _stringValue(payload['access_token']);
    final refreshToken = _stringValue(payload['refresh_token']);
    final idToken = _stringValue(payload['id_token']);

    final expiresInValue = payload['expires_in'];

    final expiresInSeconds = expiresInValue is int
        ? expiresInValue
        : int.tryParse(expiresInValue?.toString() ?? '');

    final expiresAt = expiresInSeconds == null
        ? null
        : DateTime.now().toUtc().add(Duration(seconds: expiresInSeconds));

    return _sessionFromResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: expiresAt,
    );
  }

  String? _stringValue(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  String? _safeTokenEndpointError(Map<String, dynamic> payload) {
    final value =
        _stringValue(payload['error_description']) ??
        _stringValue(payload['error']);

    if (value == null) {
      return null;
    }

    return value
        .replaceAll(RegExp(r'https?://\S+'), '[redacted URL]')
        .replaceAllMapped(
          RegExp(
            r'(code|token|verifier|state|redirect_uri)=[^&\s]+',
            caseSensitive: false,
          ),
          (match) => '${match.group(1)}=[redacted]',
        )
        .trim();
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
