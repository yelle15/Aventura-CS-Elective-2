import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prelim_exam/app.dart';

void main() {
  testWidgets('home shows all featured products', (tester) async {
    await tester.pumpWidget(const RiftsApp());
    await tester.pumpAndSettle();

    expect(find.text('All Products').first, findsOneWidget);
    expect(find.text('355 Epiphone Semi-Hollow'), findsOneWidget);
    expect(find.text('Global B1 Bass'), findsOneWidget);
    expect(find.text('Pulse ST – 0037 Electric Guitar (Red)'), findsOneWidget);
    expect(find.text('Skywing ST-0035 Electric Guitar (Sunburst)'), findsOneWidget);
  });

  testWidgets('category chips filter the product grid', (tester) async {
    await tester.pumpWidget(const RiftsApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Bass Guitars'));
    await tester.pumpAndSettle();

    expect(find.text('Global B1 Bass'), findsOneWidget);
    expect(find.text('355 Epiphone Semi-Hollow'), findsNothing);
  });

  testWidgets('product card toggles its bookmark icon', (tester) async {
    await tester.pumpWidget(const RiftsApp());
    await tester.pumpAndSettle();

    final bookmark = find.byIcon(Icons.bookmark_border_rounded).first;
    await tester.tap(bookmark);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byIcon(Icons.bookmark_rounded).first, findsOneWidget);
  });

  testWidgets('theme icon toggles the app theme', (tester) async {
    await tester.pumpWidget(const RiftsApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });

  testWidgets('home shows the first product and routes to its detail', (
    tester,
  ) async {
    await tester.pumpWidget(const RiftsApp());
    await tester.pumpAndSettle();

    expect(find.text('355 Epiphone Semi-Hollow'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('355 Epiphone Semi-Hollow'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('355 Epiphone Semi-Hollow'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('FIND YOUR'), findsOneWidget);
  });
}
