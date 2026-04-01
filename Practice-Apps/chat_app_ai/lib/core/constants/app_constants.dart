// lib/core/constants/app_constants.dart

/// App-wide constants for AuraAI
class AppConstants {
  AppConstants._();

  static const String appName = 'AuraAI';
  static const String geminiModel = 'gemini-1.5-flash';
  static const String geminiApiKey = 'AIzaSyCUhaeOS0QP3Jh0u7hq_OeXinm-iDFYMSc';

  /// Starter prompts shown on the empty state screen
  static const List<String> starterPrompts = [
    '✨ Write a short poem about the cosmos',
    '💡 Explain quantum computing simply',
    '🚀 Give me 5 startup ideas for 2025',
    '🖥️ Write a Python bubble sort',
    '📖 Summarize the Roman Empire',
    '🎨 Suggest a color palette for a calm app',
  ];

  static const int streamTimeoutSeconds = 30;
}
