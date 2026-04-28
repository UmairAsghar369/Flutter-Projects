import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_cal_app/main.dart';

void main() {
  testWidgets('BMI Calculator app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const BMICalculatorApp());
    expect(find.text('BMI Calculator'), findsOneWidget);
  });
}
