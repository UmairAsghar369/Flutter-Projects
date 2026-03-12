import 'package:flutter/material.dart';
import '../models/semester.dart';
import '../theme/app_colors.dart';

/// Card widget for displaying a semester in the list.
class SemesterCard extends StatelessWidget {
  final Semester semester;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SemesterCard({
    super.key,
    required this.semester,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gpaColor = AppColors.colorForGpa(semester.gpa);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // GPA circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gpaColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    semester.gpa.toStringAsFixed(2),
                    style: TextStyle(
                      color: gpaColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${semester.subjects.length} subjects • ${semester.totalCredits} credits',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade300,
                ),
                onPressed: onDelete,
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
