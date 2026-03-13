import 'package:flutter/material.dart';
import '../providers/cv_provider.dart';
import '../theme/app_theme.dart';
import 'cv_view_screen.dart';

/// Tabbed form screen where the user fills in their CV data.
/// Tab 0 = Professional (Name, Education, Skills, Experience)
/// Tab 1 = Hobby (Hobbies, Interests, Personal Skills)
class CvFormScreen extends StatefulWidget {
  /// If true, jump straight to the view after the form loads.
  final bool startOnViewTab;

  const CvFormScreen({super.key, this.startOnViewTab = false});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.startOnViewTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _viewCv());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _viewCv() {
    final provider = CvProvider.of(context);
    if (provider.cv.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your name first.'),
          backgroundColor: AppTheme.proPrimary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const CvViewScreen(),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.proSurface,
      body: Column(
        children: [
          // ─── Gradient app bar ───
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.proGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
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
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Build Your CV',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // View CV button
                        TextButton.icon(
                          onPressed: _viewCv,
                          icon: const Icon(
                            Icons.remove_red_eye_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Preview',
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
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.work_rounded, size: 20),
                        text: 'Professional',
                      ),
                      Tab(
                        icon: Icon(Icons.palette_rounded, size: 20),
                        text: 'Hobby',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Tab views ───
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ProfessionalFormTab(),
                _HobbyFormTab(),
              ],
            ),
          ),

          // ─── Bottom CTA ───
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _viewCv,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.proPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_rounded, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'View My CV',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Professional Form Tab
// ═══════════════════════════════════════════════════════════
class _ProfessionalFormTab extends StatelessWidget {
  const _ProfessionalFormTab();

  @override
  Widget build(BuildContext context) {
    final provider = CvProvider.of(context);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Basic Info ───
              _FormSection(
                icon: Icons.person_rounded,
                title: 'Basic Information',
                accentColor: AppTheme.proAccent,
                child: Column(
                  children: [
                    _CvTextField(
                      label: 'Full Name',
                      hint: 'e.g. Umair Asghar',
                      prefixIcon: Icons.badge_rounded,
                      initialValue: provider.cv.name,
                      onChanged: provider.updateName,
                    ),
                    const SizedBox(height: 12),
                    _CvTextField(
                      label: 'Email',
                      hint: 'e.g. umair@email.com',
                      prefixIcon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      initialValue: provider.cv.email,
                      onChanged: provider.updateEmail,
                    ),
                    const SizedBox(height: 12),
                    _CvTextField(
                      label: 'Phone',
                      hint: 'e.g. +92 300 1234567',
                      prefixIcon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      initialValue: provider.cv.phone,
                      onChanged: provider.updatePhone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Education ───
              _FormSection(
                icon: Icons.school_rounded,
                title: 'Education',
                accentColor: AppTheme.proAccent,
                trailing: _AddButton(
                  onTap: provider.addEducation,
                  color: AppTheme.proAccent,
                ),
                child: Column(
                  children: provider.cv.education.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return _EntryCard(
                      index: i,
                      accentColor: AppTheme.proAccent,
                      total: provider.cv.education.length,
                      onRemove: () => provider.removeEducation(i),
                      child: Column(
                        children: [
                          _CvTextField(
                            label: 'Degree / Qualification',
                            hint: 'e.g. BS Computer Science',
                            prefixIcon: Icons.menu_book_rounded,
                            initialValue: e.degree,
                            onChanged: (v) =>
                                provider.updateEducation(i, degree: v),
                          ),
                          const SizedBox(height: 10),
                          _CvTextField(
                            label: 'Institution',
                            hint: 'e.g. COMSATS University',
                            prefixIcon: Icons.account_balance_rounded,
                            initialValue: e.institution,
                            onChanged: (v) =>
                                provider.updateEducation(i, institution: v),
                          ),
                          const SizedBox(height: 10),
                          _CvTextField(
                            label: 'Year / Duration',
                            hint: 'e.g. 2020 – 2024',
                            prefixIcon: Icons.calendar_today_rounded,
                            initialValue: e.year,
                            onChanged: (v) =>
                                provider.updateEducation(i, year: v),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Skills ───
              _FormSection(
                icon: Icons.code_rounded,
                title: 'Skills',
                accentColor: AppTheme.proAccent,
                trailing: _AddButton(
                  onTap: provider.addSkill,
                  color: AppTheme.proAccent,
                ),
                child: Column(
                  children: provider.cv.skills.asMap().entries.map((entry) {
                    final i = entry.key;
                    return Row(
                      children: [
                        Expanded(
                          child: _CvTextField(
                            label: 'Skill ${i + 1}',
                            hint: 'e.g. Flutter & Dart',
                            prefixIcon: Icons.star_rounded,
                            initialValue: entry.value,
                            onChanged: (v) => provider.updateSkill(i, v),
                          ),
                        ),
                        if (provider.cv.skills.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              onPressed: () => provider.removeSkill(i),
                              icon: Icon(
                                Icons.remove_circle_rounded,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Work Experience ───
              _FormSection(
                icon: Icons.work_history_rounded,
                title: 'Work Experience',
                accentColor: AppTheme.proAccent,
                trailing: _AddButton(
                  onTap: provider.addExperience,
                  color: AppTheme.proAccent,
                ),
                child: Column(
                  children:
                      provider.cv.experience.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return _EntryCard(
                      index: i,
                      accentColor: AppTheme.proAccent,
                      total: provider.cv.experience.length,
                      onRemove: () => provider.removeExperience(i),
                      child: Column(
                        children: [
                          _CvTextField(
                            label: 'Job Title / Role',
                            hint: 'e.g. Flutter Developer',
                            prefixIcon: Icons.work_rounded,
                            initialValue: e.role,
                            onChanged: (v) =>
                                provider.updateExperience(i, role: v),
                          ),
                          const SizedBox(height: 10),
                          _CvTextField(
                            label: 'Company',
                            hint: 'e.g. Tech Solutions Inc.',
                            prefixIcon: Icons.business_rounded,
                            initialValue: e.company,
                            onChanged: (v) =>
                                provider.updateExperience(i, company: v),
                          ),
                          const SizedBox(height: 10),
                          _CvTextField(
                            label: 'Duration',
                            hint: 'e.g. Jan 2024 – Present',
                            prefixIcon: Icons.date_range_rounded,
                            initialValue: e.duration,
                            onChanged: (v) =>
                                provider.updateExperience(i, duration: v),
                          ),
                          const SizedBox(height: 10),
                          _CvTextField(
                            label: 'Description',
                            hint: 'Brief description of your role...',
                            prefixIcon: Icons.description_rounded,
                            maxLines: 3,
                            initialValue: e.description,
                            onChanged: (v) =>
                                provider.updateExperience(i, description: v),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Hobby Form Tab
// ═══════════════════════════════════════════════════════════
class _HobbyFormTab extends StatelessWidget {
  const _HobbyFormTab();

  @override
  Widget build(BuildContext context) {
    final provider = CvProvider.of(context);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // ─── Hobbies ───
              _FormSection(
                icon: Icons.palette_rounded,
                title: 'Hobbies',
                accentColor: AppTheme.hobbyAccent,
                trailing: _AddButton(
                  onTap: provider.addHobby,
                  color: AppTheme.hobbyAccent,
                ),
                child: Column(
                  children: provider.cv.hobbies.asMap().entries.map((entry) {
                    final i = entry.key;
                    final h = entry.value;
                    return _EntryCard(
                      index: i,
                      accentColor: AppTheme.hobbyAccent,
                      total: provider.cv.hobbies.length,
                      onRemove: () => provider.removeHobby(i),
                      child: Column(
                        children: [
                          _CvTextField(
                            label: 'Hobby Name',
                            hint: 'e.g. Photography',
                            prefixIcon: Icons.camera_alt_rounded,
                            initialValue: h.name,
                            onChanged: (v) =>
                                provider.updateHobby(i, name: v),
                          ),
                          const SizedBox(height: 10),
                          _CvTextField(
                            label: 'Description',
                            hint: 'Brief description...',
                            prefixIcon: Icons.notes_rounded,
                            maxLines: 2,
                            initialValue: h.description,
                            onChanged: (v) =>
                                provider.updateHobby(i, description: v),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Interests ───
              _FormSection(
                icon: Icons.explore_rounded,
                title: 'Interests',
                accentColor: AppTheme.hobbyAccent,
                trailing: _AddButton(
                  onTap: provider.addInterest,
                  color: AppTheme.hobbyAccent,
                ),
                child: Column(
                  children:
                      provider.cv.interests.asMap().entries.map((entry) {
                    final i = entry.key;
                    return Row(
                      children: [
                        Expanded(
                          child: _CvTextField(
                            label: 'Interest ${i + 1}',
                            hint: 'e.g. Artificial Intelligence',
                            prefixIcon: Icons.auto_awesome_rounded,
                            initialValue: entry.value,
                            onChanged: (v) => provider.updateInterest(i, v),
                          ),
                        ),
                        if (provider.cv.interests.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              onPressed: () => provider.removeInterest(i),
                              icon: Icon(
                                Icons.remove_circle_rounded,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Personal Skills ───
              _FormSection(
                icon: Icons.psychology_rounded,
                title: 'Personal Skills',
                accentColor: AppTheme.hobbyAccent,
                trailing: _AddButton(
                  onTap: provider.addPersonalSkill,
                  color: AppTheme.hobbyAccent,
                ),
                child: Column(
                  children: provider.cv.personalSkills.asMap().entries
                      .map((entry) {
                    final i = entry.key;
                    return Row(
                      children: [
                        Expanded(
                          child: _CvTextField(
                            label: 'Skill ${i + 1}',
                            hint: 'e.g. Leadership',
                            prefixIcon: Icons.emoji_people_rounded,
                            initialValue: entry.value,
                            onChanged: (v) =>
                                provider.updatePersonalSkill(i, v),
                          ),
                        ),
                        if (provider.cv.personalSkills.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              onPressed: () => provider.removePersonalSkill(i),
                              icon: Icon(
                                Icons.remove_circle_rounded,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Shared helper widgets (private, local to this file)
// ═══════════════════════════════════════════════════════════

/// Labeled form section with an icon header.
class _FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final Widget child;
  final Widget? trailing;

  const _FormSection({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Card wrapping a numbered entry with a remove button.
class _EntryCard extends StatelessWidget {
  final int index;
  final int total;
  final Color accentColor;
  final VoidCallback onRemove;
  final Widget child;

  const _EntryCard({
    required this.index,
    required this.total,
    required this.accentColor,
    required this.onRemove,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: index < total - 1 ? 12 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.proSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (total > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade300,
                    size: 20,
                  ),
                ),
              ],
            ),
          if (total > 1) const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Compact [+ Add] button.
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const _AddButton({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Styled text field used throughout the form.
class _CvTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final int maxLines;

  const _CvTextField({
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.55),
          fontSize: 13,
        ),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppTheme.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.proAccent, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
