import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// An animated checkbox that draws a green checkmark when checked.
///
/// Uses [CustomPainter] with an [AnimationController] to animate
/// the checkmark path drawing over 300 ms.
class AnimatedCheckbox extends StatefulWidget {
  /// Whether the checkbox is currently checked.
  final bool value;

  /// Called when the checkbox is tapped.
  final VoidCallback? onChanged;

  /// Size of the checkbox. Defaults to 26.
  final double size;

  /// Creates an [AnimatedCheckbox].
  const AnimatedCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 26,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onChanged,
      child: AnimatedBuilder2(
        listenable: _animation,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.value
                  ? AppColors.accentGreen.withValues(alpha: _animation.value)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.value
                    ? AppColors.accentGreen
                    : isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                width: 2,
              ),
            ),
            child: CustomPaint(
              painter: _CheckPainter(progress: _animation.value),
            ),
          );
        },
      ),
    );
  }
}

/// Animated builder helper that rebuilds on animation ticks.
class AnimatedBuilder2 extends AnimatedWidget {
  /// Builder callback.
  final Widget Function(BuildContext, Widget?) builder;

  /// Creates an [AnimatedBuilder2].
  const AnimatedBuilder2({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Checkmark path: starts from left, goes down-center, then up-right
    final startX = size.width * 0.2;
    final startY = size.height * 0.5;
    final midX = size.width * 0.42;
    final midY = size.height * 0.72;
    final endX = size.width * 0.8;
    final endY = size.height * 0.28;

    path.moveTo(startX, startY);

    if (progress <= 0.5) {
      // Draw first segment
      final t = progress * 2;
      path.lineTo(
        startX + (midX - startX) * t,
        startY + (midY - startY) * t,
      );
    } else {
      // Full first segment + partial second
      path.lineTo(midX, midY);
      final t = (progress - 0.5) * 2;
      path.lineTo(
        midX + (endX - midX) * t,
        midY + (endY - midY) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
