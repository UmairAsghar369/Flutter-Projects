import 'package:flutter/material.dart';
import '../providers/cv_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cv_toggle.dart';
import '../widgets/profile_header.dart';
import '../widgets/professional_cv.dart';
import '../widgets/hobby_cv.dart';
import 'cv_form_screen.dart';

/// Read-only CV viewer — shows Professional or Hobby CV based on the toggle.
/// Professional CV is shown by default on each visit.
class CvViewScreen extends StatefulWidget {
  const CvViewScreen({super.key});

  @override
  State<CvViewScreen> createState() => _CvViewScreenState();
}

class _CvViewScreenState extends State<CvViewScreen> {
  // Local toggle state — defaults to Professional on every open.
  bool _isProfessional = true;

  @override
  Widget build(BuildContext context) {
    final provider = CvProvider.of(context);
    final gradient =
        _isProfessional ? AppTheme.proGradient : AppTheme.hobbyGradient;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: _isProfessional ? AppTheme.proSurface : AppTheme.hobbySurface,
        child: Column(
          children: [
            // ─── Gradient header band ───
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(gradient: gradient),
              child: Column(
                children: [
                  // Back + Edit action row
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Back
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Edit button
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CvFormScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_rounded,
                                size: 17, color: Colors.white),
                            label: const Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Profile header
                  ListenableBuilder(
                    listenable: provider,
                    builder: (context, _) => ProfileHeader(
                      isProfessional: _isProfessional,
                    ),
                  ),
                  // Toggle
                  CvToggle(
                    isProfessional: _isProfessional,
                    onChanged: (val) => setState(() => _isProfessional = val),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ─── CV content with animated switching ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.07),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _isProfessional
                      ? const ProfessionalCv(key: ValueKey('pro'))
                      : const HobbyCv(key: ValueKey('hobby')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
