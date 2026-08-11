import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reborn_packaging/features/cart/presentation/cart_screen.dart';
import 'package:reborn_packaging/features/cart/state/cart_controller.dart';
import 'package:reborn_packaging/features/checkout/presentation/checkout_screen.dart';
import 'package:reborn_packaging/features/checkout/presentation/payment_screen.dart';
import 'package:reborn_packaging/features/checkout/presentation/order_confirmation_screen.dart';
import 'package:reborn_packaging/features/checkout/services/shopify_checkout_launcher.dart';
import 'package:reborn_packaging/features/products/data/mock_product_details.dart';
import 'package:reborn_packaging/features/cart/data/cart_id_store.dart';
import 'package:reborn_packaging/features/cart/data/shopify_cart_repository.dart';

import 'support/fake_cart.dart';

void main() {
  testWidgets('canceled Shopify checkout preserves cart and route', (
    tester,
  ) async {
    _configureViewport(tester);
    final router = _router();
    final checkoutLauncher = _FakeShopifyCheckoutLauncher();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(FakeCartRepository()),
          cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
          shopifyCheckoutLauncherProvider.overrideWithValue(checkoutLauncher),
        ],
        child: _SeededCheckoutApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Proceed to checkout'));
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Checkout'), findsNothing);
    expect(checkoutLauncher.presentCalls, 1);
    expect(checkoutLauncher.lastCheckoutUrl, 'https://example.test/checkout');
    final cartContext = tester.element(find.text('My Cart'));
    expect(
      ProviderScope.containerOf(cartContext).read(cartControllerProvider).items,
      isNotEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed Shopify checkout clears cart and confirms order', (
    tester,
  ) async {
    _configureViewport(tester);
    final router = _router();
    final checkoutLauncher = _FakeShopifyCheckoutLauncher(
      result: const ShopifyCheckoutResult.completed(
        ShopifyCheckoutCompletion(
          orderId: 'gid://shopify/Order/20843',
          itemCount: 1,
          totalAmount: 71.93,
          currencyCode: 'GBP',
        ),
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(FakeCartRepository()),
          cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
          shopifyCheckoutLauncherProvider.overrideWithValue(checkoutLauncher),
        ],
        child: _SeededCheckoutApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Proceed to checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Order placed!'), findsOneWidget);
    expect(find.text('20843'), findsOneWidget);
    expect(find.text('#RP-20843'), findsNothing);
    final confirmationContext = tester.element(find.text('Order placed!'));
    expect(
      ProviderScope.containerOf(
        confirmationContext,
      ).read(cartControllerProvider).items,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('checkout summary, form validation, and fixed CTA work', (
    tester,
  ) async {
    _configureViewport(tester);
    final router = _router(initialLocation: '/checkout');
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(FakeCartRepository()),
          cartIdStoreProvider.overrideWithValue(MemoryCartIdStore()),
        ],
        child: _SeededCheckoutApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsNothing);
    await tester.tap(find.text('Order summary (1 item)'));
    await tester.pumpAndSettle();
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('\u00A371.93'), findsNWidgets(2));

    final ctaTop = tester.getTopLeft(find.text('Continue to payment')).dy;
    await tester.tap(find.text('Continue to payment'));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(5));

    await _enter(tester, 'checkout_contact', 'customer@example.com');
    await _enter(tester, 'checkout_last_name', 'Customer');
    await _enter(tester, 'checkout_address', '1 High Street');
    await _enter(tester, 'checkout_city', 'London');
    await _enter(tester, 'checkout_postcode', 'SW1A 1AA');

    await tester.ensureVisible(find.text('Shipping method'));
    await tester.pumpAndSettle();
    expect(find.text('Standard delivery'), findsOneWidget);
    expect(find.text('2 to 4 business days'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Continue to payment')).dy, ctaTop);

    await tester.tap(find.text('Continue to payment'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsNothing);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Pay now — £71.93'), findsOneWidget);
    expect(find.text('Card number'), findsOneWidget);

    await tester.tap(find.text('PayPal'));
    await tester.pumpAndSettle();
    expect(find.text('Card number'), findsNothing);
    expect(
      find.text("You'll be redirected to PayPal to complete your purchase"),
      findsOneWidget,
    );

    await tester.tap(find.text('Credit card'));
    await tester.pumpAndSettle();
    expect(find.text('Card number'), findsOneWidget);
    expect(
      find.text("You'll be redirected to PayPal to complete your purchase"),
      findsNothing,
    );

    await tester.tap(find.text('Pay now — £71.93'));
    await tester.pumpAndSettle();
    expect(find.text('Order placed!'), findsOneWidget);
    expect(find.text('#RP-20843'), findsOneWidget);
    expect(find.text('1 product'), findsOneWidget);
    expect(find.text('£71.93'), findsOneWidget);

    await tester.tap(find.text('View order details'));
    await tester.pump();
    expect(find.text('Order placed!'), findsOneWidget);

    await tester.tap(find.text('Continue shopping'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    final homeContext = tester.element(find.text('Home'));
    expect(
      ProviderScope.containerOf(homeContext).read(cartControllerProvider).items,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });
}

class _FakeShopifyCheckoutLauncher implements ShopifyCheckoutLauncher {
  _FakeShopifyCheckoutLauncher({
    this.result = const ShopifyCheckoutResult.canceled(),
  });

  final ShopifyCheckoutResult result;
  int presentCalls = 0;
  String? lastCheckoutUrl;

  @override
  Future<ShopifyCheckoutResult> present(String checkoutUrl) async {
    presentCalls++;
    lastCheckoutUrl = checkoutUrl;
    return result;
  }
}

class _SeededCheckoutApp extends ConsumerStatefulWidget {
  const _SeededCheckoutApp({required this.router});

  final GoRouter router;

  @override
  ConsumerState<_SeededCheckoutApp> createState() => _SeededCheckoutAppState();
}

class _SeededCheckoutAppState extends ConsumerState<_SeededCheckoutApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(cartControllerProvider.notifier)
          .addVariant(
            product: mockKraftRoundBowlsProduct,
            variant: mockKraftRoundBowlsProduct.selectedVariant,
            quantity: 1,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: widget.router);
  }
}

GoRouter _router({String initialLocation = '/cart'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/checkout/confirmation',
        builder: (context, state) => OrderConfirmationScreen(
          completion: state.extra as ShopifyCheckoutCompletion?,
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('Home')),
      ),
    ],
  );
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, value);
  await tester.pump();
}

void _configureViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 42, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 42, bottom: 34);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
}
