import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

/// Settings screen for theme toggle, notification sound, export, and about.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ──
          _SectionHeader(title: 'Appearance', isDark: isDark),
          const SizedBox(height: 8),
          _buildThemeToggle(context, themeProvider, isDark),
          const SizedBox(height: 20),

          // ── Notifications ──
          _SectionHeader(title: 'Notifications', isDark: isDark),
          const SizedBox(height: 8),
          const _PermissionStatusSection(),
          const SizedBox(height: 12),
          _buildSoundSelector(context, themeProvider, isDark),
          const SizedBox(height: 20),

          // ── Export ──
          _SectionHeader(title: 'Export Data', isDark: isDark),
          const SizedBox(height: 8),
          _buildExportButtons(context, isDark),
          const SizedBox(height: 20),

          // ── About ──
          _SectionHeader(title: 'About', isDark: isDark),
          const SizedBox(height: 8),
          _buildAboutSection(isDark),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(
      BuildContext context, ThemeProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: ListTile(
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              RotationTransition(turns: animation, child: child),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            key: ValueKey(isDark),
            color: isDark ? AppColors.accent : AppColors.accentAmber,
          ),
        ),
        title: Text(
          isDark ? 'Dark Mode' : 'Light Mode',
          style: AppTextStyles.body(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        trailing: GestureDetector(
          onTap: provider.toggleTheme,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark ? AppColors.accent : AppColors.primary,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment:
                  isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 14,
                  color: isDark ? AppColors.accent : AppColors.accentAmber,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoundSelector(
      BuildContext context, ThemeProvider provider, bool isDark) {
    const sounds = ['default', 'bell', 'chime'];
    const soundLabels = {'default': 'Default', 'bell': 'Bell', 'chime': 'Chime'};

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Sound',
            style: AppTextStyles.body(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: sounds.map((sound) {
              final isSelected = provider.notificationSound == sound;
              return ChoiceChip(
                label: Text(soundLabels[sound] ?? sound),
                selected: isSelected,
                onSelected: (_) => provider.setNotificationSound(sound),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _ExportButton(
            icon: Icons.table_chart_rounded,
            label: 'Export to CSV',
            color: AppColors.accentGreen,
            onTap: () => _exportCsv(context),
          ),
          const Divider(height: 1),
          _ExportButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Export to PDF',
            color: AppColors.accentWarm,
            onTap: () => _exportPdf(context),
          ),
          const Divider(height: 1),
          _ExportButton(
            icon: Icons.email_rounded,
            label: 'Export via Email',
            color: AppColors.primary,
            onTap: () => _exportEmail(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TaskFlow', style: AppTextStyles.h3(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: AppTextStyles.caption(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'University Mid-Term Project\nFlutter Task Management Application\nPowered by SQLite & Provider',
            style: AppTextStyles.body(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final provider = context.read<TaskProvider>();
      final tasks = provider.allTasks;

      final rows = <List<String>>[
        [
          'Title',
          'Description',
          'Due Date',
          'Due Time',
          'Category',
          'Priority',
          'Completed',
          'Repeating',
          'Repeat Days',
        ],
        ...tasks.map((t) => [
              t.title,
              t.description ?? '',
              t.dueDate ?? '',
              t.dueTime ?? '',
              t.category ?? '',
              t.priority == 3
                  ? 'High'
                  : t.priority == 2
                      ? 'Medium'
                      : 'Low',
              t.isCompleted ? 'Yes' : 'No',
              t.isRepeating ? 'Yes' : 'No',
              t.repeatDays ?? '',
            ]),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/taskflow_export.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'TaskFlow - Tasks Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final provider = context.read<TaskProvider>();
      final tasks = provider.allTasks;
      final completed = tasks.where((t) => t.isCompleted).length;
      final pending = tasks.where((t) => !t.isCompleted).length;
      final repeating = tasks.where((t) => t.isRepeating).length;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pdfContext) => [
            pw.Header(
              level: 0,
              child: pw.Text('TaskFlow - Task Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _pdfStatBox('Total', tasks.length.toString()),
                _pdfStatBox('Completed', completed.toString()),
                _pdfStatBox('Pending', pending.toString()),
                _pdfStatBox('Repeating', repeating.toString()),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellPadding: const pw.EdgeInsets.all(6),
              headers: [
                'Title',
                'Category',
                'Priority',
                'Due Date',
                'Status'
              ],
              data: tasks
                  .map((t) => [
                        t.title,
                        t.category ?? '-',
                        t.priority == 3
                            ? 'High'
                            : t.priority == 2
                                ? 'Medium'
                                : 'Low',
                        t.dueDate ?? '-',
                        t.isCompleted ? 'Done' : 'Pending',
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Exported on ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/taskflow_report.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'TaskFlow - PDF Report',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    }
  }

  pw.Widget _pdfStatBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Future<void> _exportEmail(BuildContext context) async {
    try {
      // Generate CSV and share via email
      final provider = context.read<TaskProvider>();
      final tasks = provider.allTasks;

      final rows = <List<String>>[
        ['Title', 'Due Date', 'Category', 'Priority', 'Status'],
        ...tasks.map((t) => [
              t.title,
              t.dueDate ?? '-',
              t.category ?? '-',
              t.priority == 3
                  ? 'High'
                  : t.priority == 2
                      ? 'Medium'
                      : 'Low',
              t.isCompleted ? 'Done' : 'Pending',
            ]),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/taskflow_export.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'TaskFlow - Tasks Export',
        text: 'Please find attached my TaskFlow task export.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email export failed: $e')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h3(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

// ── Permission Status Section ────────────────────────────────────────────────

/// Shows the current status of notification & alarm permissions
/// with a button to fix them if denied.
class _PermissionStatusSection extends StatelessWidget {
  const _PermissionStatusSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<PermissionStatus>>(
      future: Future.wait([
        Permission.notification.status,
        Permission.scheduleExactAlarm.status,
      ]),
      builder: (context, snap) {
        final notifGranted = snap.data?[0].isGranted ?? false;
        final alarmGranted = snap.data?[1].isGranted ?? false;
        final allGranted = notifGranted && alarmGranted;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F8FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: allGranted
                  ? Colors.green.withValues(alpha: 0.4)
                  : Colors.orange.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    allGranted
                        ? Icons.verified_rounded
                        : Icons.warning_amber_rounded,
                    color: allGranted ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allGranted
                        ? 'All permissions granted'
                        : 'Some permissions missing',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: allGranted ? Colors.green : Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _PermRow(
                label: 'Notifications',
                granted: notifGranted,
                loading: snap.connectionState == ConnectionState.waiting,
              ),
              const SizedBox(height: 6),
              _PermRow(
                label: 'Alarms & Reminders',
                granted: alarmGranted,
                loading: snap.connectionState == ConnectionState.waiting,
              ),
              if (!allGranted && snap.connectionState == ConnectionState.done) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings_rounded, size: 18),
                    label: const Text('Open App Settings to Fix'),
                    onPressed: () => openAppSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PermRow extends StatelessWidget {
  final String label;
  final bool granted;
  final bool loading;

  const _PermRow({
    required this.label,
    required this.granted,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          loading
              ? Icons.hourglass_empty_rounded
              : granted
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
          size: 18,
          color: loading
              ? Colors.grey
              : granted
                  ? Colors.green
                  : Colors.red.shade400,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
        const Spacer(),
        Text(
          loading ? '...' : (granted ? 'Granted' : 'Denied'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: loading
                ? Colors.grey
                : granted
                    ? Colors.green
                    : Colors.red.shade400,
          ),
        ),
      ],
    );
  }
}
