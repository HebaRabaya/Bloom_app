import 'package:bloom_app/theme/app_theme.dart';
import 'package:bloom_app/widgets/bloom_logo.dart';
import 'package:bloom_app/widgets/bloom_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// هاي الاختبارات بتغطي نظام التصميم بدون ما تحتاج Firebase،
/// عشان تظل سريعة وتشتغل بأي بيئة.

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('Brand lockup renders the Bloom wordmark', (tester) async {
    await tester.pumpWidget(_wrap(const BloomLogo()));

    expect(find.text('BLOOM'), findsOneWidget);
    expect(find.text('FLOWERS'), findsOneWidget);
    expect(find.byType(BloomMark), findsOneWidget);
  });

  testWidgets('Filter chip reports taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        BloomChip(
          label: 'Bouquets',
          selected: false,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Bouquets'));
    expect(tapped, isTrue);
  });

  testWidgets('Quantity stepper disables buttons without callbacks', (
    tester,
  ) async {
    var increased = false;

    await tester.pumpWidget(
      _wrap(
        BloomQuantityStepper(
          quantity: 3,
          onIncrease: () => increased = true,
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(increased, isTrue);

    // The decrease callback was omitted, so tapping it must do nothing.
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
  });
}
