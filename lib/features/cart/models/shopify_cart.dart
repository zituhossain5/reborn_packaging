class ShopifyCart {
  const ShopifyCart({
    required this.id,
    required this.totalQuantity,
    required this.checkoutUrl,
    required this.lines,
    required this.cost,
    required this.discountCodes,
    this.hasAuthenticatedBuyer = false,
    this.warnings = const [],
  });

  final String id;
  final int totalQuantity;
  final String checkoutUrl;
  final List<CartLine> lines;
  final CartCost cost;
  final List<CartDiscountCode> discountCodes;
  final bool hasAuthenticatedBuyer;
  final List<ShopifyCartWarning> warnings;
}

class CartLine {
  const CartLine({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.productHandle,
    required this.productTitle,
    required this.variantTitle,
    required this.selectedOptions,
    required this.imageUrl,
    required this.unitPrice,
    required this.cost,
    required this.quantity,
    required this.availableForSale,
    required this.quantityRule,
    this.sku,
  });

  final String id;
  final String variantId;
  final String productId;
  final String productHandle;
  final String productTitle;
  final String variantTitle;
  final List<CartSelectedOption> selectedOptions;
  final String imageUrl;
  final MoneyAmount unitPrice;
  final CartLineCost cost;
  final int quantity;
  final bool availableForSale;
  final CartQuantityRule quantityRule;
  final String? sku;

  String get lineId => id;
  String get imageAsset => imageUrl;
  double get priceExVat => unitPrice.amount;
  double get linePrice => cost.totalAmount.amount;
  int? get piecesPerPack => null;

  String get size => _optionValue('size');
  String get lid => _optionValue('lid');

  String _optionValue(String name) {
    final normalizedName = name.toLowerCase();
    for (final option in selectedOptions) {
      if (option.name.toLowerCase() == normalizedName) return option.value;
    }
    return '';
  }
}

class CartSelectedOption {
  const CartSelectedOption({required this.name, required this.value});

  final String name;
  final String value;
}

class CartQuantityRule {
  const CartQuantityRule({
    required this.minimum,
    required this.increment,
    this.maximum,
  });

  final int minimum;
  final int increment;
  final int? maximum;
}

class MoneyAmount {
  const MoneyAmount({required this.amount, required this.currencyCode});

  final double amount;
  final String currencyCode;
}

class CartLineCost {
  const CartLineCost({required this.subtotalAmount, required this.totalAmount});

  final MoneyAmount subtotalAmount;
  final MoneyAmount totalAmount;
}

class CartCost {
  const CartCost({
    required this.subtotalAmount,
    required this.totalAmount,
    this.totalTaxAmount,
  });

  final MoneyAmount subtotalAmount;
  final MoneyAmount totalAmount;
  final MoneyAmount? totalTaxAmount;
}

class CartDiscountCode {
  const CartDiscountCode({required this.code, required this.applicable});

  final String code;
  final bool applicable;
}

class ShopifyCartWarning {
  const ShopifyCartWarning({required this.message, this.code, this.target});

  final String message;
  final String? code;
  final String? target;
}
