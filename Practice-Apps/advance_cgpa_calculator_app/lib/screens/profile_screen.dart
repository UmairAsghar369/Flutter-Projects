import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/gradient_button.dart';

/// Screen to manage multiple student profiles.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Avatar icons list
  static const List<IconData> avatarIcons = [
    Icons.person_rounded,
    Icons.school_rounded,
    Icons.engineering_rounded,
    Icons.science_rounded,
    Icons.biotech_rounded,
    Icons.computer_rounded,
    Icons.brush_rounded,
    Icons.music_note_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profiles')),
      body: Consumer<ProfileProvider>(
        builder: (context, prov, _) {
          if (prov.profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text('No profiles yet',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Create Profile',
                    icon: Icons.person_add_rounded,
                    onPressed: () => _addProfile(context, prov),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.profiles.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              if (index == prov.profiles.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: GradientButton(
                    text: 'Add New Profile',
                    icon: Icons.person_add_rounded,
                    onPressed: () => _addProfile(context, prov),
                    gradient: AppColors.accentGradient,
                  ),
                );
              }

              final profile = prov.profiles[index];
              final isActive = profile.id == prov.activeProfileId;

              return AnimatedListItem(
                index: index,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isActive
                        ? BorderSide(
                            color: AppColors.primaryStart,
                            width: 2,
                          )
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () {
                      prov.switchProfile(profile.id);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isActive
                                ? AppColors.primaryStart
                                : Colors.grey.shade300,
                            child: Icon(
                              avatarIcons[profile.avatarIndex %
                                  avatarIcons.length],
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryStart
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Active',
                                          style: TextStyle(
                                            color: AppColors.primaryStart,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'CGPA: ${profile.cgpa.toStringAsFixed(2)} • ${profile.semesters.length} semesters',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          // Delete
                          if (prov.profiles.length > 1)
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: Colors.red.shade300),
                              onPressed: () => _confirmDelete(
                                  context, prov, profile.id, profile.name),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addProfile(
      BuildContext context, ProfileProvider prov) async {
    final controller = TextEditingController();
    int selectedAvatar = 0;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  hintText: 'e.g. BS Computer Science',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Choose Avatar'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(avatarIcons.length, (i) {
                  final isSelected = selectedAvatar == i;
                  return GestureDetector(
                    onTap: () => setState(() => selectedAvatar = i),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: isSelected
                          ? AppColors.primaryStart
                          : Colors.grey.shade200,
                      child: Icon(
                        avatarIcons[i],
                        color:
                            isSelected ? Colors.white : Colors.grey.shade600,
                        size: 22,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, {
                    'name': controller.text.trim(),
                    'avatar': selectedAvatar,
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await prov.addProfile(result['name'], avatarIndex: result['avatar']);
    }
  }

  void _confirmDelete(BuildContext context, ProfileProvider prov,
      String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Delete "$name" and all its data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              prov.deleteProfile(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
