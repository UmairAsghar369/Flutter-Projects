import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/semester_provider.dart';
import '../providers/grade_scale_provider.dart';
import '../theme/app_colors.dart';
import 'grade_scale_screen.dart';

/// Settings screen with theme toggle, grade scale, export options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final gradeScaleProv = context.watch<GradeScaleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ─────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProv.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeProv.isDarkMode ? 'Dark theme active' : 'Light theme active',
              ),
              value: themeProv.isDarkMode,
              onChanged: (_) => themeProv.toggleTheme(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Grade Scale ────────────────────────────────
          _SectionHeader(title: 'Grade Scale'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Active Grade Scale'),
              subtitle: Text(gradeScaleProv.activeScale.name),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GradeScaleScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Export ─────────────────────────────────────
          _SectionHeader(title: 'Export Results'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: const Text('Export as PDF'),
                  subtitle: const Text('Generate a PDF report of your results'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _exportPdf(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.image_rounded),
                  title: const Text('Export as Image'),
                  subtitle: const Text('Save a screenshot of your results'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _exportImage(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── About ──────────────────────────────────────
          _SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('CGPA Calculator'),
                  subtitle: const Text('Version 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: const Text('Built with Flutter'),
                  subtitle: const Text('Made with ❤️'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final profileProv = context.read<ProfileProvider>();
    final semesterProv = context.read<SemesterProvider>();
    final profile = profileProv.activeProfile;

    if (profile == null || semesterProv.semesters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '${profile.name} — CGPA Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Paragraph(
            text: 'Overall CGPA: ${semesterProv.cgpa.toStringAsFixed(2)} / 4.00',
          ),
          pw.Paragraph(
            text:
                'Total Credits: ${semesterProv.totalCredits} | Semesters: ${semesterProv.semesters.length}',
          ),
          pw.SizedBox(height: 16),
          ...semesterProv.semesters.map((sem) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    '${sem.name} (GPA: ${sem.gpa.toStringAsFixed(2)})',
                  ),
                ),
                if (sem.subjects.isEmpty)
                  pw.Paragraph(text: 'No subjects added')
                else
                  pw.TableHelper.fromTextArray(
                    headers: ['Subject', 'Credits', 'Grade', 'Points'],
                    data: sem.subjects
                        .map((s) => [
                              s.name,
                              s.creditHours.toString(),
                              s.grade,
                              s.gradePoints.toStringAsFixed(2),
                            ])
                        .toList(),
                  ),
                pw.SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: '${profile.name}_CGPA_Report',
    );
  }

  Future<void> _exportImage(BuildContext context) async {
    final profileProv = context.read<ProfileProvider>();
    final semesterProv = context.read<SemesterProvider>();
    final profile = profileProv.activeProfile;

    if (profile == null || semesterProv.semesters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    final controller = ScreenshotController();

    // Build an offscreen widget for screenshot
    final widget = MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${profile.name} — CGPA Report',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'CGPA: ${semesterProv.cgpa.toStringAsFixed(2)} / 4.00',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Total Credits: ${semesterProv.totalCredits}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Divider(height: 24),
              ...semesterProv.semesters.map((sem) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sem.name} — GPA: ${sem.gpa.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      ...sem.subjects.map((s) => Text(
                            '  ${s.name}: ${s.grade} (${s.creditHours} cr)',
                          )),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    try {
      final Uint8List imageBytes = await controller.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 100),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/cgpa_report.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My CGPA Report — ${profile.name}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primaryStart,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
    );
  }
}
