import 'package:hive/hive.dart';
import 'subject.dart';

/// A semester containing multiple subjects.
class Semester extends HiveObject {
  String id;
  String name; // e.g. "Semester 1"
  List<Subject> subjects;

  Semester({
    required this.id,
    required this.name,
    List<Subject>? subjects,
  }) : subjects = subjects ?? [];

  /// Calculate GPA for this semester
  double get gpa {
    if (subjects.isEmpty) return 0.0;
    double totalQualityPoints = 0;
    int totalCreditHours = 0;
    for (final s in subjects) {
      totalQualityPoints += s.qualityPoints;
      totalCreditHours += s.creditHours;
    }
    if (totalCreditHours == 0) return 0.0;
    return totalQualityPoints / totalCreditHours;
  }

  /// Total credit hours in this semester
  int get totalCredits {
    int total = 0;
    for (final s in subjects) {
      total += s.creditHours;
    }
    return total;
  }
}

/// Manual Hive TypeAdapter for Semester (typeId = 1)
class SemesterAdapter extends TypeAdapter<Semester> {
  @override
  final int typeId = 1;

  @override
  Semester read(BinaryReader reader) {
    return Semester(
      id: reader.readString(),
      name: reader.readString(),
      subjects: reader.readList().cast<Subject>(),
    );
  }

  @override
  void write(BinaryWriter writer, Semester obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeList(obj.subjects);
  }
}
