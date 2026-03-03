import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MathQuizApp());
}

// ─────────────────────────────────────────────
//  Root App Widget
// ─────────────────────────────────────────────
class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  Data Model – a single quiz question
// ─────────────────────────────────────────────
class Question {
  final String text;          // e.g. "12 + 7 = ?"
  final List<int> options;    // 4 answer choices
  final int correctAnswer;    // the right answer

  Question({
    required this.text,
    required this.options,
    required this.correctAnswer,
  });
}

// ─────────────────────────────────────────────
//  Question Generator
// ─────────────────────────────────────────────
class QuestionGenerator {
  final Random _rng = Random();

  // Generates a list of 10 random questions
  List<Question> generateQuestions(int count) {
    return List.generate(count, (_) => _randomQuestion());
  }

  Question _randomQuestion() {
    // Pick a random operation: +, -, ×, ÷
    final operations = ['+', '-', '×', '÷'];
    final op = operations[_rng.nextInt(operations.length)];

    int a, b, answer;

    switch (op) {
      case '+':
        a = _rng.nextInt(50) + 1;
        b = _rng.nextInt(50) + 1;
        answer = a + b;
        break;
      case '-':
        a = _rng.nextInt(50) + 20;
        b = _rng.nextInt(20) + 1;
        answer = a - b;
        break;
      case '×':
        a = _rng.nextInt(12) + 1;
        b = _rng.nextInt(12) + 1;
        answer = a * b;
        break;
      case '÷':
      default:
        b = _rng.nextInt(9) + 2;          // divisor 2–10
        answer = _rng.nextInt(10) + 1;    // quotient 1–10
        a = b * answer;                   // ensure whole number
        break;
    }

    // Build 4 unique options including the correct answer
    final Set<int> optionSet = {answer};
    while (optionSet.length < 4) {
      int fake = answer + _rng.nextInt(21) - 10;
      if (fake != answer && fake > 0) optionSet.add(fake);
    }

    final options = optionSet.toList()..shuffle(_rng);

    return Question(
      text: '$a $op $b = ?',
      options: options,
      correctAnswer: answer,
    );
  }
}

// ─────────────────────────────────────────────
//  Home Screen
// ─────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Purple gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon / emoji
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🧮', style: TextStyle(fontSize: 64)),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Math Quiz',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Test your math skills!\n10 questions · 4 operations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 48),

                // Start button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuizScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 56, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    elevation: 6,
                  ),
                  child: const Text('Start Quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Quiz Screen  (StatefulWidget – changes over time)
// ─────────────────────────────────────────────
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ── State variables ──
  late List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;          // which option the user tapped
  bool _answered = false;        // has the user tapped an option?
  final int _totalQuestions = 10;
  late Timer _timer;
  int _timeLeft = 10;

  @override
  void initState() {
    super.initState();
    _questions = QuestionGenerator().generateQuestions(_totalQuestions);
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer.cancel();
        _showTimeExpiredDialog();
      }
    });
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AutoCloseDialog(),
    ).then((_) => _nextQuestion()); // called automatically when dialog closes
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _totalQuestions) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
      _startTimer(); // restart timer for next question
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultsScreen(score: _score, total: _totalQuestions),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // always cancel timer when screen closes
    super.dispose();
  }

  // Called when user taps an answer option
  void _onOptionTap(int answer) {
    if (_answered) return;
    _timer.cancel(); // stop the timer immediately on tap

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (answer == _questions[_currentIndex].correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () => _nextQuestion());
  }

  // Returns a color for each answer button
  Color _optionColor(int option) {
    if (!_answered) return Colors.white;
    final correct = _questions[_currentIndex].correctAnswer;
    if (option == correct) return Colors.green.shade400;
    if (option == _selectedAnswer) return Colors.red.shade400;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _totalQuestions;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar: question counter + score ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Q ${_currentIndex + 1} / $_totalQuestions',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.yellowAccent, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          '$_score',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Timer bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Animated countdown bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _timeLeft / 10,
                          minHeight: 8,
                          backgroundColor: Colors.white30,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft <= 3
                                ? Colors.redAccent
                                : Colors.yellowAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Countdown number
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _timeLeft <= 3
                            ? Colors.redAccent
                            : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_timeLeft',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Progress bar ──

                // ── Progress bar ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white30,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Question card ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Text(
                    question.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Answer options (2 × 2 grid) ──
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,         // ← takes only the space it needs
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2,  // ← makes boxes wider than tall (prevents oversizing)
                    children: question.options.map((option) {
                      return GestureDetector(
                        onTap: () => _onOptionTap(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: _optionColor(option),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$option',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: _answered &&
                                    (option ==
                                        question.correctAnswer ||
                                        option == _selectedAnswer)
                                    ? Colors.white
                                    : const Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Results Screen
// ─────────────────────────────────────────────
class ResultsScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultsScreen({super.key, required this.score, required this.total});

  // Pick a message based on score
  String get _message {
    final pct = score / total;
    if (pct == 1.0) return '🏆 Perfect Score!';
    if (pct >= 0.8) return '🌟 Great Job!';
    if (pct >= 0.5) return '👍 Good Effort!';
    return '💪 Keep Practicing!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score circle
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'out of $total',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  _message,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'You answered $score out of $total correctly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),

                const SizedBox(height: 48),

                // Play again
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizScreen()),
                          (route) => route.isFirst,
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                // Go home
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────
//  Auto-closing "Time's Up" Dialog (2 sec)
// ─────────────────────────────────────────────
class _AutoCloseDialog extends StatefulWidget {
  const _AutoCloseDialog();

  @override
  State<_AutoCloseDialog> createState() => _AutoCloseDialogState();
}

class _AutoCloseDialogState extends State<_AutoCloseDialog> {
  int _countdown = 2;
  late Timer _dialogTimer;

  @override
  void initState() {
    super.initState();
    _dialogTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        Navigator.pop(context); // auto-close after 2 seconds
      }
    });
  }

  @override
  void dispose() {
    _dialogTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '⏰ Time\'s Up!',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Closing countdown circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: Center(
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Moving to next question...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
