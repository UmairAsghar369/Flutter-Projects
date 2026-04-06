import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';

/// Screen for adding a new task or editing an existing one.
///
/// All form fields, including subtasks, repeat config, and reminder
/// options, are managed here with proper validation.
class AddEditTaskScreen extends StatefulWidget {
  /// If provided, the screen operates in edit mode.
  final Task? task;

  /// Creates an [AddEditTaskScreen].
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String _category = 'Work';
  int _priority = 1;
  bool _isRepeating = false;
  String _repeatType = 'daily';
  List<bool> _repeatDays = List.filled(7, false);

  // Reminder
  int? _reminderMinutes;
  DateTime? _customReminderDateTime;

  // Subtasks
  final List<TextEditingController> _subtaskControllers = [];

  bool get _isEditing => widget.task != null;

  // Stagger animation
  late AnimationController _staggerController;

  static const List<String> _categories = [
    'Work',
    'Personal',
    'Health',
    'Study',
    'Other',
  ];

  static const List<String> _dayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static const Map<String, int?> _reminderOptions = {
    'None': null,
    '5 min': 5,
    '10 min': 10,
    '15 min': 15,
    '30 min': 30,
    '1 hour': 60,
    '2 hours': 120,
    'Custom': -1,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    if (_isEditing) {
      final t = widget.task!;
      if (t.dueDate != null) {
        try {
          _dueDate = DateTime.parse(t.dueDate!);
        } catch (_) {}
      }
      if (t.dueTime != null) {
        final parts = t.dueTime!.split(':');
        if (parts.length == 2) {
          _dueTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      _category = t.category ?? 'Work';
      _priority = t.priority;
      _isRepeating = t.isRepeating;
      _repeatType = t.repeatType ?? 'daily';
      if (t.repeatDays != null && t.repeatDays!.isNotEmpty) {
        final days = t.repeatDays!.split(',').map((d) => int.tryParse(d.trim()));
        for (final d in days) {
          if (d != null && d >= 1 && d <= 7) {
            _repeatDays[d - 1] = true;
          }
        }
      }
      _reminderMinutes = t.reminderMinutes;

      // Handle custom reminder minutes not in predefined options
      if (!_reminderOptions.containsValue(_reminderMinutes) && _reminderMinutes != null) {
        if (t.dueDate != null && t.dueTime != null) {
          try {
            final dd = DateTime.parse(t.dueDate!);
            final parts = t.dueTime!.split(':');
            final dueDT = DateTime(dd.year, dd.month, dd.day, int.parse(parts[0]), int.parse(parts[1]));
            _customReminderDateTime = dueDT.subtract(Duration(minutes: _reminderMinutes!));
          } catch (_) {}
        }
        _reminderMinutes = -1;
      }
      // Load existing subtasks
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<TaskProvider>();
        final subs = provider.subtasksFor(t.id!);
        setState(() {
          for (final s in subs) {
            _subtaskControllers.add(TextEditingController(text: s.title));
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _staggerController.dispose();
    for (final c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _buildFormFields(isDark),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              _isEditing ? 'Update Task' : 'Add Task',
              style: AppTextStyles.button(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(bool isDark) {
    final fields = <Widget>[
      // Title
      _buildAnimatedField(
        index: 0,
        child: TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Enter task title',
            prefixIcon: Icon(Icons.title_rounded),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Title is required' : null,
        ),
      ),
      const SizedBox(height: 12),

      // Description
      _buildAnimatedField(
        index: 1,
        child: TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'Enter description',
            prefixIcon: Icon(Icons.description_rounded),
          ),
          maxLines: 3,
          minLines: 1,
        ),
      ),
      const SizedBox(height: 12),

      // Due Date
      _buildAnimatedField(
        index: 2,
        child: ListTile(
          leading: const Icon(Icons.calendar_today_rounded),
          title: Text(
            _dueDate != null
                ? DateFormat('EEE, MMM d, yyyy').format(_dueDate!)
                : 'Select Due Date',
            style: AppTextStyles.body(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          onTap: _pickDate,
        ),
      ),
      const SizedBox(height: 12),

      // Due Time
      _buildAnimatedField(
        index: 3,
        child: ListTile(
          leading: const Icon(Icons.access_time_rounded),
          title: Text(
            _dueTime != null ? _dueTime!.format(context) : 'Select Due Time',
            style: AppTextStyles.body(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          onTap: _pickTime,
        ),
      ),
      const SizedBox(height: 12),

      // Category
      _buildAnimatedField(
        index: 4,
        child: DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category_rounded),
          ),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _category = value);
          },
        ),
      ),
      const SizedBox(height: 12),

      // Priority
      _buildAnimatedField(
        index: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Priority',
                style: AppTextStyles.body(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('Low')),
                ButtonSegment(value: 2, label: Text('Medium')),
                ButtonSegment(value: 3, label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (v) =>
                  setState(() => _priority = v.first),
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      // Repeat Toggle
      _buildAnimatedField(
        index: 6,
        child: SwitchListTile(
          title: const Text('Repeat Task'),
          secondary: const Icon(Icons.repeat_rounded),
          value: _isRepeating,
          onChanged: (v) => setState(() => _isRepeating = v),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
      ),

      // Repeat days selector
      if (_isRepeating) ...[
        const SizedBox(height: 12),
        _buildAnimatedField(
          index: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Daily'),
                    selected: _repeatType == 'daily',
                    onSelected: (v) {
                      if (v) {
                        setState(() {
                          _repeatType = 'daily';
                          _repeatDays = List.filled(7, true);
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _repeatType == 'custom',
                    onSelected: (v) {
                      if (v) {
                        setState(() {
                          _repeatType = 'custom';
                          _repeatDays = List.filled(7, false);
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_repeatType == 'custom') ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (i) {
                    return FilterChip(
                      label: Text(_dayLabels[i]),
                      selected: _repeatDays[i],
                      onSelected: (v) {
                        setState(() => _repeatDays[i] = v);
                      },
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ],
      const SizedBox(height: 12),

      // Set Reminder
      _buildAnimatedField(
        index: 8,
        child: DropdownButtonFormField<int?>(
          initialValue: _reminderMinutes,
          decoration: const InputDecoration(
            labelText: 'Set Reminder',
            prefixIcon: Icon(Icons.notifications_active_rounded),
          ),
          items: _reminderOptions.entries
              .map((e) => DropdownMenuItem(
                    value: e.value,
                    child: Text(e.key),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _reminderMinutes = value);
            if (value == -1) {
              _pickCustomReminder();
            }
          },
        ),
      ),

      if (_reminderMinutes == -1 && _customReminderDateTime != null) ...[
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Custom: ${DateFormat('MMM d, yyyy – HH:mm').format(_customReminderDateTime!)}',
            style: AppTextStyles.caption(color: AppColors.accent),
          ),
        ),
      ],
      const SizedBox(height: 16),

      // Subtasks section
      _buildAnimatedField(
        index: 9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Subtasks',
                  style: AppTextStyles.h3(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addSubtaskField,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            ..._subtaskControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          hintText: 'Subtask ${entry.key + 1}',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline_rounded,
                          color: Colors.red.shade400, size: 20),
                      onPressed: () => _removeSubtaskField(entry.key),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];

    return fields;
  }

  Widget _buildAnimatedField({required int index, required Widget child}) {
    final delay = index * 0.05;
    final begin = (delay).clamp(0.0, 1.0);
    final end = (delay + 0.3).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(begin, end, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(begin, end, curve: Curves.easeOut),
          ),
        ),
        child: child,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _pickCustomReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _customReminderDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtaskField(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  /// Shows a bottom sheet prompting the user to optionally set a due time.
  ///
  /// Returns 'proceed' if saving should continue (quick choice or skip),
  /// 'custom' if the user wants to pick a custom date/time, or
  /// null if the sheet was dismissed without a choice.
  Future<String?> _showTimerBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TimerPromptSheet(
        onQuickTime: (DateTime dt) {
          setState(() {
            _dueDate = DateTime(dt.year, dt.month, dt.day);
            _dueTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
          });
          Navigator.pop(ctx, 'proceed');
        },
        onCustomTime: () => Navigator.pop(ctx, 'custom'),
        onSkip: () => Navigator.pop(ctx, 'proceed'),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    // Capture providers synchronously before any async gaps
    final provider = context.read<TaskProvider>();
    final themeProvider = context.read<ThemeProvider>();

    // ── Timer prompt: ask user to set due time if none is set ─────
    if (!_isEditing && _dueTime == null) {
      final result = await _showTimerBottomSheet();
      if (result == null) return; // user dismissed the sheet
      if (result == 'custom') {
        await _pickDate();
        if (!mounted || _dueDate == null) return; // date picker cancelled
        await _pickTime();
        if (!mounted) return;
      }
    }

    // Validate: due time required if reminder is set
    if (_reminderMinutes != null && _dueTime == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Due time is required when reminder is set')),
      );
      return;
    }

    // Build repeat_days string
    String? repeatDays;
    if (_isRepeating) {
      if (_repeatType == 'daily') {
        repeatDays = '1,2,3,4,5,6,7';
      } else {
        final selected = <int>[];
        for (int i = 0; i < _repeatDays.length; i++) {
          if (_repeatDays[i]) selected.add(i + 1);
        }
        repeatDays = selected.join(',');
      }
    }

    final dueDate = _dueDate != null
        ? DateFormat('yyyy-MM-dd').format(_dueDate!)
        : null;
    final dueTime = _dueTime != null
        ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
        : null;

    // Determine actual reminder minutes
    int? actualReminderMinutes = _reminderMinutes;
    if (_reminderMinutes == -1 && _customReminderDateTime != null) {
      // For custom, we still want to store it meaningfully
      // We'll compute how many minutes before the due time
      if (dueDate != null && dueTime != null) {
        final dueDateTime = DateTime(
          _dueDate!.year, _dueDate!.month, _dueDate!.day,
          _dueTime!.hour, _dueTime!.minute,
        );
        actualReminderMinutes =
            dueDateTime.difference(_customReminderDateTime!).inMinutes;
        if (actualReminderMinutes < 0) actualReminderMinutes = 0;
      } else {
        actualReminderMinutes = null;
      }
    }

    final subtaskTitles =
        _subtaskControllers.map((c) => c.text).where((t) => t.trim().isNotEmpty).toList();

    // ── Step 1: Save task to DB (must always succeed) ─────────────
    Task? savedTask;
    try {
      if (_isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: dueDate,
          dueTime: dueTime,
          category: _category,
          priority: _priority,
          isRepeating: _isRepeating,
          repeatType: _isRepeating ? _repeatType : null,
          repeatDays: _isRepeating ? repeatDays : null,
          reminderMinutes: actualReminderMinutes,
        );
        await provider.updateTask(updated, subtasks: subtaskTitles);
        savedTask = updated;
      } else {
        final newTask = Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: dueDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
          dueTime: dueTime,
          category: _category,
          priority: _priority,
          isRepeating: _isRepeating,
          repeatType: _isRepeating ? _repeatType : null,
          repeatDays: _isRepeating ? repeatDays : null,
          reminderMinutes: actualReminderMinutes,
        );
        savedTask = await provider.addTask(newTask, subtasks: subtaskTitles);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
      return; // Stop here — DB save failed
    }

    // Navigate back immediately after DB save — notifications are best-effort
    if (mounted) Navigator.of(context).pop();

    // ── Step 2: Schedule notifications (best-effort, never blocks UI) ──
    // All NotificationService methods already handle errors internally;
    // this extra try-catch is a final safety net.
    try {
      final soundName = themeProvider.notificationSound == 'default'
          ? null
          : themeProvider.notificationSound;

      if (_isEditing) {
        // Cancel old notifications first
        if (savedTask.notificationId != null) {
          await NotificationService.instance
              .cancelNotification(savedTask.notificationId!);
        }
        if (dueDate != null && dueTime != null) {
          final dueDateTime = DateTime(
            _dueDate!.year, _dueDate!.month, _dueDate!.day,
            _dueTime!.hour, _dueTime!.minute,
          );
          if (actualReminderMinutes != null && actualReminderMinutes > 0) {
            final reminderTime =
                dueDateTime.subtract(Duration(minutes: actualReminderMinutes));
            await NotificationService.instance.scheduleReminder(
              notificationId: savedTask.notificationId ?? savedTask.id!,
              taskTitle: savedTask.title,
              scheduledDate: reminderTime,
              reminderMinutes: actualReminderMinutes,
              soundName: soundName,
            );
          }
          await NotificationService.instance.scheduleDueTimeNotification(
            taskId: savedTask.id!,
            taskTitle: savedTask.title,
            dueDateTime: dueDateTime,
            soundName: soundName,
          );
        }
      } else {
        // Instant "task added" notification
        await NotificationService.instance.showTaskAddedNotification(
          taskId: savedTask.id!,
          taskTitle: savedTask.title,
          soundName: soundName,
        );
        // Time-based notifications if due time is set
        if (dueTime != null) {
          final taskDueDate = _dueDate ?? DateTime.now();
          final dueDateTime = DateTime(
            taskDueDate.year, taskDueDate.month, taskDueDate.day,
            _dueTime!.hour, _dueTime!.minute,
          );
          if (actualReminderMinutes != null && actualReminderMinutes > 0) {
            final reminderTime =
                dueDateTime.subtract(Duration(minutes: actualReminderMinutes));
            await NotificationService.instance.scheduleReminder(
              notificationId: savedTask.notificationId ?? savedTask.id!,
              taskTitle: savedTask.title,
              scheduledDate: reminderTime,
              reminderMinutes: actualReminderMinutes,
              soundName: soundName,
            );
          }
          await NotificationService.instance.scheduleDueTimeNotification(
            taskId: savedTask.id!,
            taskTitle: savedTask.title,
            dueDateTime: dueDateTime,
            soundName: soundName,
          );
        }
      }
    } catch (e) {
      // Notification scheduling failed but task was saved — just log it.
      debugPrint('_saveTask: notification scheduling error (non-fatal): $e');
    }
  }
}

// ── Timer Prompt Sheet ────────────────────────────────────────────────────

class _TimerPromptSheet extends StatelessWidget {
  final void Function(DateTime dt) onQuickTime;
  final VoidCallback onCustomTime;
  final VoidCallback onSkip;

  const _TimerPromptSheet({
    required this.onQuickTime,
    required this.onCustomTime,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final in1h = now.add(const Duration(hours: 1));
    final in2h = now.add(const Duration(hours: 2));
    final tonight = DateTime(now.year, now.month, now.day, 21, 0);
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowMorning =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_add_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Set a Due Time?',
            style: AppTextStyles.h3(
              color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'When should this task be completed?',
            style: AppTextStyles.body(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Quick time options grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.2,
            children: [
              _QuickTimeChip(
                label: 'In 1 Hour',
                icon: Icons.hourglass_top_rounded,
                color: AppColors.primary,
                onTap: () => onQuickTime(in1h),
              ),
              _QuickTimeChip(
                label: 'In 2 Hours',
                icon: Icons.hourglass_bottom_rounded,
                color: AppColors.accent,
                onTap: () => onQuickTime(in2h),
              ),
              _QuickTimeChip(
                label: 'Tonight 9 PM',
                icon: Icons.nightlight_round,
                color: AppColors.accentAmber,
                onTap: () => onQuickTime(tonight),
              ),
              _QuickTimeChip(
                label: 'Tomorrow 9 AM',
                icon: Icons.wb_sunny_rounded,
                color: AppColors.accentGreen,
                onTap: () => onQuickTime(tomorrowMorning),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom time button
          OutlinedButton.icon(
            onPressed: onCustomTime,
            icon: const Icon(Icons.edit_calendar_rounded),
            label: const Text('Pick Custom Date & Time'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Skip button
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Skip — Save without due time',
              style: AppTextStyles.body(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Time Chip ───────────────────────────────────────────────────────

class _QuickTimeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickTimeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
