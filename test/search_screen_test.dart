import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reborn_packaging/features/products/widgets/product_card.dart';
import 'package:reborn_packaging/features/search/presentation/search_screen.dart';

void main() {
  testWidgets('search autofocuses, debounces, clears, and closes', (
    tester,
  ) async {
    _configureViewport(tester);
    final router = _testRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isTrue);
    expect(find.byKey(const ValueKey('product_search_field')), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('product_search_field')),
      '650',
    );
    await tester.pump(const Duration(milliseconds: 299));
    expect(find.byType(ProductCard), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(ProductCard), findsNWidgets(2));

    await tester.tap(find.bySemanticsLabel('Clear search'));
    await tester.pump();
    expect(find.text('650'), findsNothing);
    expect(find.byType(ProductCard), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('product_search_field')),
      'not-a-product',
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No products found'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Clear search'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Close search'));
    await tester.pumpAndSettle();
    expect(find.text('Open search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search result opens the existing product route', (tester) async {
    _configureViewport(tester);
    final router = _testRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('product_search_field')),
      'round',
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byType(ProductCard));
    await tester.pumpAndSettle();
    expect(find.text('Product: kraft-round-bowls'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

GoRouter _testRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/search'),
              child: const Text('Open search'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/products/:handle',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Text('Product: ${state.pathParameters['handle']}'),
          ),
        ),
      ),
    ],
  );
}

void _configureViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 42, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 42, bottom: 34);
  tester.view.viewInsets = const FakeViewPadding(bottom: 332);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetViewInsets);
}
