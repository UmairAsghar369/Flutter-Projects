import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/semester.dart';
import '../theme/app_colors.dart';

/// Full-screen chart screen with line chart and bar chart.
class ChartScreen extends StatelessWidget {
  final List<Semester> semesters;

  const ChartScreen({super.key, required this.semesters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('GPA Analytics')),
      body: semesters.isEmpty
          ? const Center(child: Text('No data to show'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Line Chart
                Text('GPA Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 220,
                      child: _buildLineChart(isDark),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Bar Chart
                Text('Semester Comparison', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 220,
                      child: _buildBarChart(isDark),
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Stats
                Text('Statistics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildStatsCards(theme),
              ],
            ),
    );
  }

  Widget _buildLineChart(bool isDark) {
    final spots = <FlSpot>[];
    for (int i = 0; i < semesters.length; i++) {
      spots.add(FlSpot(i.toDouble(), semesters[i].gpa));
    }

    return LineChart(LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1,
        getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white10 : Colors.grey.shade200, strokeWidth: 1)),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 32,
          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1,
          getTitlesWidget: (v, _) { final i = v.toInt(); return i >= 0 && i < semesters.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text('S${i + 1}', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11))) : const SizedBox.shrink(); })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minY: 0, maxY: 4.2,
      lineBarsData: [LineChartBarData(
        spots: spots, isCurved: true, color: AppColors.primaryStart, barWidth: 3, isStrokeCapRound: true,
        dotData: FlDotData(show: true, getDotPainter: (spot, percent, data, index) => FlDotCirclePainter(radius: 5, color: AppColors.primaryStart, strokeWidth: 2, strokeColor: Colors.white)),
        belowBarData: BarAreaData(show: true, color: AppColors.primaryStart.withValues(alpha: 0.15)),
      )],
    ));
  }

  Widget _buildBarChart(bool isDark) {
    return BarChart(BarChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1,
        getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white10 : Colors.grey.shade200, strokeWidth: 1)),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 32,
          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1,
          getTitlesWidget: (v, _) { final i = v.toInt(); return i >= 0 && i < semesters.length ? Text('S${i + 1}', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11)) : const SizedBox.shrink(); })),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      maxY: 4.2,
      barGroups: List.generate(semesters.length, (i) {
        final gpa = semesters[i].gpa;
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: gpa, color: AppColors.colorForGpa(gpa), width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
        ]);
      }),
    ));
  }

  Widget _buildStatsCards(ThemeData theme) {
    double highest = 0, lowest = 4.0;
    double sum = 0;
    for (final s in semesters) {
      if (s.gpa > highest) highest = s.gpa;
      if (s.gpa < lowest) lowest = s.gpa;
      sum += s.gpa;
    }
    final avg = semesters.isNotEmpty ? sum / semesters.length : 0.0;

    return Row(children: [
      _StatCard(title: 'Highest', value: highest.toStringAsFixed(2), color: AppColors.gpaExcellent, theme: theme),
      const SizedBox(width: 8),
      _StatCard(title: 'Average', value: avg.toStringAsFixed(2), color: AppColors.primaryStart, theme: theme),
      const SizedBox(width: 8),
      _StatCard(title: 'Lowest', value: lowest.toStringAsFixed(2), color: AppColors.gpaPoor, theme: theme),
    ]).animate(delay: 400.ms).fadeIn(duration: 500.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final ThemeData theme;
  const _StatCard({required this.title, required this.value, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ]),
        ),
      ),
    );
  }
}
