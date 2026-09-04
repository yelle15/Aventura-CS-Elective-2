import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prelim_exam/app.dart';

void main() {
  testWidgets('category chips filter products', (tester) async {
    await tester.pumpWidget(const RiftsApp());
    await tester.pumpAndSettle();

    expect(find.text('355 Epiphone Semi-Hollow'), findsOneWidget);
    await tester.tap(find.text('Amps'));
    await tester.pumpAndSettle();

    expect(find.text('355 Epiphone Semi-Hollow'), findsNothing);
    expect(find.text('Fender Frontman 20G Amplifier'), findsOneWidget);
  });

  testWidgets('product card toggles its bookmark icon', (tester) async {
    await tester.pumpWidget(const RiftsApp());
    await tester.pumpAndSettle();

    final bookmark = find.byIcon(Icons.bookmark_border_rounded).first;
    await tester.tap(bookmark);
    await tester.pump();

    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
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
