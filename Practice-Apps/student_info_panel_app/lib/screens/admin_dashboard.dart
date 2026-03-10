import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/stat_card.dart';
import '../widgets/student_card.dart';
import 'add_student_screen.dart';
import 'all_students_screen.dart';
import 'login_screen.dart';
import 'student_detail_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = DummyData.students;
    final maleCount = students.where((s) => s.gender == 'Male').length;
    final femaleCount = students.where((s) => s.gender == 'Female').length;
    final avgCgpa = students.isEmpty
        ? 0.0
        : students.map((s) => s.cgpa).reduce((a, b) => a + b) /
            students.length;
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── Header ───
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentPurple
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.admin_panel_settings,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Admin Dashboard',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  'Welcome back, Administrator',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Colors.white.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Logout
                          _buildIconButton(
                            Icons.logout_rounded,
                            () {
                              Navigator.pushReplacement(
                                context,
                                FadeSlideTransition(
                                    page: const LoginScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Stats Grid ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 2.2,
                    ),
                    children: [
                      StatCard(
                        title: 'Total Students',
                        value: '${students.length}',
                        icon: Icons.people_alt_rounded,
                        gradient: AppTheme.primaryGradient,
                        delay: 100,
                      ),
                      StatCard(
                        title: 'Male Students',
                        value: '$maleCount',
                        icon: Icons.male_rounded,
                        gradient: AppTheme.tealGradient,
                        delay: 200,
                      ),
                      StatCard(
                        title: 'Female Students',
                        value: '$femaleCount',
                        icon: Icons.female_rounded,
                        gradient: AppTheme.pinkGradient,
                        delay: 300,
                      ),
                      StatCard(
                        title: 'Avg CGPA',
                        value: avgCgpa.toStringAsFixed(2),
                        icon: Icons.bar_chart_rounded,
                        gradient: AppTheme.greenGradient,
                        delay: 400,
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Department Summary ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _buildDepartmentSummary(students),
                ),
              ),

              // ─── Recent Students Header ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Students',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeSlideTransition(
                              page: AllStudentsScreen(
                                onStudentUpdated: () => setState(() {}),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                AppTheme.accentPurple.withValues(alpha: 0.15),
                            border: Border.all(
                              color:
                                  AppTheme.accentPurple.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.accentPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Student List ───
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = students[index];
                      return StudentCard(
                        student: student,
                        index: index,
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeSlideTransition(
                              page: StudentDetailScreen(
                                student: student,
                                isAdmin: true,
                                onStudentUpdated: () => setState(() {}),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount:
                        students.length > 5 ? 5 : students.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildDepartmentSummary(List<Student> students) {
    final deptMap = <String, int>{};
    for (final s in students) {
      deptMap[s.department] = (deptMap[s.department] ?? 0) + 1;
    }

    final gradients = [
      AppTheme.primaryGradient,
      AppTheme.tealGradient,
      AppTheme.pinkGradient,
      AppTheme.orangeGradient,
      AppTheme.greenGradient,
    ];

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
                child: const Icon(Icons.school_rounded,
                    color: AppTheme.accentPurple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Department Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...deptMap.entries.toList().asMap().entries.map((entry) {
            final idx = entry.key;
            final dept = entry.value;
            final percentage = (dept.value / students.length) * 100;
            final grad = gradients[idx % gradients.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          dept.key,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${dept.value} (${percentage.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: percentage / 100),
                          duration: Duration(milliseconds: 800 + (idx * 200)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return FractionallySizedBox(
                              widthFactor: value,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: grad,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildFAB() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            ScaleTransitionRoute(page: const AddStudentScreen()),
          );
          setState(() {}); // refresh after adding student
        },
        backgroundColor: AppTheme.accentPurple,
        elevation: 12,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Add Student',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
    );
  }
}
