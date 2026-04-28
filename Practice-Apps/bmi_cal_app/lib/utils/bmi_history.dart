import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BMIRecord {
  final double bmi;
  final String category;
  final String date;
  final double weight;
  final double height;
  final bool isMetric;
  final String gender;

  BMIRecord({
    required this.bmi,
    required this.category,
    required this.date,
    required this.weight,
    required this.height,
    required this.isMetric,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
        'bmi': bmi,
        'category': category,
        'date': date,
        'weight': weight,
        'height': height,
        'isMetric': isMetric,
        'gender': gender,
      };

  factory BMIRecord.fromJson(Map<String, dynamic> json) => BMIRecord(
        bmi: (json['bmi'] as num).toDouble(),
        category: json['category'] as String,
        date: json['date'] as String,
        weight: (json['weight'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        isMetric: json['isMetric'] as bool,
        gender: json['gender'] as String,
      );
}

class BMIHistory {
  static const String _key = 'bmi_history';
  static const int _maxRecords = 5;

  static Future<List<BMIRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((e) => BMIRecord.fromJson(e)).toList();
  }

  static Future<void> addRecord(BMIRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, record);
    if (history.length > _maxRecords) {
      history.removeRange(_maxRecords, history.length);
    }
    final jsonStr = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
