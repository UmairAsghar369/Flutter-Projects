/// Student model class to hold student data.
class Student {
  /// Unique identifier for each student.
  final String id;

  /// Student's full name.
  String name;

  /// Student's roll number.
  String rollNumber;

  /// Student's email address.
  String email;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.email,
  });
}
