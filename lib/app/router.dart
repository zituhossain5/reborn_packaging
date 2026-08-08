import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/products/data/mock_product_details.dart';
import '../features/products/presentation/collection_products_screen.dart';
import '../features/products/presentation/product_details_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const collectionProducts = '/collections/:handle';
  static const productDetails = '/products/:handle';
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
        final product = mockProductDetailsForHandle(handle)!;

        return ProductDetailsScreen(product: product);
      },
    ),
  ],
);
