import 'package:flutter_test/flutter_test.dart';

import 'package:bloom_app/main.dart';

void main() {
  testWidgets(
    'Bloom app starts correctly',
        (WidgetTester tester) async {
      // تشغيل التطبيق مع اعتبار أن المستخدم
      // شاهد الـ Onboarding مسبقًا
      await tester.pumpWidget(
        const MyApp(
          hasSeenOnboarding: true,
        ),
      );

      // انتظار بناء الواجهة
      await tester.pumpAndSettle();

      // التأكد أن التطبيق اشتغل
      expect(
        find.byType(MyApp),
        findsOneWidget,
      );
    },
  );
}