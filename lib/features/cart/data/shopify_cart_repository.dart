import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/shopify_failure.dart';
import '../../../core/network/shopify_providers.dart';
import '../../../core/network/shopify_storefront_client.dart';
import '../models/shopify_cart.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => ShopifyCartRepository(ref.watch(shopifyStorefrontClientProvider)),
);

abstract interface class CartRepository {
  Future<ShopifyCart?> fetchCart(String cartId);
  Future<ShopifyCart> createCart({
    required String merchandiseId,
    required int quantity,
  });
  Future<ShopifyCart> addLine({
    required String cartId,
    required String merchandiseId,
    required int quantity,
  });
  Future<ShopifyCart> updateLine({
    required String cartId,
    required String lineId,
    required int quantity,
  });
  Future<ShopifyCart> removeLine({
    required String cartId,
    required String lineId,
  });
  Future<ShopifyCart> updateDiscountCodes({
    required String cartId,
    required List<String> discountCodes,
  });
}

class ShopifyCartRepository implements CartRepository {
  const ShopifyCartRepository(this._client);

  static const cartQuery =
      r'''
    query Cart($id: ID!) {
      cart(id: $id) { ...CartFields }
    }
  ''' +
      _cartFragment;

  static const cartCreateMutation =
      r'''
    mutation CartCreate($input: CartInput!) {
      cartCreate(input: $input) {
        cart { ...CartFields }
        userErrors { field message code }
        warnings { target message code }
      }
    }
  ''' +
      _cartFragment;

  static const cartLinesAddMutation =
      r'''
    mutation CartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
      cartLinesAdd(cartId: $cartId, lines: $lines) {
        cart { ...CartFields }
        userErrors { field message code }
        warnings { target message code }
      }
    }
  ''' +
      _cartFragment;

  static const cartLinesUpdateMutation =
      r'''
    mutation CartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart { ...CartFields }
        userErrors { field message code }
        warnings { target message code }
      }
    }
  ''' +
      _cartFragment;

  static const cartLinesRemoveMutation =
      r'''
    mutation CartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart { ...CartFields }
        userErrors { field message code }
        warnings { target message code }
      }
    }
  ''' +
      _cartFragment;

  static const cartDiscountCodesUpdateMutation =
      r'''
    mutation CartDiscountCodesUpdate($cartId: ID!, $discountCodes: [String!]!) {
      cartDiscountCodesUpdate(cartId: $cartId, discountCodes: $discountCodes) {
        cart { ...CartFields }
        userErrors { field message code }
        warnings { target message code }
      }
    }
  ''' +
      _cartFragment;

  static const _cartFragment = r'''
    fragment CartFields on Cart {
      id
      totalQuantity
      checkoutUrl
      lines(first: 250) {
        nodes {
          id
          quantity
          merchandise {
            ... on ProductVariant {
              id
              title
              sku
              availableForSale
              image { url altText }
              price { amount currencyCode }
              selectedOptions { name value }
              quantityRule { minimum maximum increment }
              product {
                id
                handle
                title
                featuredImage { url altText }
              }
            }
          }
          cost {
            subtotalAmount { amount currencyCode }
            totalAmount { amount currencyCode }
          }
        }
      }
      cost {
        subtotalAmount { amount currencyCode }
        totalAmount { amount currencyCode }
        totalTaxAmount { amount currencyCode }
      }
      discountCodes { code applicable }
    }
  ''';

  final ShopifyStorefrontClient _client;

  @override
  Future<ShopifyCart?> fetchCart(String cartId) async {
    final data = await _client.execute(cartQuery, variables: {'id': cartId});
    final cart = data['cart'];
    if (cart == null) return null;
    return _cartFromJson(_map(cart, 'Shopify cart was invalid.'));
  }

  @override
  Future<ShopifyCart> createCart({
    required String merchandiseId,
    required int quantity,
  }) async {
    final data = await _client.execute(
      cartCreateMutation,
      variables: {
        'input': {
          'lines': [
            {'merchandiseId': merchandiseId, 'quantity': quantity},
          ],
        },
      },
    );
    return _cartFromPayload(data, 'cartCreate');
  }

  @override
  Future<ShopifyCart> addLine({
    required String cartId,
    required String merchandiseId,
    required int quantity,
  }) async {
    final data = await _client.execute(
      cartLinesAddMutation,
      variables: {
        'cartId': cartId,
        'lines': [
          {'merchandiseId': merchandiseId, 'quantity': quantity},
        ],
      },
    );
    return _cartFromPayload(data, 'cartLinesAdd');
  }

  @override
  Future<ShopifyCart> updateLine({
    required String cartId,
    required String lineId,
    required int quantity,
  }) async {
    final data = await _client.execute(
      cartLinesUpdateMutation,
      variables: {
        'cartId': cartId,
        'lines': [
          {'id': lineId, 'quantity': quantity},
        ],
      },
    );
    return _cartFromPayload(data, 'cartLinesUpdate');
  }

  @override
  Future<ShopifyCart> removeLine({
    required String cartId,
    required String lineId,
  }) async {
    final data = await _client.execute(
      cartLinesRemoveMutation,
      variables: {
        'cartId': cartId,
        'lineIds': [lineId],
      },
    );
    return _cartFromPayload(data, 'cartLinesRemove');
  }

  @override
  Future<ShopifyCart> updateDiscountCodes({
    required String cartId,
    required List<String> discountCodes,
  }) async {
    final data = await _client.execute(
      cartDiscountCodesUpdateMutation,
      variables: {'cartId': cartId, 'discountCodes': discountCodes},
    );
    return _cartFromPayload(data, 'cartDiscountCodesUpdate');
  }

