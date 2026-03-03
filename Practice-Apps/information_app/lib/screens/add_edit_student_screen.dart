import 'package:flutter/material.dart';
import '../models/student.dart';
import '../controllers/student_controller.dart';
import 'dart:math';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({Key? key, this.student}) : super(key: key);

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _rollNoController;
  late TextEditingController _departmentController;
  late TextEditingController _gradeController;
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<Color> _avatarColors = const [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43E08F),
    Color(0xFFFFB74D),
    Color(0xFF29B6F6),
    Color(0xFFAB47BC),
  ];

  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _rollNoController = TextEditingController(text: widget.student?.rollNo ?? '');
    _departmentController = TextEditingController(text: widget.student?.department ?? '');
    _gradeController = TextEditingController(text: widget.student?.grade ?? '');
    
    _selectedColor = widget.student?.avatarColor ?? 
        _avatarColors[Random().nextInt(_avatarColors.length)];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    _departmentController.dispose();
    _gradeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: widget.student?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        rollNo: _rollNoController.text.trim(),
        department: _departmentController.text.trim(),
        grade: _gradeController.text.trim(),
        avatarColor: _selectedColor,
      );

      if (widget.student == null) {
        StudentController.instance.addStudent(student);
      } else {
        StudentController.instance.updateStudent(student);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Add New Student'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5757)),
              tooltip: 'Delete',
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 200),
            child: Opacity(
              opacity: 1.0 - _slideAnimation.value,
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAvatarSelector(),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _rollNoController,
                  label: 'Roll Number',
                  icon: Icons.numbers_outlined,
                  validator: (value) => value!.isEmpty ? 'Please enter roll number' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _departmentController,
                  label: 'Department',
                  icon: Icons.school_outlined,
                  validator: (value) => value!.isEmpty ? 'Please enter department' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _gradeController,
                  label: 'Grade/CGPA',
                  icon: Icons.grade_outlined,
                  validator: (value) => value!.isEmpty ? 'Please enter grade' : null,
                ),
                const SizedBox(height: 48),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      children: [
        Hero(
          tag: 'avatar_${widget.student?.id ?? "new"}',
          child: CircleAvatar(
            radius: 50,
            backgroundColor: _selectedColor.withOpacity(0.2),
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: _selectedColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _avatarColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final color = _avatarColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: _selectedColor == color
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: _selectedColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
      onChanged: (val) {
        if (label == 'Full Name') {
          setState(() {}); // Update the avatar initial
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _saveForm,
          child: const Center(
            child: Text(
              'Save Student Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252538),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Student?'),
        content: Text('Are you sure you want to remove ${widget.student!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              StudentController.instance.deleteStudent(widget.student!.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back home
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
