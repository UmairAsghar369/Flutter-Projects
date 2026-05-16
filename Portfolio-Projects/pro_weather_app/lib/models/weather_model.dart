class WeatherModel {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double visibility;
  final double uvIndex;
  final List<double> hourlyTemperatures;
  final List<int> hourlyPrecipitationProbability;
  final List<String> hourlyTimes;
  final String timezone;

  WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.hourlyTemperatures,
    required this.hourlyPrecipitationProbability,
    required this.hourlyTimes,
    required this.timezone,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;

    final allHourlyTemps = (hourly['temperature_2m'] as List)
        .map<double>((e) => (e as num).toDouble())
        .toList();
    final allHourlyPrecip = (hourly['precipitation_probability'] as List)
        .map<int>((e) => (e as num?)?.toInt() ?? 0)
        .toList();
    final allHourlyTimes =
        (hourly['time'] as List).map<String>((e) => e.toString()).toList();

    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      weatherCode: (current['weather_code'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).toInt(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      visibility: (current['visibility'] as num).toDouble(),
      uvIndex: (current['uv_index'] as num?)?.toDouble() ?? 0.0,
      hourlyTemperatures: allHourlyTemps,
      hourlyPrecipitationProbability: allHourlyPrecip,
      hourlyTimes: allHourlyTimes,
      timezone: json['timezone']?.toString() ?? 'auto',
    );
  }

  String get conditionLabel {
    return conditions[weatherCode]?['label'] ?? 'Unknown';
  }

  String get conditionEmoji {
    return conditions[weatherCode]?['emoji'] ?? '🌡️';
  }

  String get uvLabel {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  String get windDirectionLabel {
    const dirs = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((windDirection % 360) / 22.5).round() % 16;
    return dirs[index];
  }

  static const Map<int, Map<String, String>> conditions = {
    0: {'label': 'Clear Sky', 'emoji': '☀️'},
    1: {'label': 'Mainly Clear', 'emoji': '🌤️'},
    2: {'label': 'Partly Cloudy', 'emoji': '⛅'},
    3: {'label': 'Overcast', 'emoji': '☁️'},
    45: {'label': 'Foggy', 'emoji': '🌫️'},
    48: {'label': 'Icy Fog', 'emoji': '🌫️'},
    51: {'label': 'Light Drizzle', 'emoji': '🌦️'},
    53: {'label': 'Drizzle', 'emoji': '🌦️'},
    55: {'label': 'Heavy Drizzle', 'emoji': '🌦️'},
    56: {'label': 'Freezing Drizzle', 'emoji': '🌧️'},
    57: {'label': 'Heavy Freezing Drizzle', 'emoji': '🌧️'},
    61: {'label': 'Light Rain', 'emoji': '🌧️'},
    63: {'label': 'Moderate Rain', 'emoji': '🌧️'},
    65: {'label': 'Heavy Rain', 'emoji': '🌧️'},
    66: {'label': 'Freezing Rain', 'emoji': '🌧️'},
    67: {'label': 'Heavy Freezing Rain', 'emoji': '🌧️'},
    71: {'label': 'Light Snow', 'emoji': '🌨️'},
    73: {'label': 'Moderate Snow', 'emoji': '❄️'},
    75: {'label': 'Heavy Snow', 'emoji': '❄️'},
    77: {'label': 'Snow Grains', 'emoji': '❄️'},
    80: {'label': 'Rain Showers', 'emoji': '🌦️'},
    81: {'label': 'Moderate Showers', 'emoji': '🌦️'},
    82: {'label': 'Heavy Showers', 'emoji': '🌧️'},
    85: {'label': 'Snow Showers', 'emoji': '🌨️'},
    86: {'label': 'Heavy Snow Showers', 'emoji': '🌨️'},
    95: {'label': 'Thunderstorm', 'emoji': '⛈️'},
    96: {'label': 'Thunderstorm + Hail', 'emoji': '⛈️'},
    99: {'label': 'Heavy Thunderstorm', 'emoji': '⛈️'},
  };
}
