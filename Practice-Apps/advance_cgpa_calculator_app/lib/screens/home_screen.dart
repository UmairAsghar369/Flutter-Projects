import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/semester_provider.dart';
import '../widgets/cgpa_summary_card.dart';
import '../widgets/semester_card.dart';
import '../widgets/add_semester_dialog.dart';
import '../widgets/gpa_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_list_item.dart';
import 'semester_detail_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'chart_screen.dart';

/// Main dashboard screen showing CGPA, chart, and semesters.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Sync semester provider with active profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncProfile();
    });
  }

  void _syncProfile() {
    final profile = context.read<ProfileProvider>().activeProfile;
    context.read<SemesterProvider>().setProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<ProfileProvider, SemesterProvider>(
      builder: (context, profileProv, semesterProv, _) {
        final profile = profileProv.activeProfile;

        // If no profile, prompt user to create one
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('CGPA Calculator')),
            body: EmptyState(
              icon: Icons.person_add_rounded,
              title: 'No Profile Yet',
              subtitle: 'Create your first profile to start tracking your GPA.',
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _createFirstProfile(context, profileProv),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Create Profile'),
            ),
          );
        }

        // Sync if profile changed
        if (semesterProv.semesters != profile.semesters) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            semesterProv.setProfile(profile);
          });
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                title: Text(profile.name),
                leading: IconButton(
                  icon: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 18),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()),
                  ).then((_) => _syncProfile()),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded),
                    tooltip: 'View Charts',
                    onPressed: semesterProv.semesters.isEmpty
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChartScreen(
                                  semesters: semesterProv.semesters,
                                ),
                              ),
                            ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // CGPA Summary Card
                    CgpaSummaryCard(
                      cgpa: semesterProv.cgpa,
                      totalCredits: semesterProv.totalCredits,
                      semesterCount: semesterProv.semesters.length,
                    ),
                    const SizedBox(height: 24),

                    // Mini GPA chart
                    if (semesterProv.semesters.length >= 2) ...[
                      Text(
                        'GPA Trend',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GpaChart(
                            semesters: semesterProv.semesters,
                            height: 180,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Semester list header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Semesters',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${semesterProv.semesters.length} total',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Semesters or empty state
                    if (semesterProv.semesters.isEmpty)
                      const EmptyState(
                        icon: Icons.school_rounded,
                        title: 'No Semesters',
                        subtitle:
                            'Tap + to add your first semester and start calculating.',
                      )
                    else
                      ...List.generate(
                        semesterProv.semesters.length,
                        (i) {
                          final sem = semesterProv.semesters[i];
                          return AnimatedListItem(
                            index: i,
                            child: SemesterCard(
                              semester: sem,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SemesterDetailScreen(
                                    semesterId: sem.id,
                                    semesterName: sem.name,
                                  ),
                                ),
                              ),
                              onDelete: () =>
                                  _confirmDelete(context, semesterProv, sem.id, sem.name),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 80), // FAB spacing
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addSemester(context, semesterProv),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Future<void> _addSemester(
      BuildContext context, SemesterProvider prov) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AddSemesterDialog(
        nextSemesterNumber: prov.semesters.length + 1,
      ),
    );
    if (name != null) {
      prov.addSemester(name);
    }
  }

  void _confirmDelete(BuildContext context, SemesterProvider prov,
      String semId, String semName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Semester'),
        content: Text('Delete "$semName" and all its subjects?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              prov.deleteSemester(semId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _createFirstProfile(
      BuildContext context, ProfileProvider prov) async {
    final controller = TextEditingController(text: 'My Profile');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
            hintText: 'e.g. BS Computer Science',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await prov.addProfile(name);
      _syncProfile();
    }
  }
}
