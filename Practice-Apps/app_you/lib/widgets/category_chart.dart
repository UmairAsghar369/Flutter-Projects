import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';

class CategoryChart extends StatefulWidget {
  final bool isDark;
  final ExpenseProvider provider;
  final NumberFormat formatter;

  const CategoryChart({
    super.key,
    required this.isDark,
    required this.provider,
    required this.formatter,
  });

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totals = widget.provider.categoryTotals;
    final total = totals.values.fold(0.0, (a, b) => a + b);

    if (totals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 64,
              color: AppTheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No data to display',
              style: TextStyle(
                color: widget.isDark ? AppTheme.textGrey : Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add some expenses first',
              style: TextStyle(
                color: widget.isDark
                    ? AppTheme.textGrey.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final keys = totals.keys.toList();
    final sections = keys.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = (totals[cat]! / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        value: totals[cat],
        color: cat.color,
        radius: isTouched ? 100 : 82,
        title: isTouched ? '$percentage%' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 52,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedIndex = -1;
                      } else {
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_touchedIndex >= 0 && _touchedIndex < keys.length)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: keys[_touchedIndex].color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${keys[_touchedIndex].name}: ${widget.formatter.format(totals[keys[_touchedIndex]])}',
                  style: TextStyle(
                    color: keys[_touchedIndex].color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          ...totals.entries.map((entry) {
            final percent = entry.value / total;
            return _buildCategoryRow(entry.key, entry.value, percent);
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(ExpenseCategory cat, double amount, double percent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: cat.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                widget.formatter.format(amount),
                style: TextStyle(
                  color: cat.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: widget.isDark ? AppTheme.textGrey : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: percent),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: cat.color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                  minHeight: 6,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
