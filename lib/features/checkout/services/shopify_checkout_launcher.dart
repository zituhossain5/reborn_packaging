import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final shopifyCheckoutLauncherProvider = Provider<ShopifyCheckoutLauncher>(
  (ref) => const PlatformShopifyCheckoutLauncher(),
);

abstract interface class ShopifyCheckoutLauncher {
  Future<bool> open(String checkoutUrl);
}

class PlatformShopifyCheckoutLauncher implements ShopifyCheckoutLauncher {
  const PlatformShopifyCheckoutLauncher();

  @override
  Future<bool> open(String checkoutUrl) {
    final uri = Uri.tryParse(checkoutUrl.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return Future.value(false);
    }

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
