import 'package:flutter/material.dart';
import '../providers/cv_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cv_section_card.dart';

/// Hobby CV view — reads from CvProvider.
/// Shows: Hobbies, Interests, Personal Skills.
class HobbyCv extends StatefulWidget {
  const HobbyCv({super.key});

  @override
  State<HobbyCv> createState() => _HobbyCvState();
}

class _HobbyCvState extends State<HobbyCv>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = CvProvider.of(context);
    const accent = AppTheme.hobbyAccent;

    return FadeTransition(
      opacity: _fade,
      child: ListenableBuilder(
        listenable: provider,
        builder: (context, _) {
          final cv = provider.cv;
          final hobbies =
              cv.hobbies.where((h) => h.name.isNotEmpty).toList();
          final interests =
              cv.interests.where((s) => s.trim().isNotEmpty).toList();
          final personalSkills =
              cv.personalSkills.where((s) => s.trim().isNotEmpty).toList();

          return Column(
            children: [
              const SizedBox(height: 8),

              // ─── Hobbies ───
              CvSectionCard(
                icon: Icons.palette_rounded,
                title: 'Hobbies',
                accentColor: accent,
                child: hobbies.isEmpty
                    ? _EmptyHint(
                        message: 'No hobbies added yet.', color: accent)
                    : Column(
                        children: hobbies.asMap().entries.map((entry) {
                          final i = entry.key;
                          final h = entry.value;
                          return TweenAnimationBuilder<double>(
                            key: ValueKey(h.name),
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration:
                                Duration(milliseconds: 350 + (i * 100)),
                            curve: Curves.easeOut,
                            builder: (context, v, child) => Opacity(
                              opacity: v,
                              child: Transform.translate(
                                  offset: Offset(0, 18 * (1 - v)),
                                  child: child),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(
                                  bottom:
                                      i < hobbies.length - 1 ? 10 : 0),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.hobbySurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                        accent.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          accent.withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: AppTheme.hobbyPrimary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          h.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        if (h.description.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            h.description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),

              // ─── Interests ───
              CvSectionCard(
                icon: Icons.explore_rounded,
                title: 'Interests',
                accentColor: accent,
                child: interests.isEmpty
                    ? _EmptyHint(
                        message: 'No interests added yet.',
                        color: accent,
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: interests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.hobbyPrimary
                                      .withValues(alpha: 0.1),
                                  AppTheme.hobbyPrimary
                                      .withValues(alpha: 0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.hobbyPrimary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: AppTheme.hobbyPrimary),
                                const SizedBox(width: 6),
                                Text(
                                  interest,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.hobbyPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              // ─── Personal Skills ───
              CvSectionCard(
                icon: Icons.psychology_rounded,
                title: 'Personal Skills',
                accentColor: accent,
                child: personalSkills.isEmpty
                    ? _EmptyHint(
                        message: 'No personal skills added yet.',
                        color: accent,
                      )
                    : Column(
                        children: personalSkills
                            .asMap()
                            .entries
                            .map((entry) {
                          final i = entry.key;
                          final skill = entry.value;
                          final level =
                              0.65 + ((i % 4) * 0.09).clamp(0.0, 0.35);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${(level * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.hobbyPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: level),
                                  duration: Duration(
                                      milliseconds: 700 + i * 100),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, v, _) => Stack(
                                    children: [
                                      Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppTheme.hobbyPrimary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: v,
                                        child: Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            gradient:
                                                AppTheme.hobbyGradient,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
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

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

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
          Icon(Icons.info_outline_rounded,
              size: 16, color: color.withValues(alpha: 0.5)),
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
