import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A custom bottom navigation bar with an animated sliding indicator.
///
/// The selected tab has a scaled-up icon and a horizontal indicator
/// that slides smoothly between tabs.
class CustomBottomNav extends StatelessWidget {
  /// The currently selected tab index.
  final int currentIndex;

  /// Called when a tab is tapped with the new index.
  final ValueChanged<int> onTap;

  /// Creates a [CustomBottomNav].
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.today_rounded, label: 'Today'),
    _NavItem(icon: Icons.check_circle_outline_rounded, label: 'Completed'),
    _NavItem(icon: Icons.repeat_rounded, label: 'Repeated'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final selectedColor = isDark ? AppColors.accent : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              // ── Sliding indicator ──
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                bottom: 0,
                left: _indicatorLeft(context),
                child: Container(
                  width: MediaQuery.of(context).size.width / _items.length,
                  height: 3,
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // ── Tab items ──
              Row(
                children: List.generate(_items.length, (index) {
                  final isSelected = index == currentIndex;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              _items[index].icon,
                              color:
                                  isSelected ? selectedColor : unselectedColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _items[index].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color:
                                  isSelected ? selectedColor : unselectedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _indicatorLeft(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / _items.length) * currentIndex;
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
