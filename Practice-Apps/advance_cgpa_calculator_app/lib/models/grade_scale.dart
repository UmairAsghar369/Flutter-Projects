import 'package:hive/hive.dart';

/// A custom grade scale with name and grade-to-point mappings.
class GradeScale extends HiveObject {
  String id;
  String name; // e.g. "Standard 4.0", "5.0 Scale"
  Map<String, double> gradeMap; // e.g. {'A+': 4.0, 'A': 4.0, ...}

  GradeScale({
    required this.id,
    required this.name,
    required this.gradeMap,
  });

  /// Grade letters in this scale
  List<String> get letters => gradeMap.keys.toList();

  /// Get points for a grade letter
  double pointsFor(String letter) => gradeMap[letter] ?? 0.0;

  /// Default 4.0 scale
  static GradeScale get defaultScale => GradeScale(
        id: 'default',
        name: 'Standard 4.0',
        gradeMap: {
          'A+': 4.00,
          'A': 4.00,
          'A-': 3.67,
          'B+': 3.33,
          'B': 3.00,
          'B-': 2.67,
          'C+': 2.33,
          'C': 2.00,
          'C-': 1.67,
          'D+': 1.33,
          'D': 1.00,
          'F': 0.00,
        },
      );
}

/// Manual Hive TypeAdapter for GradeScale (typeId = 3)
class GradeScaleAdapter extends TypeAdapter<GradeScale> {
  @override
  final int typeId = 3;

  @override
  GradeScale read(BinaryReader reader) {
    return GradeScale(
      id: reader.readString(),
      name: reader.readString(),
      gradeMap: Map<String, double>.from(reader.readMap()),
    );
  }

  @override
  void write(BinaryWriter writer, GradeScale obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeMap(obj.gradeMap);
  }
}
