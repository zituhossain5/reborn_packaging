import '../../../core/config/cart_pricing_config.dart';
import 'cart_item.dart';
import 'shopify_cart.dart';

class CartSummary {
  CartSummary._({
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.estimatedTaxes,
    required this.total,
    this.shippingAvailable = true,
    this.estimatedTaxesAvailable = true,
  });

  factory CartSummary.calculate({
    required List<CartItem> items,
    double requestedDiscount = 0,
  }) {
    final subtotal = _money(
      items.fold<double>(0, (total, item) => total + item.linePrice),
    );
    final discount = _money(requestedDiscount.clamp(0, subtotal).toDouble());
    final taxableSubtotal = subtotal - discount;
    final shipping =
        subtotal > 0 && subtotal < CartPricingConfig.freeShippingThreshold
        ? CartPricingConfig.standardShippingFee
        : 0.0;
    final estimatedTaxes = _money(
      taxableSubtotal * CartPricingConfig.estimatedTaxRate,
    );

    return CartSummary._(
      subtotal: subtotal,
      discount: discount,
      shipping: shipping,
      estimatedTaxes: estimatedTaxes,
      total: _money(taxableSubtotal + shipping + estimatedTaxes),
    );
  }

  factory CartSummary.fromShopifyCart(ShopifyCart cart) {
    final subtotal = _money(cart.cost.subtotalAmount.amount);
    return CartSummary._(
      subtotal: subtotal,
      discount: 0,
      shipping: 0,
      estimatedTaxes: _money(cart.cost.totalTaxAmount?.amount ?? 0),
      total: _money(cart.cost.totalAmount.amount),
      shippingAvailable: false,
      estimatedTaxesAvailable: cart.cost.totalTaxAmount != null,
    );
  }

  final double subtotal;
  final double discount;
  final double shipping;
  final double estimatedTaxes;
  final double total;
  final bool shippingAvailable;
  final bool estimatedTaxesAvailable;

  double get freeShippingRemaining => _money(
    (CartPricingConfig.freeShippingThreshold - subtotal).clamp(
      0,
      CartPricingConfig.freeShippingThreshold,
    ),
  );

  double get freeShippingProgress =>
      (subtotal / CartPricingConfig.freeShippingThreshold).clamp(0, 1);

  bool get showsFreeShippingProgress =>
      subtotal > 0 && subtotal < CartPricingConfig.freeShippingThreshold;

  static double _money(double value) => (value * 100).round() / 100;
}
