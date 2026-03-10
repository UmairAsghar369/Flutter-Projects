import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import 'add_student_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  final bool isAdmin;
  final VoidCallback? onStudentUpdated;

  const StudentDetailScreen({
    super.key,
    required this.student,
    this.isAdmin = false,
    this.onStudentUpdated,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshStudent() {
    final updated =
        DummyData.students.where((s) => s.id == _currentStudent.id).toList();
    if (updated.isNotEmpty) {
      setState(() => _currentStudent = updated.first);
    }
  }

  void _deleteStudent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Student',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete ${_currentStudent.name}?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              DummyData.students
                  .removeWhere((s) => s.id == _currentStudent.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onStudentUpdated?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Student deleted successfully'),
                    ],
                  ),
                  backgroundColor: AppTheme.accentPink,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = _currentStudent;
    final profileColor = Color(int.parse(student.profileColor));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Custom App Bar ───
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Student Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (widget.isAdmin) ...[
                        _buildActionButton(
                          Icons.edit_rounded,
                          AppTheme.accentPurple,
                          () async {
                            await Navigator.push(
                              context,
                              FadeSlideTransition(
                                page: AddStudentScreen(
                                    studentToEdit: _currentStudent),
                              ),
                            );
                            _refreshStudent();
                            widget.onStudentUpdated?.call();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.delete_rounded,
                          AppTheme.accentPink,
                          _deleteStudent,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ─── Profile Header ───
            SliverToBoxAdapter(
              child: _buildAnimated(
                0.0,
                0.3,
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          profileColor.withValues(alpha: 0.3),
                          profileColor.withValues(alpha: 0.08),
                        ],
                      ),
                      border: Border.all(
                          color: profileColor.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: profileColor.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'avatar_${student.id}',
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  profileColor,
                                  profileColor.withValues(alpha: 0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      profileColor.withValues(alpha: 0.5),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                student.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Hero(
                          tag: 'name_${student.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: profileColor.withValues(alpha: 0.2),
                          ),
                          child: Text(
                            student.regNo,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: profileColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Quick Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStat('CGPA',
                                student.cgpa.toStringAsFixed(2), profileColor),
                            _divider(),
                            _buildStat('Age', '${student.age}', profileColor),
                            _divider(),
                            _buildStat('Semester', student.semester, profileColor),
                            _divider(),
                            _buildStat(
                                'Blood', student.bloodGroup, profileColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Info Sections ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildAnimated(
                      0.2,
                      0.5,
                      _buildSection(
                          'Personal Details', Icons.person_rounded, [
                        _infoRow('Full Name', student.name),
                        _infoRow('Date of Birth', student.dobFormatted),
                        _infoRow('Gender', student.gender),
                        _infoRow('Blood Group', student.bloodGroup),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _buildAnimated(
                      0.3,
                      0.6,
                      _buildSection(
                          'Contact Info', Icons.contact_mail_rounded, [
                        _infoRow('Email', student.email),
                        _infoRow('Phone', student.phone),
                        _infoRow('Address', student.address),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _buildAnimated(
                      0.4,
                      0.7,
                      _buildSection(
                          'Academic Info', Icons.school_rounded, [
                        _infoRow('Department', student.department),
                        _infoRow('Semester', student.semester),
                        _infoRow('Registration No', student.regNo),
                        _infoRow('CGPA', student.cgpa.toStringAsFixed(2)),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    _buildAnimated(
                      0.5,
                      0.8,
                      _buildSection(
                          'Guardian Info', Icons.family_restroom_rounded, [
                        _infoRow('Guardian Name', student.guardianName),
                        _infoRow('Guardian Phone', student.guardianPhone),
                      ]),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimated(double begin, double end, Widget child) {
    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(opacity: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(icon, color: AppTheme.accentPurple, size: 20),
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
          ),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
