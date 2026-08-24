class CustomerOrderDetails {
  const CustomerOrderDetails({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.fulfillmentStatus,
    required this.lineItems,
    required this.totalPrice,
    required this.shippingAddress,
    required this.fulfillments,
    this.confirmationNumber,
    this.financialStatus,
    this.subtotal,
    this.totalShipping,
    this.totalTax,
    this.totalDiscount,
    this.statusPageUrl,
  });

  factory CustomerOrderDetails.fromShopifyJson(Map<String, dynamic> json) {
    final lineItems = _nodes(
      json['lineItems'],
    ).map(CustomerOrderLineItem.fromShopifyJson).toList(growable: false);
    final totalPrice = ShopifyOrderMoney.fromShopifyJson(
      json['totalPrice'] as Map<String, dynamic>,
    );
    return CustomerOrderDetails(
      id: json['id'] as String,
      name: json['name'] as String,
      confirmationNumber: _nullableString(json['confirmationNumber']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      financialStatus: _nullableString(json['financialStatus']),
      fulfillmentStatus: json['fulfillmentStatus'] as String,
      lineItems: lineItems,
      subtotal: ShopifyOrderMoney.fromNullableJson(json['subtotal']),
      totalShipping: ShopifyOrderMoney.fromNullableJson(json['totalShipping']),
      totalTax: ShopifyOrderMoney.fromNullableJson(json['totalTax']),
      totalDiscount: _totalDiscount(
        lineItems,
        json['shippingDiscountAllocations'],
        totalPrice.currencyCode,
      ),
      totalPrice: totalPrice,
      shippingAddress: json['shippingAddress'] is Map<String, dynamic>
          ? CustomerOrderAddress.fromShopifyJson(
              json['shippingAddress'] as Map<String, dynamic>,
            )
          : null,
      fulfillments: _nodes(
        json['fulfillments'],
      ).map(CustomerOrderFulfillment.fromShopifyJson).toList(growable: false),
      statusPageUrl: _nullableUri(json['statusPageUrl']),
    );
  }

  final String id;
  final String name;
  final String? confirmationNumber;
  final DateTime createdAt;
  final String? financialStatus;
  final String fulfillmentStatus;
  final List<CustomerOrderLineItem> lineItems;
  final ShopifyOrderMoney? subtotal;
  final ShopifyOrderMoney? totalShipping;
  final ShopifyOrderMoney? totalTax;
  final ShopifyOrderMoney? totalDiscount;
  final ShopifyOrderMoney totalPrice;
  final CustomerOrderAddress? shippingAddress;
  final List<CustomerOrderFulfillment> fulfillments;
  final Uri? statusPageUrl;
}

class CustomerOrderLineItem {
  const CustomerOrderLineItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.variantTitle,
    this.sku,
    this.imageUrl,
    this.imageAltText,
    this.totalPrice,
    this.price,
    this.totalDiscount,
    this.title,
  });

  factory CustomerOrderLineItem.fromShopifyJson(Map<String, dynamic> json) {
    final image = json['image'];
    return CustomerOrderLineItem(
      id: json['id'] as String,
      name: json['name'] as String,
      title: _nullableString(json['title']),
      quantity: json['quantity'] as int,
      variantTitle: _nullableString(json['variantTitle']),
      sku: _nullableString(json['sku']),
      imageUrl: image is Map<String, dynamic>
          ? _nullableString(image['url'])
          : null,
      imageAltText: image is Map<String, dynamic>
          ? _nullableString(image['altText'])
          : null,
      totalPrice: ShopifyOrderMoney.fromNullableJson(json['totalPrice']),
      price: ShopifyOrderMoney.fromNullableJson(json['price']),
      totalDiscount: ShopifyOrderMoney.fromNullableJson(json['totalDiscount']),
    );
  }

  final String id;
  final String name;
  final String? title;
  final int quantity;
  final String? variantTitle;
  final String? sku;
  final String? imageUrl;
  final String? imageAltText;
  final ShopifyOrderMoney? totalPrice;
  final ShopifyOrderMoney? price;
  final ShopifyOrderMoney? totalDiscount;
}

