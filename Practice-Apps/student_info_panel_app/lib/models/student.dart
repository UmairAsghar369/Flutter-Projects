class Student {
  final String id;
  final String name;
  final String regNo;
  final DateTime dob;
  final String gender;
  final String email;
  final String phone;
  final String department;
  final String semester;
  final String address;
  final String bloodGroup;
  final String guardianName;
  final String guardianPhone;
  final double cgpa;
  final String profileColor;

  Student({
    required this.id,
    required this.name,
    required this.regNo,
    required this.dob,
    required this.gender,
    required this.email,
    required this.phone,
    required this.department,
    required this.semester,
    required this.address,
    this.bloodGroup = '',
    this.guardianName = '',
    this.guardianPhone = '',
    this.cgpa = 0.0,
    this.profileColor = '0xFF6C63FF',
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String get dobFormatted {
    return '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}';
  }

  Student copyWith({
    String? id,
    String? name,
    String? regNo,
    DateTime? dob,
    String? gender,
    String? email,
    String? phone,
    String? department,
    String? semester,
    String? address,
    String? bloodGroup,
    String? guardianName,
    String? guardianPhone,
    double? cgpa,
    String? profileColor,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      regNo: regNo ?? this.regNo,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      cgpa: cgpa ?? this.cgpa,
      profileColor: profileColor ?? this.profileColor,
    );
  }
}
