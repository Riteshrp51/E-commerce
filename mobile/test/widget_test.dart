import 'package:flutter_test/flutter_test.dart';
import 'package:dailymart_mobile/main.dart';

void main() {
  testWidgets('DailyMart app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyMartApp());
    expect(find.byType(DailyMartApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
  });
}
