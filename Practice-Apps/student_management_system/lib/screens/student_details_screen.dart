import 'package:flutter/material.dart';
import '../main.dart';
import '../models/student.dart';
import 'add_edit_student_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;
  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late Student _student;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Student>(
      context,
      MaterialPageRoute(builder: (_) => AddEditStudentScreen(student: _student)),
    );
    if (updated != null) setState(() => _student = updated);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
          ),
          const SizedBox(width: 14),
          const Text('Delete Student',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 18)),
        ]),
        content: Text(
          'Are you sure you want to remove ${_student.name}? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.danger, AppColors.dangerDark]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.pop(context, 'deleted');
  }

  @override
  Widget build(BuildContext context) {
    final initials = _student.name
        .split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

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
                left: 20, right: 20, bottom: 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
              ),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, _student),
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
                      const Text('Student Details',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(width: 42), // balance
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Profile avatar
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 24, offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(color: Colors.white,
                              fontSize: 34, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_student.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_student.rollNumber,
                        style: const TextStyle(color: AppColors.accent,
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          // ── Info card ──
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic)),
              child: FadeTransition(
                opacity: _anim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Information',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),

                      // Info card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            _infoRow(Icons.person_outline_rounded, 'Full Name', _student.name,
                                AppColors.accent, isFirst: true),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(height: 1, color: AppColors.divider),
                            ),
                            _infoRow(Icons.badge_outlined, 'Roll Number', _student.rollNumber,
                                AppColors.secondary),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(height: 1, color: AppColors.divider),
                            ),
                            _infoRow(Icons.email_outlined, 'Email Address', _student.email,
                                AppColors.warning, isLast: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Action Buttons ──
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.secondary, AppColors.secondaryLight],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withValues(alpha: 0.3),
                                      blurRadius: 12, offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _edit,
                                  icon: const Icon(Icons.edit_rounded, size: 19),
                                  label: const Text('Edit',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: _delete,
                                icon: const Icon(Icons.delete_outline_rounded, size: 19),
                                label: const Text('Delete',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(color: AppColors.danger, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color,
      {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 20 : 16,
        bottom: isLast ? 20 : 16,
        left: 20, right: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11,
                    color: AppColors.textMuted, fontWeight: FontWeight.w500,
                    letterSpacing: 0.5)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 15,
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
