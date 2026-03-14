import 'package:flutter/material.dart';
import 'package:quiz_application_student/data/questions.dart';
import 'package:quiz_application_student/screens/welcome_screen.dart';
import 'package:quiz_application_student/screens/quiz_screen.dart';
import 'package:quiz_application_student/screens/result_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  List<String> _selectedAnswers = [];
  var _activeScreen = 'welcome-screen';

  void _switchScreen() {
    setState(() {
      _activeScreen = 'quiz-screen';
    });
  }

  void _chooseAnswer(String answer) {
    _selectedAnswers.add(answer);

    if (_selectedAnswers.length == questions.length) {
      setState(() {
        _activeScreen = 'results-screen';
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _selectedAnswers = [];
      _activeScreen = 'welcome-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = WelcomeScreen(_switchScreen);

    if (_activeScreen == 'quiz-screen') {
      screenWidget = QuizScreen(
        onSelectAnswer: _chooseAnswer,
      );
    } else if (_activeScreen == 'results-screen') {
      screenWidget = ResultScreen(
        chosenAnswers: _selectedAnswers,
        onRestart: _restartQuiz,
      );
    }

    return MaterialApp(
      title: 'Quiz Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF), // Cyan/Teal neon
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B), // Slate 800
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.6),
              radius: 1.2,
              colors: [
                Color(0xFF251A4D), // Deep Violet/Indigo glow
                Color(0xFF0F172A), // Slate 900 base
              ],
            ),
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                key: ValueKey(_activeScreen),
                width: double.infinity,
                child: screenWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
