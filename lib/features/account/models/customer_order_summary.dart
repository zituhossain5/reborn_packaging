import 'account_models.dart';

class CustomerOrderSummary {
  const CustomerOrderSummary({
    required this.id,
    required this.name,
    required this.confirmationNumber,
    required this.createdAt,
    required this.financialStatus,
    required this.fulfillmentStatus,
    required this.totalAmount,
    required this.currencyCode,
    required this.itemCount,
  });

  factory CustomerOrderSummary.fromShopifyJson(Map<String, dynamic> json) {
    final totalPrice = json['totalPrice'];
    final lineItems = json['lineItems'];
    final lineItemNodes = lineItems is Map<String, dynamic>
        ? (lineItems['nodes'] as List? ?? const [])
        : const [];

    return CustomerOrderSummary(
      id: json['id'] as String? ?? '',
      name: _nullableString(json['name']),
      confirmationNumber: _nullableString(json['confirmationNumber']),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      financialStatus: _nullableString(json['financialStatus']),
      fulfillmentStatus: json['fulfillmentStatus'] as String? ?? 'UNFULFILLED',
      totalAmount: totalPrice is Map<String, dynamic>
          ? double.tryParse(totalPrice['amount'] as String? ?? '') ?? 0
          : 0,
      currencyCode: totalPrice is Map<String, dynamic>
          ? totalPrice['currencyCode'] as String? ?? 'GBP'
          : 'GBP',
      itemCount: lineItemNodes.whereType<Map<String, dynamic>>().fold<int>(
        0,
        (total, item) => total + (item['quantity'] as int? ?? 0),
      ),
    );
  }

  final String id;
  final String? name;
  final String? confirmationNumber;
  final DateTime createdAt;
  final String? financialStatus;
  final String fulfillmentStatus;
  final double totalAmount;
  final String currencyCode;
  final int itemCount;

  String get displayNumber => name ?? confirmationNumber ?? 'Order';

  AccountOrderStatus get uiStatus {
    return switch (fulfillmentStatus.toUpperCase()) {
      'FULFILLED' => AccountOrderStatus.delivered,
      'IN_PROGRESS' ||
      'ON_HOLD' ||
      'OPEN' ||
      'PARTIALLY_FULFILLED' ||
      'PENDING_FULFILLMENT' ||
      'RESTOCKED' ||
      'SCHEDULED' ||
      'UNFULFILLED' => AccountOrderStatus.pending,
      _ => AccountOrderStatus.pending,
    };
  }

  String get itemCountLabel =>
      '$itemCount ${itemCount == 1 ? 'item' : 'items'}';

  String get formattedTotal {
    final symbol = switch (currencyCode.toUpperCase()) {
      'GBP' => '£',
      'EUR' => '€',
      'USD' => r'$',
      'CAD' => r'CA$',
      'AUD' => r'A$',
      _ => '${currencyCode.toUpperCase()} ',
    };
    return '$symbol${totalAmount.toStringAsFixed(2)}';
  }
}

class CustomerOrderPage {
  const CustomerOrderPage({
    required this.orders,
    required this.hasNextPage,
    required this.endCursor,
  });

  factory CustomerOrderPage.fromShopifyJson(Map<String, dynamic> connection) {
    final nodes = (connection['nodes'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CustomerOrderSummary.fromShopifyJson)
        .toList(growable: false);
    final pageInfo = connection['pageInfo'];
    return CustomerOrderPage(
      orders: nodes,
      hasNextPage: pageInfo is Map<String, dynamic>
          ? pageInfo['hasNextPage'] as bool? ?? false
          : false,
      endCursor: pageInfo is Map<String, dynamic>
          ? _nullableString(pageInfo['endCursor'])
          : null,
    );
  }

  final List<CustomerOrderSummary> orders;
  final bool hasNextPage;
  final String? endCursor;
}

String? _nullableString(Object? value) {
  final text = value is String ? value.trim() : '';
  return text.isEmpty ? null : text;
}
