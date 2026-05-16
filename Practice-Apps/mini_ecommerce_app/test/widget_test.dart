import 'package:flutter_test/flutter_test.dart';
import 'package:mini_ecommerce_app/main.dart';

void main() {
  testWidgets('App starts and shows LUXE STORE', (WidgetTester tester) async {
    await tester.pumpWidget(const LuxeStoreApp());
    expect(find.text('LUXE STORE'), findsOneWidget);
  });
}
