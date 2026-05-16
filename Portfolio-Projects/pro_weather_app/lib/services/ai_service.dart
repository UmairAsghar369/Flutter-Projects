import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const Duration _timeout = Duration(seconds: 15);

  /// Get a single AI weather tip from Claude
  Future<String?> getWeatherTip({
    required String apiKey,
    required String city,
    required double temperature,
    required String condition,
    required int humidity,
    required double windSpeed,
  }) async {
    if (apiKey.trim().isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': apiKey.trim(),
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': 'claude-haiku-3-5-20241022',
              'max_tokens': 120,
              'messages': [
                {
                  'role': 'user',
                  'content':
                      'Weather in $city: ${temperature.round()}°C, $condition, '
                          'humidity $humidity%, wind ${windSpeed.round()} km/h. '
                          'Give ONE practical, friendly tip for today. '
                          'Max 25 words. No emojis.',
                }
              ],
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['content'] as List<dynamic>;
        if (content.isNotEmpty) {
          return (content[0] as Map<String, dynamic>)['text'] as String?;
        }
      }
      return null;
    } catch (_) {
      // AI tip is non-critical — fail silently
      return null;
    }
  }
}
