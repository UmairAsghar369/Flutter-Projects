import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class CurrentWeatherCard extends StatefulWidget {
  final Color accentColor;

  const CurrentWeatherCard({super.key, required this.accentColor});

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _tempAnimation;
  double _targetTemp = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTemp(double target) {
    if (target == _targetTemp && _controller.isCompleted) return;
    _targetTemp = target;
    _tempAnimation = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        if (weather == null) return const SizedBox.shrink();

        final displayTemp = provider.toDisplay(weather.temperature);
        _animateTemp(displayTemp);

        final forecast = provider.forecast;
        final today = forecast?.today;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Condition emoji
              Text(
                weather.conditionEmoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 8),

              // Temperature with count-up animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final val = _tempAnimation.value;
                  return Text(
                    '${val.round()}°',
                    style: AppTheme.temperatureDisplay(),
                  );
                },
              ),

              // Condition label
              Text(
                weather.conditionLabel,
                style: AppTheme.heading(color: widget.accentColor),
              ),
              const SizedBox(height: 8),

              // Feels like + High / Low
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Feels like ${provider.formatTemp(weather.apparentTemperature)}',
                    style: AppTheme.subtitle(),
                  ),
                  if (today != null) ...[
                    Text(
                      '  •  ',
                      style: AppTheme.subtitle(),
                    ),
                    Text(
                      'H: ${provider.formatTemp(today.maxTemp)}  L: ${provider.formatTemp(today.minTemp)}',
                      style: AppTheme.subtitle(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),

              // Precipitation probability
              if (today != null && today.precipitationProbability > 0)
                Text(
                  '🌧 ${today.precipitationProbability}% chance of rain',
                  style: AppTheme.subtitle(color: widget.accentColor),
                ),

              const SizedBox(height: 4),

              // Last updated
              if (provider.lastUpdated != null)
                Text(
                  'Updated ${DateFormat('h:mm a').format(provider.lastUpdated!)}',
                  style: AppTheme.label(),
                ),
            ],
          ),
        );
      },
    );
  }
}
