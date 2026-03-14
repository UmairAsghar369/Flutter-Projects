import 'package:flutter/material.dart';
import 'package:quiz_application_student/data/questions.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.chosenAnswers,
    required this.onRestart,
  });

  final List<String> chosenAnswers;
  final void Function() onRestart;

  List<Map<String, Object>> get summaryData {
    final List<Map<String, Object>> summary = [];

    for (var i = 0; i < chosenAnswers.length; i++) {
      summary.add({
        'question_index': i,
        'question': questions[i].text,
        'correct_answer': questions[i].answers[0],
        'user_answer': chosenAnswers[i],
      });
    }

    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final summary = summaryData;
    final numTotalQuestions = questions.length;
    final numCorrectQuestions = summary.where((data) {
      return data['correct_answer'] == data['user_answer'];
    }).length;

    final scorePercentage = numCorrectQuestions / numTotalQuestions;
    String message;
    IconData iconData;
    Color iconColor;

    if (scorePercentage == 1.0) {
      message = 'Outstanding!';
      iconData = Icons.workspace_premium_rounded;
      iconColor = const Color(0xFFFFD700); // Gold
    } else if (scorePercentage >= 0.7) {
      message = 'Great Job!';
      iconData = Icons.thumb_up_alt_rounded;
      iconColor = const Color(0xFF00E5FF); // Neon cyan
    } else {
      message = 'Keep Practice!';
      iconData = Icons.school_rounded;
      iconColor = const Color(0xFFFF6B6B); // Coral red
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score Highlight Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E293B).withOpacity(0.8),
                  const Color(0xFF0F172A).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon with Glow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 40,
                      )
                    ],
                  ),
                  child: Icon(
                    iconData,
                    size: 70,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    children: [
                      const TextSpan(text: 'You scored '),
                      TextSpan(
                        text: '$numCorrectQuestions',
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const TextSpan(text: ' out of '),
                      TextSpan(
                        text: '$numTotalQuestions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const TextSpan(text: ' correct.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRestart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text(
                    'Restart Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
