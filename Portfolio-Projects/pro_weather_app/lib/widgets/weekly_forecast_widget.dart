import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class WeeklyForecastWidget extends StatelessWidget {
  final Color accentColor;

  const WeeklyForecastWidget({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final forecast = provider.forecast;
        if (forecast == null || forecast.days.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Text('7-DAY FORECAST', style: AppTheme.label()),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast.days.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final day = forecast.days[index];
                    final isToday = index == 0;
                    final dayName = isToday
                        ? 'Today'
                        : DateFormat('EEE').format(day.date);

                    return Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 10),
                      decoration: isToday
                          ? AppTheme.glassCardWithGlow(glowColor: accentColor)
                          : AppTheme.glassCard(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dayName,
                            style: AppTheme.label(
                              color: isToday
                                  ? accentColor
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            day.conditionEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          Column(
                            children: [
                              Text(
                                provider.formatTemp(day.maxTemp),
                                style: AppTheme.dataNumber(),
                              ),
                              Text(
                                provider.formatTemp(day.minTemp),
                                style: AppTheme.subtitle(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
