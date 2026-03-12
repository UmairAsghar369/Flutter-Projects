import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grade_scale_provider.dart';
import '../models/grade_scale.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class GradeScaleScreen extends StatelessWidget {
  const GradeScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Grade Scales')),
      body: Consumer<GradeScaleProvider>(
        builder: (context, prov, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...prov.scales.map((scale) {
                final isActive = scale.id == prov.activeScaleId;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isActive
                        ? const BorderSide(color: AppColors.primaryStart, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () => prov.setActiveScale(scale.id),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(isActive ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isActive ? AppColors.primaryStart : Colors.grey),
                            const SizedBox(width: 12),
                            Text(scale.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            if (scale.id != 'default')
                              IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20), onPressed: () => prov.deleteScale(scale.id)),
                          ]),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6, runSpacing: 4,
                            children: scale.gradeMap.entries.map((e) => Chip(
                              label: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              GradientButton(
                text: 'Create Custom Scale',
                icon: Icons.add_rounded,
                onPressed: () => _showCreateDialog(context, prov),
                gradient: AppColors.accentGradient,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, GradeScaleProvider prov) async {
    final nameCtrl = TextEditingController();
    final gradeMap = Map<String, double>.from(GradeScale.defaultScale.gradeMap);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Custom Grade Scale'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Scale Name', hintText: 'e.g. 5.0 Scale')),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView(
                  children: gradeMap.entries.map((e) => ListTile(
                    dense: true, title: Text(e.key),
                    trailing: SizedBox(width: 60, child: TextFormField(
                      initialValue: e.value.toString(), keyboardType: TextInputType.number,
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 14),
                      onChanged: (val) { final p = double.tryParse(val); if (p != null) setState(() => gradeMap[e.key] = p); },
                    )),
                  )).toList(),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(onPressed: () { if (nameCtrl.text.trim().isNotEmpty) Navigator.pop(ctx, {'name': nameCtrl.text.trim(), 'gradeMap': gradeMap}); }, child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result != null) await prov.addScale(result['name'], Map<String, double>.from(result['gradeMap']));
  }
}
