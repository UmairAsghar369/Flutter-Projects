import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BMIGauge extends StatefulWidget {
  final double bmi;
  final double size;

  const BMIGauge({
    super.key,
    required this.bmi,
    this.size = 260,
  });

  @override
  State<BMIGauge> createState() => _BMIGaugeState();
}

class _BMIGaugeState extends State<BMIGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bmiAnimation;
  double _previousBMI = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bmiAnimation = Tween<double>(begin: 0, end: widget.bmi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(BMIGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      _previousBMI = oldWidget.bmi;
      _bmiAnimation = Tween<double>(
        begin: _previousBMI,
        end: widget.bmi,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bmiAnimation,
      builder: (context, child) {
        final currentBMI = _bmiAnimation.value;
        final category = BMICategory.fromBMI(currentBMI.clamp(10, 50));
        return SizedBox(
          width: widget.size,
          height: widget.size * 0.7,
          child: CustomPaint(
            painter: _GaugePainter(
              bmi: currentBMI,
              categoryColor: category.color,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentBMI.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: category.color,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: category.color.withValues(alpha: 0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BMI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double bmi;
  final Color categoryColor;

  _GaugePainter({required this.bmi, required this.categoryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.42;
    const startAngle = pi;
    const sweepAngle = pi;
    const strokeWidth = 14.0;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Colored segments
    final segments = [
      (AppColors.underweight, 0.0, 0.37),   // 0-18.5 of 50
      (AppColors.normal, 0.37, 0.13),        // 18.5-25
      (AppColors.overweight, 0.50, 0.10),    // 25-30
      (AppColors.obese, 0.60, 0.40),         // 30-50
    ];

    for (final segment in segments) {
      final segPaint = Paint()
        ..color = segment.$1.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + sweepAngle * segment.$2,
        sweepAngle * segment.$3,
        false,
        segPaint,
      );
    }

    // Active arc
    final clampedBMI = bmi.clamp(10.0, 50.0);
    final progress = (clampedBMI - 10) / 40;
    final activeSweep = sweepAngle * progress;

    final activeGradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        AppColors.underweight,
        AppColors.normal,
        AppColors.overweight,
        AppColors.obese,
      ],
      stops: const [0.0, 0.37, 0.55, 0.8],
    );

    final activePaint = Paint()
      ..shader = activeGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activePaint,
    );

    // Needle indicator
    final needleAngle = startAngle + activeSweep;
    final needleX = center.dx + radius * cos(needleAngle);
    final needleY = center.dy + radius * sin(needleAngle);

    // Outer glow
    final glowPaint = Paint()
      ..color = categoryColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(needleX, needleY), 10, glowPaint);

    // White dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(needleX, needleY), 7, dotPaint);

    // Inner colored dot
    final innerPaint = Paint()..color = categoryColor;
    canvas.drawCircle(Offset(needleX, needleY), 4, innerPaint);

    // Scale labels
    final labels = ['10', '18.5', '25', '30', '50'];
    final labelPositions = [0.0, 0.2125, 0.375, 0.5, 1.0];

    for (int i = 0; i < labels.length; i++) {
      final angle = startAngle + sweepAngle * labelPositions[i];
      final labelRadius = radius + 22;
      final lx = center.dx + labelRadius * cos(angle);
      final ly = center.dy + labelRadius * sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.bmi != bmi || oldDelegate.categoryColor != categoryColor;
}
