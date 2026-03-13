import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated segmented toggle control for switching between CV views.
class CvToggle extends StatelessWidget {
  final bool isProfessional;
  final ValueChanged<bool> onChanged;

  const CvToggle({
    super.key,
    required this.isProfessional,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildOption(
            label: 'Professional',
            icon: Icons.work_rounded,
            isSelected: isProfessional,
            onTap: () => onChanged(true),
          ),
          _buildOption(
            label: 'Hobby',
            icon: Icons.palette_rounded,
            isSelected: !isProfessional,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  icon,
                  key: ValueKey('$label-$isSelected'),
                  size: 18,
                  color: isSelected
                      ? AppTheme.proPrimary
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.proPrimary
                      : Colors.white.withValues(alpha: 0.85),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
