import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:advance_cgpa_calculator_app/app.dart';
import 'package:advance_cgpa_calculator_app/providers/theme_provider.dart';
import 'package:advance_cgpa_calculator_app/providers/settings_provider.dart';
import 'package:advance_cgpa_calculator_app/providers/profile_provider.dart';
import 'package:advance_cgpa_calculator_app/providers/semester_provider.dart';
import 'package:advance_cgpa_calculator_app/providers/grade_scale_provider.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(false)),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => SemesterProvider()),
          ChangeNotifierProvider(create: (_) => GradeScaleProvider()),
        ],
        child: const CgpaApp(),
      ),
    );

    // Verify that the app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
