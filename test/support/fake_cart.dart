import 'package:reborn_packaging/features/cart/data/cart_id_store.dart';
import 'package:reborn_packaging/features/cart/data/shopify_cart_repository.dart';
import 'package:reborn_packaging/features/cart/models/shopify_cart.dart';
import 'package:reborn_packaging/features/products/data/mock_product_details.dart';

class MemoryCartIdStore implements CartIdStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> save(String cartId) async => value = cartId;

  @override
  Future<void> clear() async => value = null;
}

class FakeCartRepository implements CartRepository {
  ShopifyCart? cart;
  int createCalls = 0;
  int addCalls = 0;
  int updateCalls = 0;
  int removeCalls = 0;
  String? lastMerchandiseId;
  String? lastCustomerAccessToken;

  @override
  Future<ShopifyCart?> fetchCart(String cartId) async =>
      cart?.id == cartId ? cart : null;

  @override
  Future<ShopifyCart> createCart({
    required String merchandiseId,
    required int quantity,
  }) async {
    createCalls++;
    lastMerchandiseId = merchandiseId;
    cart = _buildCart([_newLine(merchandiseId, quantity)]);
    return cart!;
  }

  @override
  Future<ShopifyCart> addLine({
    required String cartId,
    required String merchandiseId,
    required int quantity,
  }) async {
    addCalls++;
    lastMerchandiseId = merchandiseId;
    final lines = [...?cart?.lines];
    final index = lines.indexWhere((line) => line.variantId == merchandiseId);
    if (index == -1) {
      lines.add(_newLine(merchandiseId, quantity));
    } else {
      lines[index] = _copyLine(
        lines[index],
        quantity: lines[index].quantity + quantity,
      );
    }
    cart = _buildCart(lines);
    return cart!;
  }

  @override
  Future<ShopifyCart> updateLine({
    required String cartId,
    required String lineId,
    required int quantity,
  }) async {
    updateCalls++;
    cart = _buildCart([
      for (final line in cart!.lines)
        if (line.id == lineId) _copyLine(line, quantity: quantity) else line,
    ]);
    return cart!;
  }

  @override
  Future<ShopifyCart> removeLine({
    required String cartId,
    required String lineId,
  }) async {
    removeCalls++;
    cart = _buildCart(
      cart!.lines.where((line) => line.id != lineId).toList(growable: false),
    );
    return cart!;
  }

  @override
  Future<ShopifyCart> updateDiscountCodes({
    required String cartId,
    required List<String> discountCodes,
  }) async {
    cart = _buildCart(
      cart!.lines,
      discountCodes: [
        for (final code in discountCodes)
          CartDiscountCode(code: code, applicable: code == 'SAVE10'),
      ],
    );
    return cart!;
  }

  @override
  Future<ShopifyCart> updateBuyerIdentity({
    required String cartId,
    required String? customerAccessToken,
  }) async {
    lastCustomerAccessToken = customerAccessToken;
    cart = _buildCart(
      [...?cart?.lines],
      hasAuthenticatedBuyer: customerAccessToken?.isNotEmpty ?? false,
    );
    return cart!;
  }

  CartLine _newLine(String merchandiseId, int quantity) {
    final product = mockKraftRoundBowlsProduct;
    final variant = product.variants.firstWhere(
      (candidate) => candidate.id == merchandiseId,
      orElse: () => product.selectedVariant,
    );
    return CartLine(
      id: 'gid://shopify/CartLine/${merchandiseId.hashCode}',
      variantId: merchandiseId,
      productId: product.id,
      productHandle: product.handle,
      productTitle: product.title,
      variantTitle: variant.title,
      selectedOptions: [
        CartSelectedOption(name: 'Size', value: variant.size),
        CartSelectedOption(name: 'Lid', value: variant.lid),
      ],
      imageUrl: variant.imageSource,
      unitPrice: MoneyAmount(
        amount: variant.priceExVat,
        currencyCode: variant.currencyCode,
      ),
      cost: _lineCost(variant.priceExVat, quantity),
      quantity: quantity,
      availableForSale: variant.availableForSale,
      quantityRule: CartQuantityRule(
        minimum: variant.quantityRule.minimum,
        maximum: variant.quantityRule.maximum,
        increment: variant.quantityRule.increment,
      ),
      sku: variant.sku,
    );
  }

  CartLine _copyLine(CartLine line, {required int quantity}) => CartLine(
    id: line.id,
    variantId: line.variantId,
    productId: line.productId,
    productHandle: line.productHandle,
    productTitle: line.productTitle,
    variantTitle: line.variantTitle,
    selectedOptions: line.selectedOptions,
    imageUrl: line.imageUrl,
    unitPrice: line.unitPrice,
    cost: _lineCost(line.unitPrice.amount, quantity),
    quantity: quantity,
    availableForSale: line.availableForSale,
    quantityRule: line.quantityRule,
    sku: line.sku,
  );

  ShopifyCart _buildCart(
    List<CartLine> lines, {
    List<CartDiscountCode> discountCodes = const [],
    bool hasAuthenticatedBuyer = false,
  }) {
    final subtotal = lines.fold<double>(
      0,
      (total, line) => total + line.cost.totalAmount.amount,
    );
    final money = MoneyAmount(amount: subtotal, currencyCode: 'GBP');
    return ShopifyCart(
      id: 'gid://shopify/Cart/test?key=full-secret-key',
      totalQuantity: lines.fold(0, (total, line) => total + line.quantity),
      checkoutUrl: 'https://example.test/checkout',
      lines: List.unmodifiable(lines),
      cost: CartCost(subtotalAmount: money, totalAmount: money),
      discountCodes: discountCodes,
      hasAuthenticatedBuyer: hasAuthenticatedBuyer,
    );
  }

  CartLineCost _lineCost(double unitPrice, int quantity) {
    final money = MoneyAmount(
      amount: unitPrice * quantity,
      currencyCode: 'GBP',
    );
    return CartLineCost(subtotalAmount: money, totalAmount: money);
  }
}
