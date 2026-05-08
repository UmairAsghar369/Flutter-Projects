import 'package:flutter/material.dart';
import '../main.dart';
import '../models/student.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;
  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rollCtrl;
  late final TextEditingController _emailCtrl;
  late AnimationController _anim;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.student?.name ?? '');
    _rollCtrl = TextEditingController(text: widget.student?.rollNumber ?? '');
    _emailCtrl = TextEditingController(text: widget.student?.email ?? '');
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _emailCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isEditing) {
      widget.student!.name = _nameCtrl.text.trim();
      widget.student!.rollNumber = _rollCtrl.text.trim();
      widget.student!.email = _emailCtrl.text.trim();
      Navigator.pop(context, widget.student);
    } else {
      final s = Student(
        id: UniqueKey().toString(),
        name: _nameCtrl.text.trim(),
        rollNumber: _rollCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      Navigator.pop(context, s);
    }
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w\.\-\+]+@[\w\-]+\.[\w\-\.]+$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20, right: 20, bottom: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isEditing ? 'Edit Student' : 'New Student',
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: _isEditing
                              ? [AppColors.secondary, AppColors.secondaryLight]
                              : [AppColors.accent, const Color(0xFF56FFD6)],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isEditing
                        ? 'Update the student information below'
                        : 'Fill in the details to add a new student',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          // ── Form ──
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic)),
              child: FadeTransition(
                opacity: _anim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Icon
                        Center(
                          child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isEditing
                                    ? [AppColors.secondary, AppColors.secondaryLight]
                                    : [AppColors.accent, AppColors.accentDark],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isEditing ? AppColors.secondary : AppColors.accent)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20, offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isEditing ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
                              size: 32, color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildField(
                          ctrl: _nameCtrl,
                          label: 'Full Name',
                          hint: 'e.g. Ali Ahmed',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          ctrl: _rollCtrl,
                          label: 'Roll Number',
                          hint: 'e.g. CS-2024-001',
                          icon: Icons.badge_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Roll number is required' : null,
                        ),
                        const SizedBox(height: 18),

                        _buildField(
                          ctrl: _emailCtrl,
                          label: 'Email Address',
                          hint: 'e.g. student@university.edu',
                          icon: Icons.email_outlined,
                          kb: TextInputType.emailAddress,
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 36),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isEditing
                                    ? [AppColors.secondary, AppColors.secondaryLight]
                                    : [AppColors.accent, AppColors.accentDark],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isEditing ? AppColors.secondary : AppColors.accent)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 14, offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    _isEditing ? 'Save Changes' : 'Add Student',
                                    style: const TextStyle(fontSize: 17,
                                        fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType kb = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: kb,
        validator: validator,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(color: AppColors.textMuted),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          errorStyle: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