class ShopifyOrderMoney {
  const ShopifyOrderMoney({required this.amount, required this.currencyCode});

  factory ShopifyOrderMoney.fromShopifyJson(Map<String, dynamic> json) {
    return ShopifyOrderMoney(
      amount: double.parse(json['amount'] as String),
      currencyCode: json['currencyCode'] as String,
    );
  }

  static ShopifyOrderMoney? fromNullableJson(Object? json) {
    return json is Map<String, dynamic>
        ? ShopifyOrderMoney.fromShopifyJson(json)
        : null;
  }

  final double amount;
  final String currencyCode;
}

class CustomerOrderAddress {
  const CustomerOrderAddress({
    required this.formatted,
    this.firstName,
    this.lastName,
  });

  factory CustomerOrderAddress.fromShopifyJson(Map<String, dynamic> json) {
    return CustomerOrderAddress(
      firstName: _nullableString(json['firstName']),
      lastName: _nullableString(json['lastName']),
      formatted: (json['formatted'] as List? ?? const [])
          .whereType<String>()
          .where((line) => line.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  final String? firstName;
  final String? lastName;
  final List<String> formatted;
}

class CustomerOrderFulfillment {
  const CustomerOrderFulfillment({
    required this.id,
    required this.trackingInformation,
    this.status,
    this.latestShipmentStatus,
    this.estimatedDeliveryAt,
  });

  factory CustomerOrderFulfillment.fromShopifyJson(Map<String, dynamic> json) {
    return CustomerOrderFulfillment(
      id: json['id'] as String,
      status: _nullableString(json['status']),
      latestShipmentStatus: _nullableString(json['latestShipmentStatus']),
      estimatedDeliveryAt: json['estimatedDeliveryAt'] is String
          ? DateTime.tryParse(json['estimatedDeliveryAt'] as String)
          : null,
      trackingInformation: (json['trackingInformation'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CustomerOrderTracking.fromShopifyJson)
          .toList(growable: false),
    );
  }

  final String id;
  final String? status;
  final String? latestShipmentStatus;
  final DateTime? estimatedDeliveryAt;
  final List<CustomerOrderTracking> trackingInformation;
}

class CustomerOrderTracking {
  const CustomerOrderTracking({this.company, this.number, this.url});

  factory CustomerOrderTracking.fromShopifyJson(Map<String, dynamic> json) {
    return CustomerOrderTracking(
      company: _nullableString(json['company']),
      number: _nullableString(json['number']),
      url: _nullableUri(json['url']),
    );
  }

  final String? company;
  final String? number;
  final Uri? url;
}

List<Map<String, dynamic>> _nodes(Object? connection) {
  if (connection is! Map<String, dynamic>) return const [];
  return (connection['nodes'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

String? _nullableString(Object? value) {
  final text = value is String ? value.trim() : '';
  return text.isEmpty ? null : text;
}

Uri? _nullableUri(Object? value) {
  final uri = Uri.tryParse(value is String ? value.trim() : '');
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
      ? uri
      : null;
}

ShopifyOrderMoney? _totalDiscount(
  List<CustomerOrderLineItem> lineItems,
  Object? shippingAllocations,
  String currencyCode,
) {
  var amount = lineItems.fold<double>(
    0,
    (total, item) => total + (item.totalDiscount?.amount ?? 0),
  );
  if (shippingAllocations is List) {
    for (final allocation
        in shippingAllocations.whereType<Map<String, dynamic>>()) {
      amount +=
          ShopifyOrderMoney.fromNullableJson(
            allocation['allocatedAmount'],
          )?.amount ??
          0;
    }
  }
  return amount > 0
      ? ShopifyOrderMoney(amount: amount, currencyCode: currencyCode)
      : null;
}
