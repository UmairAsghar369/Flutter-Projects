import 'package:hive/hive.dart';
import 'semester.dart';

/// A student profile containing multiple semesters.
class StudentProfile extends HiveObject {
  String id;
  String name;
  int avatarIndex; // index into a list of avatar icons
  List<Semester> semesters;

  StudentProfile({
    required this.id,
    required this.name,
    this.avatarIndex = 0,
    List<Semester>? semesters,
  }) : semesters = semesters ?? [];

  /// Calculate overall CGPA across all semesters
  double get cgpa {
    if (semesters.isEmpty) return 0.0;
    double totalQualityPoints = 0;
    int totalCreditHours = 0;
    for (final sem in semesters) {
      for (final sub in sem.subjects) {
        totalQualityPoints += sub.qualityPoints;
        totalCreditHours += sub.creditHours;
      }
    }
    if (totalCreditHours == 0) return 0.0;
    return totalQualityPoints / totalCreditHours;
  }

  /// Total credit hours across all semesters
  int get totalCredits {
    int total = 0;
    for (final sem in semesters) {
      total += sem.totalCredits;
    }
    return total;
  }
}

/// Manual Hive TypeAdapter for StudentProfile (typeId = 2)
class StudentProfileAdapter extends TypeAdapter<StudentProfile> {
  @override
  final int typeId = 2;

  @override
  StudentProfile read(BinaryReader reader) {
    return StudentProfile(
      id: reader.readString(),
      name: reader.readString(),
      avatarIndex: reader.readInt(),
      semesters: reader.readList().cast<Semester>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudentProfile obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.avatarIndex);
    writer.writeList(obj.semesters);
  }
}
