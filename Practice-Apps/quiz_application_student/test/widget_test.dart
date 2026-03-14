import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_application_student/main.dart';

void main() {
  testWidgets('QuizApp loads Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuizApp());

    // Verify that the welcome screen text is present.
    expect(find.text('Quiz Pro'), findsOneWidget);
    expect(find.text('Begin Assessment'), findsOneWidget);
  });
}
