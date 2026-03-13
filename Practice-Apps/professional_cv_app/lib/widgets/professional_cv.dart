import 'package:flutter/material.dart';
import '../providers/cv_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cv_section_card.dart';

/// Professional CV view — reads from CvProvider.
/// Shows: Education, Skills, Work Experience.
class ProfessionalCv extends StatelessWidget {
  const ProfessionalCv({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = CvProvider.of(context);
    const accent = AppTheme.proAccent;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final cv = provider.cv;

        // Filter out empty entries so blanks don't render
        final education =
            cv.education.where((e) => e.degree.isNotEmpty).toList();
        final skills =
            cv.skills.where((s) => s.trim().isNotEmpty).toList();
        final experience =
            cv.experience.where((e) => e.role.isNotEmpty).toList();

        return Column(
          children: [
            const SizedBox(height: 8),

            // ─── Education ───
            CvSectionCard(
              icon: Icons.school_rounded,
              title: 'Education',
              accentColor: accent,
              child: education.isEmpty
                  ? _EmptyHint(
                      message: 'No education added yet.',
                      color: accent,
                    )
                  : Column(
                      children: education.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.degree,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (e.institution.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        e.institution,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                    if (e.year.isNotEmpty)
                                      Text(
                                        e.year,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            // ─── Skills ───
            CvSectionCard(
              icon: Icons.code_rounded,
              title: 'Skills',
              accentColor: accent,
              child: skills.isEmpty
                  ? _EmptyHint(message: 'No skills added yet.', color: accent)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.1),
                                accent.withValues(alpha: 0.04),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: accent.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            skill,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.proPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),

            // ─── Work Experience ───
            CvSectionCard(
              icon: Icons.work_history_rounded,
              title: 'Work Experience',
              accentColor: accent,
              child: experience.isEmpty
                  ? _EmptyHint(
                      message: 'No experience added yet.', color: accent)
                  : Column(
                      children: experience.asMap().entries.map((entry) {
                        final e = entry.value;
                        final isLast = entry.key == experience.length - 1;
                        return Container(
                          margin:
                              EdgeInsets.only(bottom: isLast ? 0 : 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.proSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.business_rounded,
                                      size: 18, color: accent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.role,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (e.company.isNotEmpty ||
                                  e.duration.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  [e.company, e.duration]
                                      .where((s) => s.isNotEmpty)
                                      .join('  •  '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if (e.description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  e.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

/// Shown when a section has no data yet.
class _EmptyHint extends StatelessWidget {
  final String message;
  final Color color;
  const _EmptyHint({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16,
              color: color.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
