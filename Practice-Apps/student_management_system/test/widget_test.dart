import 'package:flutter_test/flutter_test.dart';
import 'package:student_management_system/main.dart';

void main() {
  testWidgets('App renders student list screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentManagementApp());
    // Verify the app bar title appears.
    expect(find.text('Students'), findsOneWidget);
  });
}
