/// Default grade definitions for GPA calculation.
class Grade {
  final String letter;
  final double points;

  const Grade({required this.letter, required this.points});

  /// Standard 4.0 scale grade list
  static const List<Grade> defaultScale = [
    Grade(letter: 'A+', points: 4.00),
    Grade(letter: 'A', points: 4.00),
    Grade(letter: 'A-', points: 3.67),
    Grade(letter: 'B+', points: 3.33),
    Grade(letter: 'B', points: 3.00),
    Grade(letter: 'B-', points: 2.67),
    Grade(letter: 'C+', points: 2.33),
    Grade(letter: 'C', points: 2.00),
    Grade(letter: 'C-', points: 1.67),
    Grade(letter: 'D+', points: 1.33),
    Grade(letter: 'D', points: 1.00),
    Grade(letter: 'F', points: 0.00),
  ];

  /// Get grade points for a letter grade from a scale
  static double pointsFor(String letter, [List<Grade>? scale]) {
    final grades = scale ?? defaultScale;
    return grades
        .firstWhere(
          (g) => g.letter == letter,
          orElse: () => const Grade(letter: 'F', points: 0.0),
        )
        .points;
  }

  /// Get all grade letters from a scale
  static List<String> letters([List<Grade>? scale]) {
    return (scale ?? defaultScale).map((g) => g.letter).toList();
  }
}
