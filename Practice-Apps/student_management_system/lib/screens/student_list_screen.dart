import 'package:flutter/material.dart';
import '../main.dart';
import '../models/student.dart';
import 'add_edit_student_screen.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen>
    with SingleTickerProviderStateMixin {
  final List<Student> _students = [];
  String _searchQuery = '';
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Seed sample data
    _students.addAll([
      Student(id: '1', name: 'Ali Ahmed', rollNumber: 'CS-2024-001', email: 'ali.ahmed@university.edu'),
      Student(id: '2', name: 'Sara Khan', rollNumber: 'CS-2024-002', email: 'sara.khan@university.edu'),
      Student(id: '3', name: 'Usman Tariq', rollNumber: 'CS-2024-003', email: 'usman.tariq@university.edu'),
      Student(id: '4', name: 'Fatima Noor', rollNumber: 'CS-2024-004', email: 'fatima.noor@university.edu'),
    ]);
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    final q = _searchQuery.toLowerCase();
    return _students.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.rollNumber.toLowerCase().contains(q)).toList();
  }

  Future<void> _addStudent() async {
    final result = await Navigator.push<Student>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const AddEditStudentScreen(),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
    if (result != null) {
      setState(() => _students.add(result));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(_snackBar(
          '${result.name} added successfully!',
          Icons.check_circle_rounded,
          AppColors.accent,
        ));
      }
    }
  }

  Future<void> _openDetails(int index) async {
    final result = await Navigator.push<dynamic>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => StudentDetailsScreen(student: _students[index]),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    if (result == null) return;
    if (result == 'deleted') {
      final name = _students[index].name;
      setState(() => _students.removeAt(index));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            _snackBar('$name removed', Icons.delete_outline_rounded, AppColors.danger));
      }
    } else if (result is Student) {
      setState(() => _students[index] = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            _snackBar('${result.name} updated!', Icons.edit_rounded, AppColors.secondary));
      }
    }
  }

  SnackBar _snackBar(String msg, IconData icon, Color color) => SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

  List<Color> _gradient(int i) {
    const g = [
      [Color(0xFF00D4AA), Color(0xFF00A383)],
      [Color(0xFF7C5CFC), Color(0xFF5A3FD6)],
      [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
      [Color(0xFFFFD93D), Color(0xFFF0A500)],
      [Color(0xFF00B4D8), Color(0xFF0077B6)],
      [Color(0xFFFF85A2), Color(0xFFE63975)],
    ];
    return g[i % g.length];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStudents;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24, right: 24, bottom: 24,
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
                  // Top row with greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Student Hub',
                              style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w800,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [AppColors.accent, AppColors.secondaryLight],
                                  ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                              )),
                          const SizedBox(height: 4),
                          Text('Manage your students',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        ],
                      ),
                      // Student count chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.secondary.withValues(alpha: 0.15)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_alt_rounded, size: 16, color: AppColors.accent),
                            const SizedBox(width: 6),
                            Text('${_students.length}',
                                style: const TextStyle(color: AppColors.accent,
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Stats row ──
                  Row(
                    children: [
                      _statChip(Icons.school_rounded, '${_students.length}', 'Total', AppColors.accent),
                      const SizedBox(width: 12),
                      _statChip(Icons.trending_up_rounded, 'Active', 'Status', AppColors.secondary),
                      const SizedBox(width: 12),
                      _statChip(Icons.calendar_today_rounded, '2024', 'Batch', AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Search bar ──
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search by name or roll number...',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All Students',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('${filtered.length} found',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),

          // ── List ──
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(_searchQuery.isEmpty ? 'No students yet' : 'No results found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text(_searchQuery.isEmpty
                        ? 'Tap the button below to add one'
                        : 'Try a different search term',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final student = filtered[index];
                  final realIndex = _students.indexOf(student);
                  final colors = _gradient(realIndex);
                  final initials = student.name
                      .split(' ').take(2)
                      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                      .join();

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + (index * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) => Transform.translate(
                      offset: Offset(0, 24 * (1 - v)),
                      child: Opacity(opacity: v, child: child),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openDetails(realIndex),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: colors[0].withValues(alpha: 0.06),
                                  blurRadius: 16, offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Gradient avatar
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: colors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors[0].withValues(alpha: 0.3),
                                        blurRadius: 8, offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(initials,
                                        style: const TextStyle(color: Colors.white,
                                            fontSize: 18, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student.name,
                                          style: const TextStyle(fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary)),
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: colors[0].withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(student.rollNumber,
                                              style: TextStyle(fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors[0])),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                // Arrow
                                Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
        ],
      ),

      // ── FAB ──
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.4),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _addStudent,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add Student',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
