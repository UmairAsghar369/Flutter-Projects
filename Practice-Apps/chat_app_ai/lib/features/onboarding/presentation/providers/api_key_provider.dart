// lib/features/onboarding/presentation/providers/api_key_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the Gemini API key in memory only (lost on restart by design)
class ApiKeyNotifier extends StateNotifier<String?> {
  ApiKeyNotifier() : super(null);

  void setKey(String key) => state = key.trim();
  void clearKey() => state = null;
}

final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String?>(
  (ref) => ApiKeyNotifier(),
);

/// Convenience provider — true once key is set
final hasApiKeyProvider = Provider<bool>(
  (ref) => ref.watch(apiKeyProvider) != null,
);
