import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class StatsGridWidget extends StatelessWidget {
  final Color accentColor;

  const StatsGridWidget({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        if (weather == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.water_drop_outlined,
                      iconColor: const Color(0xFF60A5FA),
                      value: '${weather.humidity}%',
                      label: 'HUMIDITY',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _WindStatCard(
                      windSpeed: weather.windSpeed,
                      windDirection: weather.windDirection,
                      directionLabel: weather.windDirectionLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.speed_outlined,
                      iconColor: const Color(0xFFFBBF24),
                      value: '${weather.pressure.round()} hPa',
                      label: 'PRESSURE',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.visibility_outlined,
                      iconColor: const Color(0xFF34D399),
                      value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                      label: 'VISIBILITY',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(value, style: AppTheme.dataNumber()),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.label()),
        ],
      ),
    );
  }
}

class _WindStatCard extends StatelessWidget {
  final double windSpeed;
  final int windDirection;
  final String directionLabel;

  const _WindStatCard({
    required this.windSpeed,
    required this.windDirection,
    required this.directionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, color: Color(0xFF93C5FD), size: 24),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: windDirection / 360,
                duration: const Duration(milliseconds: 600),
                child: Icon(
                  Icons.navigation,
                  color: const Color(0xFF93C5FD).withValues(alpha: 0.7),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${windSpeed.round()} km/h', style: AppTheme.dataNumber()),
          const SizedBox(height: 4),
          Text('WIND $directionLabel', style: AppTheme.label()),
        ],
      ),
    );
  }
}

class UvIndexCard extends StatelessWidget {
  final Color accentColor;

  const UvIndexCard({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.weather;
        if (weather == null) return const SizedBox.shrink();

        final uv = weather.uvIndex;
        final progress = (uv / 11).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_outlined,
                        color: Color(0xFFFBBF24), size: 22),
                    const SizedBox(width: 8),
                    Text('UV INDEX', style: AppTheme.label()),
                    const Spacer(),
                    Text(
                      weather.uvLabel,
                      style: AppTheme.subtitle(color: _uvColor(uv)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, _) {
                    return Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF22C55E),
                                Color(0xFFFBBF24),
                                Color(0xFFF97316),
                                Color(0xFFEF4444),
                                Color(0xFF9333EA),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: (MediaQuery.of(context).size.width - 80) *
                              value.clamp(0.0, 0.95),
                          top: -3,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _uvColor(uv).withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  uv.toStringAsFixed(1),
                  style: AppTheme.dataNumber(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _uvColor(double uv) {
    if (uv <= 2) return const Color(0xFF22C55E);
    if (uv <= 5) return const Color(0xFFFBBF24);
    if (uv <= 7) return const Color(0xFFF97316);
    if (uv <= 10) return const Color(0xFFEF4444);
    return const Color(0xFF9333EA);
  }
}
