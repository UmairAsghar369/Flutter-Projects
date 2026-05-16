import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/geocoding_service.dart';
import '../services/ai_service.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final GeocodingService _geocodingService = GeocodingService();
  final AiService _aiService = AiService();

  WeatherModel? _weather;
  ForecastModel? _forecast;
  WeatherStatus _status = WeatherStatus.initial;
  String _errorMessage = '';
  String _cityName = '';
  String _country = '';
  bool _isCelsius = true;
  String _aiTip = '';
  String _apiKey = '';
  DateTime? _lastUpdated;
  double _currentLat = 0;
  double _currentLon = 0;

  // ── Getters ──
  WeatherModel? get weather => _weather;
  ForecastModel? get forecast => _forecast;
  WeatherStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get cityName => _cityName;
  String get country => _country;
  bool get isCelsius => _isCelsius;
  String get aiTip => _aiTip;
  String get apiKey => _apiKey;
  DateTime? get lastUpdated => _lastUpdated;

  /// Convert temperature for display
  double toDisplay(double celsius) {
    return _isCelsius ? celsius : (celsius * 9 / 5) + 32;
  }

  /// Format temperature string
  String formatTemp(double celsius) {
    final value = toDisplay(celsius);
    return '${value.round()}°';
  }

  /// Unit label
  String get unitLabel => _isCelsius ? '°C' : '°F';

  /// Toggle Celsius / Fahrenheit
  void toggleUnit() {
    _isCelsius = !_isCelsius;
    notifyListeners();
  }

  /// Set API key
  void setApiKey(String key) {
    _apiKey = key;
    notifyListeners();
  }

  /// Load weather for default city (Islamabad) — called on startup
  Future<void> loadDefault() async {
    debugPrint('Aurora: Loading default city (Islamabad)...');
    await fetchWeatherByCoords(33.6844, 73.0479, 'Islamabad', 'Pakistan');
  }

  /// Fetch weather for specific coordinates — core method
  Future<void> fetchWeatherByCoords(
    double lat,
    double lon,
    String city,
    String country,
  ) async {
    _status = WeatherStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      debugPrint('Aurora: Fetching weather for $city ($lat, $lon)...');
      final result = await _weatherService.fetchWeather(lat, lon);
      _weather = result['weather'] as WeatherModel;
      _forecast = result['forecast'] as ForecastModel;
      _cityName = city;
      _country = country;
      _currentLat = lat;
      _currentLon = lon;
      _lastUpdated = DateTime.now();
      _status = WeatherStatus.loaded;
      debugPrint('Aurora: ✅ Weather loaded for $city');
      notifyListeners();

      // Fire AI tip in background (non-blocking)
      _fetchAiTip();
    } catch (e) {
      debugPrint('Aurora: ❌ Error loading weather: $e');
      _status = WeatherStatus.error;
      _errorMessage = _friendlyError(e.toString());
      notifyListeners();
    }
  }

  /// Refresh current location data
  Future<void> refresh() async {
    if (_currentLat != 0 && _currentLon != 0) {
      await fetchWeatherByCoords(
          _currentLat, _currentLon, _cityName, _country);
    } else {
      await loadDefault();
    }
  }

  /// Use GPS — only when user explicitly taps the GPS button
  Future<void> useGps() async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      // Wrap the ENTIRE GPS flow in a 12-second master timeout
      // This prevents the app from ever hanging on emulator
      await _doGpsLookup().timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw TimeoutException('GPS timed out');
        },
      );
    } catch (e) {
      debugPrint('Aurora: GPS failed ($e), showing error');
      _status = WeatherStatus.error;
      _errorMessage = 'GPS unavailable. Use search to find your city.';
      notifyListeners();
    }
  }

  /// Internal GPS lookup logic
  Future<void> _doGpsLookup() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    final position = await Geolocator.getCurrentPosition();

    String city = 'Current Location';
    String ctry = '';
    try {
      final geo = await _geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      city = geo.city;
      ctry = geo.country;
    } catch (_) {
      // Reverse geocode failed — use generic name
    }

    await fetchWeatherByCoords(
      position.latitude,
      position.longitude,
      city,
      ctry,
    );
  }

  /// Convert raw error to user-friendly message
  String _friendlyError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('handshake')) {
      return 'No internet connection.\nCheck your network and tap Retry.';
    }
    if (lower.contains('timeout')) {
      return 'Connection timed out.\nCheck your network and tap Retry.';
    }
    return error.replaceFirst('Exception: ', '');
  }

  /// Fetch AI weather tip in background
  Future<void> _fetchAiTip() async {
    if (_apiKey.isEmpty || _weather == null) {
      _aiTip = '';
      notifyListeners();
      return;
    }

    final tip = await _aiService.getWeatherTip(
      apiKey: _apiKey,
      city: _cityName,
      temperature: _weather!.temperature,
      condition: _weather!.conditionLabel,
      humidity: _weather!.humidity,
      windSpeed: _weather!.windSpeed,
    );

    _aiTip = tip ?? '';
    notifyListeners();
  }
}
