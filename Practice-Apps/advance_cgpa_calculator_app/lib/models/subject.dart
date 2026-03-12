import 'package:hive/hive.dart';

/// A subject within a semester.
class Subject extends HiveObject {
  String id;
  String name;
  int creditHours;
  String grade; // e.g. 'A+', 'B', 'F'
  double gradePoints; // e.g. 4.0, 3.0, 0.0

  Subject({
    required this.id,
    required this.name,
    required this.creditHours,
    required this.grade,
    required this.gradePoints,
  });

  /// Quality points = creditHours × gradePoints
  double get qualityPoints => creditHours * gradePoints;
}

/// Manual Hive TypeAdapter for Subject (typeId = 0)
class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 0;

  @override
  Subject read(BinaryReader reader) {
    return Subject(
      id: reader.readString(),
      name: reader.readString(),
      creditHours: reader.readInt(),
      grade: reader.readString(),
      gradePoints: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.creditHours);
    writer.writeString(obj.grade);
    writer.writeDouble(obj.gradePoints);
  }
}
