import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/checkout/presentation/payment_screen.dart';
import '../features/checkout/presentation/order_confirmation_screen.dart';
import '../features/products/presentation/collection_products_screen.dart';
import '../features/products/presentation/product_details_route_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/auth/presentation/login_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const collectionProducts = '/collections/:handle';
  static const productDetails = '/products/:handle';
  static const cart = '/cart';
  static const search = '/search';
  // Design-only mock routes. Production Cart checkout opens Shopify's
  // checkoutUrl in the platform browser and does not navigate to these routes.
  static const mockCheckoutDelivery = '/checkout';
  static const mockCheckoutPayment = '/checkout/payment';
  static const mockCheckoutConfirmation = '/checkout/confirmation';
  static const login = '/login';
  static const account = '/account';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.collectionProducts,
      builder: (context, state) {
        final handle = state.pathParameters['handle']!;
        final title = state.extra as String?;

        return CollectionProductsScreen(
          collectionTitle: title ?? handle.replaceAll('-', ' ').toUpperCase(),
          collectionHandle: handle,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      builder: (context, state) {
        final handle = state.pathParameters['handle']!;
        return ProductDetailsRouteScreen(productHandle: handle);
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.mockCheckoutDelivery,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.mockCheckoutPayment,
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: AppRoutes.mockCheckoutConfirmation,
      builder: (context, state) => const OrderConfirmationScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => const AccountScreen(),
    ),
  ],
);
