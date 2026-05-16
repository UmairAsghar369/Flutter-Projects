import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.18),
      period: const Duration(milliseconds: 1500),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // City name placeholder
            _skeletonBox(width: 160, height: 22, radius: 11),
            const SizedBox(height: 30),
            // Temperature placeholder
            _skeletonBox(width: 180, height: 80, radius: 20),
            const SizedBox(height: 14),
            // Condition placeholder
            _skeletonBox(width: 140, height: 16, radius: 8),
            const SizedBox(height: 8),
            _skeletonBox(width: 200, height: 14, radius: 7),
            const SizedBox(height: 40),
            // Stats grid
            Row(
              children: [
                Expanded(child: _skeletonCard(height: 110)),
                const SizedBox(width: 12),
                Expanded(child: _skeletonCard(height: 110)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _skeletonCard(height: 110)),
                const SizedBox(width: 12),
                Expanded(child: _skeletonCard(height: 110)),
              ],
            ),
            const SizedBox(height: 24),
            // UV card
            _skeletonCard(height: 80),
            const SizedBox(height: 24),
            // Chart card
            _skeletonCard(height: 220),
            const SizedBox(height: 24),
            // Sunrise card
            _skeletonCard(height: 160),
            const SizedBox(height: 24),
            // Forecast
            _skeletonCard(height: 140),
          ],
        ),
      ),
    );
  }

  static Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget _skeletonCard({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
    );
  }
}
