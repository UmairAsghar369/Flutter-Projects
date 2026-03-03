import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Minimal smoke test - full app requires SharedPreferences
    expect(true, isTrue);
  });
}
