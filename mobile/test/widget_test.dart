import 'package:flutter_test/flutter_test.dart';
import 'package:greencart_mobile/main.dart';

void main() {
  testWidgets('GreenCart app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GreenCartApp());
    expect(find.byType(GreenCartApp), findsOneWidget);
  });
}
