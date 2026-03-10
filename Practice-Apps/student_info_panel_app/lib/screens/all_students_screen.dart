import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/student.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/student_card.dart';
import 'student_detail_screen.dart';

class AllStudentsScreen extends StatefulWidget {
  final VoidCallback? onStudentUpdated;

  const AllStudentsScreen({super.key, this.onStudentUpdated});

  @override
  State<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends State<AllStudentsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _searchQuery = '';
  String _filterDepartment = 'All';
  String _filterGender = 'All';
  String _sortBy = 'Name';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Student> get _filteredStudents {
    var students = List<Student>.from(DummyData.students);

    // Search
    if (_searchQuery.isNotEmpty) {
      students = students
          .where((s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.regNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.email.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by department
    if (_filterDepartment != 'All') {
      students =
          students.where((s) => s.department == _filterDepartment).toList();
    }

    // Filter by gender
    if (_filterGender != 'All') {
      students = students.where((s) => s.gender == _filterGender).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Name':
        students.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Reg No':
        students.sort((a, b) => a.regNo.compareTo(b.regNo));
        break;
      case 'CGPA':
        students.sort((a, b) => b.cgpa.compareTo(a.cgpa));
        break;
      case 'Department':
        students.sort((a, b) => a.department.compareTo(b.department));
        break;
    }

    return students;
  }

  @override
  Widget build(BuildContext context) {
    final students = _filteredStudents;
    final departments = ['All', ...DummyData.students.map((s) => s.department).toSet()];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'All Students',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${students.length} students found',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSortButton(),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Search Bar ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF3A4A6B), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search by name, reg no, or email...',
                      hintStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppTheme.accentPurple),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppTheme.textMuted, size: 20),
                              onPressed: () {
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) =>
                        setState(() => _searchQuery = val),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ─── Filter Chips ───
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildFilterChip('All', _filterGender == 'All' && _filterDepartment == 'All',
                        () {
                      setState(() {
                        _filterGender = 'All';
                        _filterDepartment = 'All';
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        '♂ Male', _filterGender == 'Male', () {
                      setState(() => _filterGender =
                          _filterGender == 'Male' ? 'All' : 'Male');
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        '♀ Female', _filterGender == 'Female', () {
                      setState(() => _filterGender =
                          _filterGender == 'Female' ? 'All' : 'Female');
                    }),
                    const SizedBox(width: 8),
                    ...departments.where((d) => d != 'All').map((dept) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          dept.split(' ').map((w) => w[0]).join(''),
                          _filterDepartment == dept,
                          () {
                            setState(() => _filterDepartment =
                                _filterDepartment == dept ? 'All' : dept);
                          },
                          tooltip: dept,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ─── Student List ───
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64,
                                color: AppTheme.textMuted
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            const Text(
                              'No students found',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          return StudentCard(
                            student: students[index],
                            index: index,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                FadeSlideTransition(
                                  page: StudentDetailScreen(
                                    student: students[index],
                                    isAdmin: true,
                                    onStudentUpdated: () {
                                      setState(() {});
                                      widget.onStudentUpdated?.call();
                                    },
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap,
      {String? tooltip}) {
    final chip = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.surfaceLight,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF3A4A6B),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentPurple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: chip);
    }
    return chip;
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child:
            const Icon(Icons.sort_rounded, color: AppTheme.textSecondary, size: 20),
      ),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) => setState(() => _sortBy = value),
      itemBuilder: (context) => [
        _buildSortItem('Name', Icons.sort_by_alpha_rounded),
        _buildSortItem('Reg No', Icons.numbers_rounded),
        _buildSortItem('CGPA', Icons.bar_chart_rounded),
        _buildSortItem('Department', Icons.business_rounded),
      ],
    );
  }

  PopupMenuItem<String> _buildSortItem(String label, IconData icon) {
    final isSelected = _sortBy == label;
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isSelected ? AppTheme.accentPurple : AppTheme.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.accentPurple : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check_rounded,
                size: 16, color: AppTheme.accentPurple),
          ],
        ],
      ),
    );
  }
}
