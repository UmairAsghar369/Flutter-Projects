import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import '../widgets/student_card.dart';
import 'add_edit_student_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedBuilder(
                animation: StudentController.instance,
                builder: (context, child) {
                  final students = StudentController.instance.students;

                  if (students.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      // Use TweenAnimationBuilder for entrance animation
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(student.id),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 400)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: StudentCard(student: student, index: index),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditStudentScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF252538),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                ),
              ),
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                backgroundColor: Color(0xFF6C63FF),
              )
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Information Center',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage all student records efficiently.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 100,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Students Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to add a student.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
