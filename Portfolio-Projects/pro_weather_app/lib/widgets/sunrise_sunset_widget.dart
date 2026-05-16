import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class SunriseSunsetWidget extends StatelessWidget {
  final Color accentColor;

  const SunriseSunsetWidget({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final forecast = provider.forecast;
        final today = forecast?.today;
        if (today == null) return const SizedBox.shrink();

        final sunrise = DateTime.tryParse(today.sunrise);
        final sunset = DateTime.tryParse(today.sunset);
        if (sunrise == null || sunset == null) return const SizedBox.shrink();

        final now = DateTime.now();
        final totalMinutes = sunset.difference(sunrise).inMinutes;
        final elapsedMinutes = now.difference(sunrise).inMinutes;
        final progress = totalMinutes > 0
            ? (elapsedMinutes / totalMinutes).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassCard(),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_twilight, color: accentColor, size: 18),
                    const SizedBox(width: 8),
                    Text('SUNRISE & SUNSET', style: AppTheme.label()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: CustomPaint(
                    size: const Size(double.infinity, 100),
                    painter: _SunArcPainter(
                      progress: progress,
                      accentColor: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text('🌅', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(sunrise),
                          style: AppTheme.dataNumber(),
                        ),
                        Text('SUNRISE', style: AppTheme.label()),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          _daylight(totalMinutes),
                          style: AppTheme.subtitle(color: accentColor),
                        ),
                        Text('DAYLIGHT', style: AppTheme.label()),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('🌇', style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(sunset),
                          style: AppTheme.dataNumber(),
                        ),
                        Text('SUNSET', style: AppTheme.label()),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _daylight(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return '${hours}h ${mins}m';
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _SunArcPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.42;

    // Arc path (semicircle)
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );

    // Traveled path
    if (progress > 0) {
      final traveledPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi * progress,
        false,
        traveledPaint,
      );
    }

    // Sun dot
    final angle = math.pi + (math.pi * progress);
    final sunX = center.dx + radius * math.cos(angle);
    final sunY = center.dy + radius * math.sin(angle);

    // Glow
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(sunX, sunY), 10, glowPaint);

    // Sun circle
    final sunPaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(Offset(sunX, sunY), 6, sunPaint);

    // Horizon line
    final horizonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      horizonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
