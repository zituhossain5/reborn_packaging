import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/app/app.dart';
import 'package:reborn_packaging/features/products/widgets/product_option_chip.dart';

void main() {
  testWidgets('navigates from splash to the Home screen', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 42, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 42, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(const ProviderScope(child: RebornPackagingApp()));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('PRODUCT COLLECTIONS'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final mediaQuery = tester.widget<MediaQuery>(find.byType(MediaQuery).first);
    debugPrint(
      'Home visual viewport: '
      'size=${mediaQuery.data.size}, '
      'devicePixelRatio=${mediaQuery.data.devicePixelRatio}, '
      'textScaler=${mediaQuery.data.textScaler}, '
      'padding=${mediaQuery.data.padding}, '
      'viewPadding=${mediaQuery.data.viewPadding}, '
      'viewInsets=${mediaQuery.data.viewInsets}',
    );

    expect(find.text('PRODUCT COLLECTIONS'), findsOneWidget);
    expect(find.text('KRAFT RECTANGULAR BOWLS'), findsOneWidget);
    expect(find.text('SHOP'), findsOneWidget);

    for (final label in [
      'PRODUCT COLLECTIONS',
      '25 collections',
      'KRAFT ROUND BOWLS',
      'FREE NEXT DAY DELIVERY ON ORDERS OVER \u00A3100',
      'SHOP',
      'CART',
      'ACCOUNT',
    ]) {
      final text = tester.widget<Text>(find.text(label).first);
      expect(text.style?.fontFamily, 'Montserrat');
    }

    final collectionTop = tester.getTopLeft(find.text('KRAFT ROUND BOWLS')).dy;
    final navigationTop = tester.getTopLeft(find.text('SHOP')).dy;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('KRAFT ROUND BOWLS')).dy,
      lessThan(collectionTop),
    );
    expect(tester.getTopLeft(find.text('SHOP')).dy, navigationTop);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('KRAFT ROUND BOWLS').first);
    await tester.pumpAndSettle();

    expect(find.text('500ml Kraft Round Bowls'), findsNWidgets(4));
    expect(find.text('600 QTY'), findsNWidgets(4));
    expect(find.text('\u00A341.95'), findsNWidgets(4));
    expect(find.text('2'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);

    await tester.tap(find.text('500ml Kraft Round Bowls').first);
    await tester.pumpAndSettle();

    expect(find.text('Kraft Round Bowls'), findsOneWidget);
    expect(find.text('In Stock'), findsOneWidget);
    expect(find.text('\u00A354.95'), findsNWidgets(2));
    expect(find.text('Ex. VAT'), findsOneWidget);
    expect(find.text('600 units'), findsOneWidget);
    expect(find.text('ADD TO CART'), findsOneWidget);

    await tester.tap(find.text('Include VAT'));
    await tester.pump();
    expect(find.text('Inc. VAT'), findsOneWidget);
    expect(find.text('\u00A365.94'), findsNWidgets(2));
    expect(find.text('\u00A30.1099 / piece'), findsOneWidget);

    var petLidChip = tester.widget<ProductOptionChip>(
      find.widgetWithText(ProductOptionChip, 'With PET Lid'),
    );
    expect(petLidChip.enabled, isFalse);

    await tester.ensureVisible(find.text('650ml'));
    await tester.tap(find.text('650ml'));
    await tester.pump();
    petLidChip = tester.widget<ProductOptionChip>(
      find.widgetWithText(ProductOptionChip, 'With PET Lid'),
    );
    expect(petLidChip.enabled, isTrue);

    await tester.ensureVisible(find.text('With PET Lid'));
    await tester.tap(find.text('With PET Lid'));
    await tester.pump();
    petLidChip = tester.widget<ProductOptionChip>(
      find.widgetWithText(ProductOptionChip, 'With PET Lid'),
    );
    expect(petLidChip.selected, isTrue);
    expect(find.text('500 QTY'), findsOneWidget);
    expect(find.text('\u00A30.1535 / piece'), findsOneWidget);
    expect(find.text('\u00A376.74'), findsNWidgets(2));
    expect(find.text('500 units'), findsOneWidget);

    await tester.ensureVisible(find.bySemanticsLabel('Increase quantity'));
    await tester.tap(find.bySemanticsLabel('Increase quantity'));
    await tester.pump();
    expect(find.text('1000 units'), findsOneWidget);
    expect(find.text('\u00A3153.48'), findsOneWidget);

    final ctaTop = tester.getTopLeft(find.text('ADD TO CART')).dy;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('PRODUCT DESCRIPTION'), findsOneWidget);
    expect(tester.getTopLeft(find.text('ADD TO CART')).dy, ctaTop);
    expect(tester.takeException(), isNull);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.text('500ml Kraft Round Bowls'), findsNWidgets(4));
    expect(find.bySemanticsLabel('Back'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Back'), findsNothing);
    expect(find.text('KRAFT RECTANGULAR BOWLS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
