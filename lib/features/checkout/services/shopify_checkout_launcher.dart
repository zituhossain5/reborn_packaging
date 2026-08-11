import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final shopifyCheckoutLauncherProvider = Provider<ShopifyCheckoutLauncher>(
  (ref) => const PlatformShopifyCheckoutLauncher(),
);

abstract interface class ShopifyCheckoutLauncher {
  Future<ShopifyCheckoutResult> present(String checkoutUrl);
}

class PlatformShopifyCheckoutLauncher implements ShopifyCheckoutLauncher {
  const PlatformShopifyCheckoutLauncher();

  static const _channel = MethodChannel(
    'com.rebornpackaging.reborn_packaging/shopify_checkout',
  );

  @override
  Future<ShopifyCheckoutResult> present(String checkoutUrl) async {
    final uri = Uri.tryParse(checkoutUrl.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return const ShopifyCheckoutResult.failed('Checkout is unavailable.');
    }

    final usesNativeCheckoutKit =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (usesNativeCheckoutKit) {
      try {
        final response = await _channel.invokeMapMethod<String, dynamic>(
          'presentCheckout',
          <String, String>{'checkoutUrl': checkoutUrl},
        );
        return ShopifyCheckoutResult.fromNative(response);
      } on PlatformException catch (error) {
        return ShopifyCheckoutResult.failed(_messageForCode(error.code));
      } on MissingPluginException {
        return const ShopifyCheckoutResult.failed(
          'In-app checkout is unavailable. Please restart the app and try again.',
        );
      }
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    return opened
        ? const ShopifyCheckoutResult.externalOpened()
        : const ShopifyCheckoutResult.failed('Unable to open checkout.');
  }

  static String _messageForCode(String code) => switch (code) {
    'checkout_already_presented' => 'Checkout is already open.',
    'invalid_checkout_url' => 'Checkout is unavailable.',
    'cart_expired' || 'cart_completed' || 'invalid_cart' =>
      'This checkout is no longer available. Please refresh your cart.',
    _ => 'Checkout could not be opened. Please try again.',
  };
}

enum ShopifyCheckoutStatus { completed, canceled, failed, externalOpened }

class ShopifyCheckoutResult {
  const ShopifyCheckoutResult._(this.status, [this.message, this.completion]);

  const ShopifyCheckoutResult.completed([ShopifyCheckoutCompletion? completion])
    : this._(ShopifyCheckoutStatus.completed, null, completion);

  const ShopifyCheckoutResult.canceled()
    : this._(ShopifyCheckoutStatus.canceled);

  const ShopifyCheckoutResult.failed(String message)
    : this._(ShopifyCheckoutStatus.failed, message);

  const ShopifyCheckoutResult.externalOpened()
    : this._(ShopifyCheckoutStatus.externalOpened);

  factory ShopifyCheckoutResult.fromNative(Map<String, dynamic>? response) {
    final event = response?['event'];
    return switch (event) {
      'checkoutCompleted' => ShopifyCheckoutResult.completed(
        ShopifyCheckoutCompletion.fromNative(response),
      ),
      'checkoutCanceled' => const ShopifyCheckoutResult.canceled(),
      'checkoutFailed' => ShopifyCheckoutResult.failed(
        PlatformShopifyCheckoutLauncher._messageForCode(
          response?['errorCode'] as String? ?? 'unknown',
        ),
      ),
      _ => const ShopifyCheckoutResult.failed(
        'Checkout ended unexpectedly. Please try again.',
      ),
    };
  }

  final ShopifyCheckoutStatus status;
  final String? message;
  final ShopifyCheckoutCompletion? completion;
}

class ShopifyCheckoutCompletion {
  const ShopifyCheckoutCompletion({
    this.orderId,
    this.itemCount,
    this.totalAmount,
    this.currencyCode,
  });

  factory ShopifyCheckoutCompletion.fromNative(Map<String, dynamic>? response) {
    return ShopifyCheckoutCompletion(
      orderId: response?['orderId'] as String?,
      itemCount: (response?['itemCount'] as num?)?.toInt(),
      totalAmount: (response?['totalAmount'] as num?)?.toDouble(),
      currencyCode: response?['currencyCode'] as String?,
    );
  }

  final String? orderId;
  final int? itemCount;
  final double? totalAmount;
  final String? currencyCode;
}
