import 'package:flutter_test/flutter_test.dart';
import 'package:pro_weather_app/main.dart';

void main() {
  testWidgets('Aurora Weather app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AuroraWeatherApp());
    // App should launch without errors
    expect(find.byType(AuroraWeatherApp), findsOneWidget);
  });
}
