import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class HourlyChartWidget extends StatelessWidget {
  final Color accentColor;

  const HourlyChartWidget({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        if (weather == null) return const SizedBox.shrink();

        // Get next 24 hours of data starting from current hour
        final now = DateTime.now();
        int startIndex = 0;

        // Find the hour closest to now
        for (int i = 0; i < weather.hourlyTimes.length; i++) {
          final t = DateTime.tryParse(weather.hourlyTimes[i]);
          if (t != null && t.isAfter(now.subtract(const Duration(hours: 1)))) {
            startIndex = i;
            break;
          }
        }

        final endIndex = (startIndex + 24).clamp(0, weather.hourlyTemperatures.length);
        if (startIndex >= endIndex) return const SizedBox.shrink();

        final temps = weather.hourlyTemperatures.sublist(startIndex, endIndex);
        final times = weather.hourlyTimes.sublist(startIndex, endIndex);

        final displayTemps = temps.map((t) => provider.toDisplay(t)).toList();
        final minTemp = displayTemps.reduce((a, b) => a < b ? a : b);
        final maxTemp = displayTemps.reduce((a, b) => a > b ? a : b);
        final range = maxTemp - minTemp;

        final spots = <FlSpot>[];
        for (int i = 0; i < displayTemps.length; i++) {
          spots.add(FlSpot(i.toDouble(), displayTemps[i]));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            decoration: AppTheme.glassCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time,
                        color: accentColor, size: 18),
                    const SizedBox(width: 8),
                    Text('24-HOUR FORECAST', style: AppTheme.label()),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: range > 0 ? range / 4 : 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withValues(alpha: 0.06),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 4,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= times.length) {
                                return const SizedBox.shrink();
                              }
                              final t = DateTime.tryParse(times[idx]);
                              if (t == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('ha').format(t).toLowerCase(),
                                  style: AppTheme.label(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: minTemp - (range * 0.15).clamp(1, 5),
                      maxY: maxTemp + (range * 0.15).clamp(1, 5),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) =>
                              const Color(0xFF1E293B),
                          tooltipRoundedRadius: 12,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final idx = spot.x.toInt();
                              final t = idx < times.length
                                  ? DateTime.tryParse(times[idx])
                                  : null;
                              final timeStr = t != null
                                  ? DateFormat('h:mm a').format(t)
                                  : '';
                              return LineTooltipItem(
                                '${spot.y.round()}${provider.unitLabel}\n$timeStr',
                                AppTheme.subtitle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: accentColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accentColor.withValues(alpha: 0.30),
                                accentColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
