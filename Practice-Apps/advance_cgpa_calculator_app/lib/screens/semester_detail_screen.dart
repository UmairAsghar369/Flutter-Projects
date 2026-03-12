import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/semester_provider.dart';
import '../providers/grade_scale_provider.dart';
import '../models/semester.dart';
import '../widgets/subject_tile.dart';
import '../widgets/add_subject_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_list_item.dart';
import '../theme/app_colors.dart';

/// Shows subjects for a specific semester with add/edit/delete.
class SemesterDetailScreen extends StatelessWidget {
  final String semesterId;
  final String semesterName;

  const SemesterDetailScreen({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<SemesterProvider>(
      builder: (context, semesterProv, _) {
        Semester? semester;
        try {
          semester = semesterProv.semesters.firstWhere(
            (s) => s.id == semesterId,
          );
        } catch (_) {
          semester = null;
        }

        if (semester == null) {
          return Scaffold(
            appBar: AppBar(title: Text(semesterName)),
            body: const Center(child: Text('Semester not found')),
          );
        }

        final gpaColor = AppColors.colorForGpa(semester.gpa);

        return Scaffold(
          appBar: AppBar(
            title: Text(semesterName),
          ),
          body: Column(
            children: [
              // GPA header card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: gpaColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: gpaColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'GPA',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: gpaColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: semester.gpa),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) => Text(
                            value.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: gpaColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: gpaColor.withValues(alpha: 0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          'Subjects',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: gpaColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${semester.subjects.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: gpaColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: gpaColor.withValues(alpha: 0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          'Credits',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: gpaColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${semester.totalCredits}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: gpaColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Subject list header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subjects',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Subject list
              Expanded(
                child: semester.subjects.isEmpty
                    ? const EmptyState(
                        icon: Icons.book_rounded,
                        title: 'No Subjects',
                        subtitle: 'Tap + to add your first subject.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: semester.subjects.length,
                        itemBuilder: (context, index) {
                          final sub = semester!.subjects[index];
                          return AnimatedListItem(
                            index: index,
                            child: SubjectTile(
                              subject: sub,
                              onEdit: () => _editSubject(
                                context,
                                semesterProv,
                                sub,
                              ),
                              onDelete: () => semesterProv.deleteSubject(
                                semesterId,
                                sub.id,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addSubject(context, semesterProv),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Future<void> _addSubject(
      BuildContext context, SemesterProvider prov) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const AddSubjectSheet(),
    );
    if (!context.mounted) return;
    if (result != null) {
      final scale = context.read<GradeScaleProvider>().activeScale;
      prov.addSubject(
        semesterId,
        name: result['name'],
        creditHours: result['creditHours'],
        grade: result['grade'],
        scale: scale,
      );
    }
  }

  Future<void> _editSubject(
    BuildContext context,
    SemesterProvider prov,
    subject,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddSubjectSheet(existingSubject: subject),
    );
    if (!context.mounted) return;
    if (result != null) {
      final scale = context.read<GradeScaleProvider>().activeScale;
      prov.updateSubject(
        semesterId,
        subject.id,
        name: result['name'],
        creditHours: result['creditHours'],
        grade: result['grade'],
        scale: scale,
      );
    }
  }
}
