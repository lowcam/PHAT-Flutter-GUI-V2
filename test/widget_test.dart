import 'package:flutter_test/flutter_test.dart';
import 'package:phat_flutter_gui/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PhatApp());
    expect(find.text('PHAT CALC'), findsWidgets);
  });
}
