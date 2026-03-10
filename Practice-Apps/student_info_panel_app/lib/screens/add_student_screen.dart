import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_text_field.dart';

class AddStudentScreen extends StatefulWidget {
  final Student? studentToEdit;

  const AddStudentScreen({super.key, this.studentToEdit});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _cgpaController = TextEditingController();

  DateTime? _selectedDob;
  String _selectedGender = 'Male';
  String _selectedDepartment = 'Software Engineering';
  String _selectedSemester = '1st';
  String _selectedBloodGroup = 'A+';

  bool _isEditing = false;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _departments = [
    'Software Engineering',
    'Computer Science',
    'Information Technology',
    'Electrical Engineering',
    'Mechanical Engineering',
  ];
  final List<String> _semesters = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'
  ];
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  final List<String> _profileColors = [
    '0xFF6C63FF',
    '0xFFE94560',
    '0xFF00D9FF',
    '0xFF00E676',
    '0xFFFF9100',
    '0xFF7C4DFF',
    '0xFFE040FB',
    '0xFFFF6B6B',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    if (widget.studentToEdit != null) {
      _isEditing = true;
      final s = widget.studentToEdit!;
      _nameController.text = s.name;
      _regNoController.text = s.regNo;
      _emailController.text = s.email;
      _phoneController.text = s.phone;
      _addressController.text = s.address;
      _guardianNameController.text = s.guardianName;
      _guardianPhoneController.text = s.guardianPhone;
      _cgpaController.text = s.cgpa.toString();
      _selectedDob = s.dob;
      _selectedGender = s.gender;
      _selectedDepartment = s.department;
      _selectedSemester = s.semester;
      _selectedBloodGroup = s.bloodGroup;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _regNoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2003, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentPurple,
              onPrimary: Colors.white,
              surface: AppTheme.cardDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Please select a date of birth'),
            ],
          ),
          backgroundColor: AppTheme.accentOrange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final colorIndex = DummyData.students.length % _profileColors.length;

    final student = Student(
      id: _isEditing
          ? widget.studentToEdit!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      regNo: _regNoController.text.trim(),
      dob: _selectedDob!,
      gender: _selectedGender,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment,
      semester: _selectedSemester,
      address: _addressController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      guardianName: _guardianNameController.text.trim(),
      guardianPhone: _guardianPhoneController.text.trim(),
      cgpa: double.tryParse(_cgpaController.text.trim()) ?? 0.0,
      profileColor: _isEditing
          ? widget.studentToEdit!.profileColor
          : _profileColors[colorIndex],
    );

    if (_isEditing) {
      final index =
          DummyData.students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        DummyData.students[index] = student;
      }
    } else {
      DummyData.students.add(student);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(_isEditing
                ? 'Student updated successfully!'
                : 'Student added successfully!'),
          ],
        ),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── App Bar ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      _isEditing ? 'Edit Student' : 'Add New Student',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // ─── Form ───
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildSectionHeader(
                              'Personal Details', Icons.person_rounded),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter student name',
                            icon: Icons.badge_rounded,
                            validator: (v) =>
                                v!.isEmpty ? 'Name is required' : null,
                          ),
                          CustomTextField(
                            controller: _regNoController,
                            label: 'Registration No',
                            hint: 'e.g. FA21-BSE-001',
                            icon: Icons.numbers_rounded,
                            validator: (v) =>
                                v!.isEmpty ? 'Reg no is required' : null,
                          ),
                          // Date of Birth
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 18),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFF3A4A6B), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cake_rounded,
                                      size: 22, color: AppTheme.accentPurple),
                                  const SizedBox(width: 14),
                                  Text(
                                    _selectedDob == null
                                        ? 'Select Date of Birth'
                                        : '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _selectedDob == null
                                          ? AppTheme.textMuted
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Gender
                          _buildDropdown('Gender', Icons.wc_rounded,
                              _selectedGender, _genders, (val) {
                            setState(() => _selectedGender = val!);
                          }),
                          // Blood Group
                          _buildDropdown(
                              'Blood Group',
                              Icons.bloodtype_rounded,
                              _selectedBloodGroup,
                              _bloodGroups, (val) {
                            setState(() => _selectedBloodGroup = val!);
                          }),
                          const SizedBox(height: 8),
                          _buildSectionHeader(
                              'Contact Details', Icons.contact_mail_rounded),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'student@university.edu',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.isEmpty ? 'Email is required' : null,
                          ),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            hint: '+92 3XX XXXXXXX',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          CustomTextField(
                            controller: _addressController,
                            label: 'Address',
                            hint: 'Enter complete address',
                            icon: Icons.location_on_rounded,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          _buildSectionHeader(
                              'Academic Details', Icons.school_rounded),
                          const SizedBox(height: 14),
                          _buildDropdown(
                              'Department',
                              Icons.business_rounded,
                              _selectedDepartment,
                              _departments, (val) {
                            setState(() => _selectedDepartment = val!);
                          }),
                          _buildDropdown(
                              'Semester',
                              Icons.timeline_rounded,
                              _selectedSemester,
                              _semesters, (val) {
                            setState(() => _selectedSemester = val!);
                          }),
                          CustomTextField(
                            controller: _cgpaController,
                            label: 'CGPA',
                            hint: 'e.g. 3.50',
                            icon: Icons.bar_chart_rounded,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            validator: (v) {
                              if (v != null && v.isNotEmpty) {
                                final val = double.tryParse(v);
                                if (val == null || val < 0 || val > 4) {
                                  return 'CGPA must be between 0 and 4';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildSectionHeader('Guardian Details',
                              Icons.family_restroom_rounded),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _guardianNameController,
                            label: 'Guardian Name',
                            hint: 'Enter guardian name',
                            icon: Icons.person_outline_rounded,
                          ),
                          CustomTextField(
                            controller: _guardianPhoneController,
                            label: 'Guardian Phone',
                            hint: '+92 3XX XXXXXXX',
                            icon: Icons.phone_in_talk_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 24),
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveStudent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: AppTheme.accentPurple
                                    .withValues(alpha: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isEditing
                                        ? Icons.save_rounded
                                        : Icons.person_add_rounded,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isEditing
                                        ? 'Update Student'
                                        : 'Add Student',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.accentPurple, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, IconData icon, String value,
      List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A4A6B), width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppTheme.cardDark,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textMuted),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, size: 22, color: AppTheme.accentPurple),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
