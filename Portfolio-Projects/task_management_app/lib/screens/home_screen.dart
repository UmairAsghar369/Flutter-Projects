import 'package:flutter/material.dart';

import '../widgets/custom_bottom_nav.dart';
import 'today_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import '../constants/app_colors.dart';

/// Main home screen with bottom navigation for Today, Completed, and Repeated tabs.
///
/// Includes a FAB to add new tasks and a settings icon in the AppBar.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayTasksScreen(),
    CompletedTasksScreen(),
    RepeatedTasksScreen(),
  ];

  static const List<String> _titles = ['Today', 'Completed', 'Repeated'];

  late AnimationController _fabPulseController;
  late Animation<double> _fabPulse;

  @override
  void initState() {
    super.initState();
    _fabPulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _fabPulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _fabPulseController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabPulse,
        child: Hero(
          tag: 'add_task_fab',
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