  ShopifyCart _cartFromPayload(Map<String, dynamic> data, String key) {
    final payload = _map(
      data[key],
      'Shopify cart mutation response was invalid.',
    );
    final errors = payload['userErrors'];
    if (errors is List && errors.isNotEmpty) {
      throw ShopifyUserFailure(
        errors: errors
            .whereType<Map<String, dynamic>>()
            .map((error) {
              final rawField = error['field'];
              return ShopifyUserError(
                message:
                    error['message'] as String? ??
                    'Shopify rejected the cart request.',
                code: error['code']?.toString(),
                source: 'Shopify user error',
                field: rawField is List
                    ? rawField
                          .map((value) => value.toString())
                          .toList(growable: false)
                    : null,
              );
            })
            .toList(growable: false),
      );
    }
    final warnings = payload['warnings'];
    final parsedWarnings = warnings is List
        ? warnings
              .whereType<Map<String, dynamic>>()
              .map((warning) {
                return ShopifyCartWarning(
                  message:
                      warning['message'] as String? ??
                      'Shopify could not complete the cart request.',
                  code: warning['code']?.toString(),
                  target: warning['target'] as String?,
                );
              })
              .toList(growable: false)
        : const <ShopifyCartWarning>[];
    return _cartFromJson(
      _map(payload['cart'], 'Shopify cart was missing.'),
      warnings: parsedWarnings,
    );
  }

  ShopifyCart _cartFromJson(
    Map<String, dynamic> json, {
    List<ShopifyCartWarning> warnings = const [],
  }) {
    final lines = _map(json['lines'], 'Shopify cart lines were missing.');
    final rawLines = lines['nodes'];
    final rawDiscountCodes = json['discountCodes'];
    return ShopifyCart(
      id: json['id'] as String? ?? '',
      totalQuantity: json['totalQuantity'] as int? ?? 0,
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
      lines: rawLines is List
          ? rawLines
                .whereType<Map<String, dynamic>>()
                .map(_lineFromJson)
                .toList(growable: false)
          : const [],
      cost: _cartCostFromJson(
        _map(json['cost'], 'Shopify cart cost was missing.'),
      ),
      discountCodes: rawDiscountCodes is List
          ? rawDiscountCodes
                .whereType<Map<String, dynamic>>()
                .map(
                  (code) => CartDiscountCode(
                    code: code['code'] as String? ?? '',
                    applicable: code['applicable'] as bool? ?? false,
                  ),
                )
                .toList(growable: false)
          : const [],
      warnings: warnings,
    );
  }

  CartLine _lineFromJson(Map<String, dynamic> json) {
    final merchandise = _map(
      json['merchandise'],
      'Shopify cart merchandise was missing.',
    );
    final product = _map(
      merchandise['product'],
      'Shopify cart product was missing.',
    );
    final image = merchandise['image'] is Map<String, dynamic>
        ? merchandise['image'] as Map<String, dynamic>
        : product['featuredImage'] as Map<String, dynamic>?;
    final rawOptions = merchandise['selectedOptions'];
    final rule = merchandise['quantityRule'] is Map<String, dynamic>
        ? merchandise['quantityRule'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return CartLine(
      id: json['id'] as String? ?? '',
      variantId: merchandise['id'] as String? ?? '',
      productId: product['id'] as String? ?? '',
      productHandle: product['handle'] as String? ?? '',
      productTitle: product['title'] as String? ?? '',
      variantTitle: merchandise['title'] as String? ?? '',
      selectedOptions: rawOptions is List
          ? rawOptions
                .whereType<Map<String, dynamic>>()
                .map(
                  (option) => CartSelectedOption(
                    name: option['name'] as String? ?? '',
                    value: option['value'] as String? ?? '',
                  ),
                )
                .toList(growable: false)
          : const [],
      imageUrl: image?['url'] as String? ?? '',
      unitPrice: _moneyFromJson(
        _map(merchandise['price'], 'Shopify variant price was missing.'),
      ),
      cost: _lineCostFromJson(
        _map(json['cost'], 'Shopify line cost was missing.'),
      ),
      quantity: json['quantity'] as int? ?? 0,
      availableForSale: merchandise['availableForSale'] as bool? ?? false,
      quantityRule: CartQuantityRule(
        minimum: rule['minimum'] as int? ?? 1,
        maximum: rule['maximum'] as int?,
        increment: rule['increment'] as int? ?? 1,
      ),
      sku: merchandise['sku'] as String?,
    );
  }

  CartLineCost _lineCostFromJson(Map<String, dynamic> json) => CartLineCost(
    subtotalAmount: _moneyFromJson(
      _map(json['subtotalAmount'], 'Shopify line subtotal was missing.'),
    ),
    totalAmount: _moneyFromJson(
      _map(json['totalAmount'], 'Shopify line total was missing.'),
    ),
  );

  CartCost _cartCostFromJson(Map<String, dynamic> json) => CartCost(
    subtotalAmount: _moneyFromJson(
      _map(json['subtotalAmount'], 'Shopify cart subtotal was missing.'),
    ),
    totalAmount: _moneyFromJson(
      _map(json['totalAmount'], 'Shopify cart total was missing.'),
    ),
    totalTaxAmount: json['totalTaxAmount'] is Map<String, dynamic>
        ? _moneyFromJson(json['totalTaxAmount'] as Map<String, dynamic>)
        : null,
  );

  MoneyAmount _moneyFromJson(Map<String, dynamic> json) {
    final amount = double.tryParse(json['amount'] as String? ?? '');
    if (amount == null) {
      throw const ShopifyResponseFailure(
        'Shopify returned an invalid money amount.',
      );
    }
    return MoneyAmount(
      amount: amount,
      currencyCode: json['currencyCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> _map(Object? value, String message) {
    if (value is Map<String, dynamic>) return value;
    throw ShopifyResponseFailure(message);
  }
}
