import 'weather_model.dart';

class ForecastDay {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String sunrise;
  final String sunset;
  final int precipitationProbability;

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.precipitationProbability,
  });

  String get conditionLabel {
    return WeatherModel.conditions[weatherCode]?['label'] ?? 'Unknown';
  }

  String get conditionEmoji {
    return WeatherModel.conditions[weatherCode]?['emoji'] ?? '🌡️';
  }
}

class ForecastModel {
  final List<ForecastDay> days;

  ForecastModel({required this.days});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;
    final times = daily['time'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final minTemps = daily['temperature_2m_min'] as List;
    final codes = daily['weather_code'] as List;
    final sunrises = daily['sunrise'] as List;
    final sunsets = daily['sunset'] as List;
    final precip = daily['precipitation_probability_max'] as List;

    final List<ForecastDay> daysList = [];
    for (int i = 0; i < times.length; i++) {
      daysList.add(ForecastDay(
        date: DateTime.parse(times[i].toString()),
        maxTemp: (maxTemps[i] as num).toDouble(),
        minTemp: (minTemps[i] as num).toDouble(),
        weatherCode: (codes[i] as num).toInt(),
        sunrise: sunrises[i].toString(),
        sunset: sunsets[i].toString(),
        precipitationProbability: (precip[i] as num?)?.toInt() ?? 0,
      ));
    }

    return ForecastModel(days: daysList);
  }

  ForecastDay? get today => days.isNotEmpty ? days.first : null;
}
