import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetch current weather + hourly + daily forecast for given coordinates
  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,'
      'apparent_temperature,weather_code,wind_speed_10m,'
      'wind_direction_10m,surface_pressure,visibility,uv_index'
      '&hourly=temperature_2m,precipitation_probability'
      '&daily=temperature_2m_max,temperature_2m_min,'
      'weather_code,sunrise,sunset,precipitation_probability_max'
      '&timezone=auto'
      '&forecast_days=7',
    );

    try {
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final weather = WeatherModel.fromJson(json);
        final forecast = ForecastModel.fromJson(json);
        return {
          'weather': weather,
          'forecast': forecast,
        };
      } else {
        throw Exception(
            'Weather API returned status ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('ClientException')) {
        throw Exception(
            'No internet connection. Please check your network and try again.');
      }
      rethrow;
    }
  }
}
