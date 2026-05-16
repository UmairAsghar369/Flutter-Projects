import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';

class AiTipWidget extends StatelessWidget {
  final Color accentColor;

  const AiTipWidget({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        // Show nothing if no API key or no tip
        if (provider.apiKey.isEmpty) {
          return _buildSetupCard(context);
        }

        if (provider.aiTip.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('✨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'AI Weather Insight',
                      style: AppTheme.heading(color: accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  provider.aiTip,
                  style: AppTheme.body(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Powered by Claude',
                    style: AppTheme.label().copyWith(
                      fontSize: 10,
                      color: AppTheme.textSecondary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetupCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassCard(),
        child: Row(
          children: [
            Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Weather Insight',
                    style: AppTheme.subtitle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your Claude API key in settings to get personalized weather tips',
                    style: AppTheme.label(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
