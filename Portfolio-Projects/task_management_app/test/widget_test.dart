import 'package:flutter_test/flutter_test.dart';

import 'package:task_management_app/main.dart';
import 'package:task_management_app/providers/theme_provider.dart';
import 'package:task_management_app/providers/task_provider.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    final taskProvider = TaskProvider();

    await tester.pumpWidget(
      TaskFlowApp(
        themeProvider: themeProvider,
        taskProvider: taskProvider,
      ),
    );

    expect(find.text('TaskFlow'), findsOneWidget);
  });
}
