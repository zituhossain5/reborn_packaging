import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/account/data/customer_order_repository.dart';
import 'package:reborn_packaging/features/account/models/customer_order_details.dart';
import 'package:reborn_packaging/features/account/presentation/order_details_screen.dart';
import 'package:reborn_packaging/features/account/state/customer_order_details_provider.dart';
import 'package:reborn_packaging/features/auth/data/customer_auth_repository.dart';
import 'package:reborn_packaging/features/auth/models/customer_auth_session.dart';
import 'package:reborn_packaging/features/auth/state/customer_auth_controller.dart';

void main() {
  test('order parser maps discounts and real Shopify details', () {
    final order = CustomerOrderDetails.fromShopifyJson(_orderJson());

    expect(order.name, '#1189');
    expect(order.lineItems.single.title, 'Bagasse Bowl');
    expect(order.lineItems.single.quantity, 2);
    expect(order.totalDiscount?.amount, 7.5);
    expect(order.shippingAddress?.formatted, contains('London SW1A 1AA'));
    expect(order.fulfillments.single.estimatedDeliveryAt, isNotNull);
    expect(order.statusPageUrl?.scheme, 'https');
  });

  testWidgets('native order details renders authoritative Shopify fields', (
    tester,
  ) async {
    final order = CustomerOrderDetails.fromShopifyJson(_orderJson());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerAuthRepositoryProvider.overrideWithValue(
            const _SignedInAuthRepository(),
          ),
          customerOrderRepositoryProvider.overrideWithValue(
            _FakeOrderRepository(order),
          ),
        ],
        child: const MaterialApp(
          home: OrderDetailsScreen(orderId: 'gid://shopify/Order/1189'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#1189'), findsOneWidget);
    expect(find.text('Bagasse Bowl'), findsOneWidget);
    expect(find.text('Qty 2'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Discounts'), findsOneWidget);
    expect(find.text('Shipping'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.textContaining('London SW1A 1AA'), findsOneWidget);
    expect(find.textContaining('Estimated delivery:'), findsOneWidget);
    expect(find.text('Royal Mail - TRACK1189'), findsOneWidget);
    expect(find.text('View Shopify order status'), findsOneWidget);
  });
}

Map<String, dynamic> _orderJson() => {
  'id': 'gid://shopify/Order/1189',
  'name': '#1189',
  'confirmationNumber': 'CONFIRM1189',
  'createdAt': '2026-08-24T10:00:00Z',
  'financialStatus': 'PAID',
  'fulfillmentStatus': 'FULFILLED',
  'statusPageUrl': 'https://example.test/orders/1189',
  'lineItems': {
    'nodes': [
      {
        'id': 'gid://shopify/LineItem/1',
        'name': 'Bagasse Bowl - 500ml',
        'title': 'Bagasse Bowl',
        'quantity': 2,
        'variantTitle': '500ml',
        'sku': 'BOWL-500',
        'image': null,
        'price': {'amount': '25.00', 'currencyCode': 'GBP'},
        'totalPrice': {'amount': '50.00', 'currencyCode': 'GBP'},
        'totalDiscount': {'amount': '5.00', 'currencyCode': 'GBP'},
      },
    ],
  },
  'subtotal': {'amount': '50.00', 'currencyCode': 'GBP'},
  'totalShipping': {'amount': '5.00', 'currencyCode': 'GBP'},
  'totalTax': {'amount': '10.00', 'currencyCode': 'GBP'},
  'totalPrice': {'amount': '57.50', 'currencyCode': 'GBP'},
  'shippingDiscountAllocations': [
    {
      'allocatedAmount': {'amount': '2.50', 'currencyCode': 'GBP'},
    },
  ],
  'shippingAddress': {
    'firstName': 'Real',
    'lastName': 'Customer',
    'formatted': ['1 High Street', 'London SW1A 1AA', 'United Kingdom'],
  },
  'fulfillments': {
    'nodes': [
      {
        'id': 'gid://shopify/Fulfillment/1',
        'status': 'SUCCESS',
        'latestShipmentStatus': 'IN_TRANSIT',
        'estimatedDeliveryAt': '2026-08-26T17:00:00Z',
        'trackingInformation': [
          {'company': 'Royal Mail', 'number': 'TRACK1189', 'url': null},
        ],
      },
    ],
  },
};

class _FakeOrderRepository implements CustomerOrderRepository {
  const _FakeOrderRepository(this.order);

  final CustomerOrderDetails order;

  @override
  Future<CustomerOrderDetails> fetchOrder({
    required String orderId,
    required String accessToken,
  }) async => order;

  @override
  Future<CustomerOrderDetails?> findRecentOrder({
    required String orderId,
    required String accessToken,
  }) async => order;
}

class _SignedInAuthRepository implements CustomerAuthRepository {
  const _SignedInAuthRepository();

  @override
  Future<CustomerAuthSession?> restoreSession() async => CustomerAuthSession(
    accessToken: 'customer-account-token',
    refreshToken: 'refresh-token',
    idToken: 'id-token',
    expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
  );

  @override
  Future<CustomerAuthSession> signIn({String? loginHint}) async {
    return (await restoreSession())!;
  }

  @override
  Future<void> signOut(CustomerAuthSession? session) async {}
}
