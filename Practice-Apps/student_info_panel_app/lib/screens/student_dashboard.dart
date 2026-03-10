import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';

class StudentDashboard extends StatefulWidget {
  final Student student;

  const StudentDashboard({super.key, required this.student});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimations = List.generate(6, (index) {
      final start = index * 0.12;
      final end = start + 0.4;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(6, (index) {
      final start = index * 0.12;
      final end = start + 0.4;
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
          .animate(
        CurvedAnimation(
          parent: _controller,
          curve:
              Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
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
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // ─── Header ───
                _buildAnimatedSection(
                  0,
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            FadeSlideTransition(page: const LoginScreen()),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: AppTheme.textSecondary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Profile',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Welcome, ${student.name.split(' ').first}!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ─── Profile Card ───
                _buildAnimatedSection(
                  1,
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          profileColor.withValues(alpha: 0.3),
                          profileColor.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: profileColor.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: profileColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'avatar_${student.id}',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  profileColor,
                                  profileColor.withValues(alpha: 0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: profileColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                student.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Hero(
                          tag: 'name_${student.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          student.regNo,
                          style: TextStyle(
                            fontSize: 14,
                            color: profileColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.department} • ${student.semester} Semester',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Quick Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickStat('CGPA', student.cgpa.toStringAsFixed(2),
                                AppTheme.accentGreen),
                            Container(
                              width: 1,
                              height: 35,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            _buildQuickStat(
                                'Age', '${student.age}', AppTheme.accentTeal),
                            Container(
                              width: 1,
                              height: 35,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            _buildQuickStat(
                                'Blood', student.bloodGroup, AppTheme.accentPink),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Personal Information ───
                _buildAnimatedSection(
                  2,
                  _buildInfoSection('Personal Information', Icons.person_rounded, [
                    _buildInfoTile('Full Name', student.name, Icons.badge_rounded),
                    _buildInfoTile('Date of Birth', student.dobFormatted,
                        Icons.cake_rounded),
                    _buildInfoTile('Gender', student.gender,
                        student.gender == 'Male' ? Icons.male : Icons.female),
                    _buildInfoTile('Blood Group', student.bloodGroup,
                        Icons.bloodtype_rounded),
                  ]),
                ),
                const SizedBox(height: 16),

                // ─── Contact Information ───
                _buildAnimatedSection(
                  3,
                  _buildInfoSection(
                      'Contact Information', Icons.contact_mail_rounded, [
                    _buildInfoTile('Email', student.email, Icons.email_rounded),
                    _buildInfoTile('Phone', student.phone, Icons.phone_rounded),
                    _buildInfoTile(
                        'Address', student.address, Icons.location_on_rounded),
                  ]),
                ),
                const SizedBox(height: 16),

                // ─── Academic Information ───
                _buildAnimatedSection(
                  4,
                  _buildInfoSection(
                      'Academic Information', Icons.school_rounded, [
                    _buildInfoTile('Department', student.department,
                        Icons.business_rounded),
                    _buildInfoTile(
                        'Semester', student.semester, Icons.timeline_rounded),
                    _buildInfoTile(
                        'Reg No', student.regNo, Icons.numbers_rounded),
                    _buildInfoTile('CGPA', student.cgpa.toStringAsFixed(2),
                        Icons.bar_chart_rounded),
                  ]),
                ),
                const SizedBox(height: 16),

                // ─── Guardian Information ───
                _buildAnimatedSection(
                  5,
                  _buildInfoSection(
                      'Guardian Information', Icons.family_restroom_rounded, [
                    _buildInfoTile('Guardian Name', student.guardianName,
                        Icons.person_outline_rounded),
                    _buildInfoTile('Guardian Phone', student.guardianPhone,
                        Icons.phone_in_talk_rounded),
                  ]),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    final safeIndex = index.clamp(0, _fadeAnimations.length - 1);
    return SlideTransition(
      position: _slideAnimations[safeIndex],
      child: FadeTransition(
        opacity: _fadeAnimations[safeIndex],
        child: child,
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
