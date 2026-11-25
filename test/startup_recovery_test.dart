import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/app/app.dart';
import 'package:reborn_packaging/app/router.dart';
import 'package:reborn_packaging/core/config/shopify_config.dart';
import 'package:reborn_packaging/core/errors/shopify_failure.dart';
import 'package:reborn_packaging/core/network/shopify_providers.dart';
import 'package:reborn_packaging/core/network/shopify_storefront_client.dart';
import 'package:reborn_packaging/features/auth/config/customer_account_config.dart';
import 'package:reborn_packaging/features/auth/models/customer_auth_session.dart';
import 'package:reborn_packaging/features/auth/state/customer_auth_controller.dart';
import 'package:reborn_packaging/features/cart/data/cart_id_store.dart';
import 'package:reborn_packaging/features/home/data/shopify_collection_repository.dart';
import 'package:reborn_packaging/features/home/widgets/collection_card.dart';

import 'support/fake_cart.dart';

const _sessionKey = 'shopify_customer_account_session';

void main() {
  testWidgets('missing Storefront defines leave splash and Home usable', (
    tester,
  ) async {
    final container = await _launch(tester, config: _missingConfig);

    expect(container.read(customerAuthControllerProvider).requireValue, isNull);
    expect(find.text('Unable to load collections.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(ErrorWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('en', 'GB'), Locale('bn', 'BD')]) {
    for (final failure in const [
      ShopifyNetworkFailure('Offline'),
      ShopifyTimeoutFailure('Timed out'),
    ]) {
      testWidgets('$locale ${failure.runtimeType} supports Retry', (
        tester,
      ) async {
        tester.binding.platformDispatcher.localeTestValue = locale;
        addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
        final store = _FakeStorefront(() => throw failure);
        await _launch(tester, store: store);

        expect(find.text('Unable to load collections.'), findsOneWidget);
        expect(store.calls, 1);
        store.response = () => _collections([
          'napkins',
          'hinged-lid-sauce-pots',
          'white-round-bowls',
          'kraft-round-bowls',
        ]);
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(store.calls, 2);
        expect(find.text('4 collections'), findsOneWidget);
        expect(
          tester.getTopLeft(_card('kraft-round-bowls')).dx,
          lessThan(tester.getTopLeft(_card('white-round-bowls')).dx),
        );
        expect(_card('hinged-lid-sauce-pots'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final session in ['valid', 'expired', 'malformed']) {
    testWidgets('$session stored session does not block startup', (
      tester,
    ) async {
      final container = await _launch(
        tester,
        storedSession: session == 'malformed'
            ? '{bad json'
            : jsonEncode(
                CustomerAuthSession(
                  accessToken: 'fixture-access',
                  refreshToken: null,
                  idToken: 'fixture-id',
                  expiresAt: DateTime.now().toUtc().add(
                    Duration(hours: session == 'valid' ? 1 : -1),
                  ),
                ).toJson(),
              ),
        store: _FakeStorefront(() => _collections([])),
      );

      expect(find.text('No collections found.'), findsOneWidget);
      final restored = container.read(customerAuthControllerProvider);
      expect(restored.hasValue, isTrue);
      expect(restored.value != null, session == 'valid');
      expect(tester.takeException(), isNull);
    });
  }

  test('invalid collection connection fails explicitly', () async {
    final repository = ShopifyCollectionRepository(_FakeStorefront(() => {}));
    await expectLater(
      repository.fetchAll(),
      throwsA(isA<ShopifyResponseFailure>()),
    );
  });

  test('repeated pagination cursor stops instead of loading forever', () async {
    final store = _FakeStorefront(() => _collections([], nextCursor: 'same'));
    await expectLater(
      ShopifyCollectionRepository(store).fetchAll(),
      throwsA(isA<ShopifyResponseFailure>()),
    );
    expect(store.calls, 2);
  });
}

const _missingConfig = ShopifyConfig(
  storeDomain: '',
  apiVersion: '',
  storefrontToken: '',
);

Future<ProviderContainer> _launch(
  WidgetTester tester, {
  _FakeStorefront? store,
  ShopifyConfig? config,
  String? storedSession,
}) async {
  FlutterSecureStorage.setMockInitialValues({_sessionKey: ?storedSession});
  addTearDown(() => FlutterSecureStorage.setMockInitialValues({}));
  final container = ProviderContainer(
    overrides: [
      cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
      customerAccountConfigProvider.overrideWithValue(
        const CustomerAccountConfig(
          storeDomain: '',
          clientId: '',
          redirectUri: null,
          scopes: [],
        ),
      ),
      if (config != null)
        shopifyConfigProvider.overrideWith((ref) {
          config.validate();
          return config;
        }),
      if (store != null)
        shopifyStorefrontClientProvider.overrideWithValue(store),
    ],
  );
  addTearDown(container.dispose);
  appRouter.go(AppRoutes.splash);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const RebornPackagingApp(),
    ),
  );
  await tester.pump();
  expect(find.byType(Image), findsOneWidget);
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  expect(find.text('PRODUCT COLLECTIONS'), findsOneWidget);
  return container;
}

class _FakeStorefront extends ShopifyStorefrontClient {
  _FakeStorefront(this.response) : super(_missingConfig, httpClient: _NoHttp());

  Map<String, dynamic> Function() response;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> execute(
    String query, {
    Map<String, dynamic> variables = const {},
  }) async {
    calls++;
    return response();
  }
}

class _NoHttp implements HttpClient {
  @override
  set connectionTimeout(Duration? value) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Finder _card(String handle) => find.byWidgetPredicate(
  (widget) => widget is CollectionCard && widget.item.handle == handle,
);

Map<String, dynamic> _collections(
  List<String> handles, {
  String? nextCursor,
}) => {
  'collections': {
    'nodes': [
      for (final handle in handles)
        <String, dynamic>{
          'handle': handle,
          'title': handle.replaceAll('-', ' '),
        },
    ],
    'pageInfo': {'hasNextPage': nextCursor != null, 'endCursor': nextCursor},
  },
};
