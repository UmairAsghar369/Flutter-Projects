import 'dart:math';

class Student {
  final String id;
  final String name;
  final String course;
  final int age;
  final int avatarIndex;

  Student({
    String? id,
    required this.name,
    required this.course,
    required this.age,
    int? avatarIndex,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        avatarIndex = avatarIndex ?? Random().nextInt(5);
}
