import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/app/app.dart';

void main() {
  testWidgets('navigates from splash to temporary home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RebornPackagingApp()));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Reborn Packaging'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Reborn Packaging'), findsOneWidget);
  });
}
