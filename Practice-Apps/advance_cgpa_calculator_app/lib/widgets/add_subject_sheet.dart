import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../models/grade_scale.dart';
import '../providers/grade_scale_provider.dart';
import '../widgets/gradient_button.dart';

/// Bottom sheet for adding or editing a subject.
class AddSubjectSheet extends StatefulWidget {
  final Subject? existingSubject; // null for add, non-null for edit

  const AddSubjectSheet({super.key, this.existingSubject});

  @override
  State<AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<AddSubjectSheet> {
  late TextEditingController _nameController;
  late int _creditHours;
  late String _selectedGrade;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingSubject?.name ?? '');
    _creditHours = widget.existingSubject?.creditHours ?? 3;
    _selectedGrade = widget.existingSubject?.grade ?? 'A';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = context.watch<GradeScaleProvider>().activeScale;
    final isEditing = widget.existingSubject != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing ? 'Edit Subject' : 'Add Subject',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Subject name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                hintText: 'e.g. Mathematics',
                prefixIcon: Icon(Icons.book_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Credit hours
            Text('Credit Hours', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: List.generate(6, (i) {
                final value = i + 1;
                final isSelected = _creditHours == value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _creditHours = value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Grade dropdown
            Text('Grade', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _GradeSelector(
              scale: scale,
              selectedGrade: _selectedGrade,
              onChanged: (grade) => setState(() => _selectedGrade = grade),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: isEditing ? 'Update Subject' : 'Add Subject',
                icon: isEditing ? Icons.check_rounded : Icons.add_rounded,
                onPressed: _save,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject name')),
      );
      return;
    }
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'creditHours': _creditHours,
      'grade': _selectedGrade,
    });
  }
}

/// Grid of grade chips for selection.
class _GradeSelector extends StatelessWidget {
  final GradeScale scale;
  final String selectedGrade;
  final ValueChanged<String> onChanged;

  const _GradeSelector({
    required this.scale,
    required this.selectedGrade,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: scale.letters.map((letter) {
        final isSelected = selectedGrade == letter;
        return GestureDetector(
          onTap: () => onChanged(letter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.cardTheme.color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              letter,
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
