import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/account/models/account_models.dart';
import 'package:reborn_packaging/features/account/models/customer_order_summary.dart';

void main() {
  test('maps Shopify order fields and sums line-item quantities', () {
    final order = CustomerOrderSummary.fromShopifyJson({
      'id': 'gid://shopify/Order/1182',
      'name': '#1182',
      'confirmationNumber': 'ABC123',
      'createdAt': '2026-08-24T10:30:00Z',
      'financialStatus': 'PAID',
      'fulfillmentStatus': 'FULFILLED',
      'totalPrice': {'amount': '120.64', 'currencyCode': 'GBP'},
      'lineItems': {
        'nodes': [
          {'quantity': 2},
          {'quantity': 3},
        ],
      },
    });

    expect(order.id, 'gid://shopify/Order/1182');
    expect(order.displayNumber, '#1182');
    expect(order.itemCount, 5);
    expect(order.formattedTotal, '£120.64');
    expect(order.uiStatus, AccountOrderStatus.delivered);
  });

  test('maps every documented non-fulfilled status to Pending', () {
    const pendingStatuses = [
      'IN_PROGRESS',
      'ON_HOLD',
      'OPEN',
      'PARTIALLY_FULFILLED',
      'PENDING_FULFILLMENT',
      'RESTOCKED',
      'SCHEDULED',
      'UNFULFILLED',
    ];

    for (final status in pendingStatuses) {
      final order = CustomerOrderSummary.fromShopifyJson({
        'fulfillmentStatus': status,
      });
      expect(order.uiStatus, AccountOrderStatus.pending, reason: status);
    }
  });

  test('parses cursor page information for subsequent order requests', () {
    final page = CustomerOrderPage.fromShopifyJson({
      'nodes': const [],
      'pageInfo': {'hasNextPage': true, 'endCursor': 'next-page'},
    });

    expect(page.orders, isEmpty);
    expect(page.hasNextPage, isTrue);
    expect(page.endCursor, 'next-page');
  });
}
