import 'dart:convert';
import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  health,
  entertainment,
  bills,
  education,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get name {
    switch (this) {
      case ExpenseCategory.food:        return 'Food';
      case ExpenseCategory.transport:   return 'Transport';
      case ExpenseCategory.shopping:    return 'Shopping';
      case ExpenseCategory.health:      return 'Health';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.bills:       return 'Bills';
      case ExpenseCategory.education:   return 'Education';
      case ExpenseCategory.other:       return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:          return Icons.restaurant_rounded;
      case ExpenseCategory.transport:     return Icons.directions_car_rounded;
      case ExpenseCategory.shopping:      return Icons.shopping_bag_rounded;
      case ExpenseCategory.health:        return Icons.favorite_rounded;
      case ExpenseCategory.entertainment: return Icons.movie_rounded;
      case ExpenseCategory.bills:         return Icons.receipt_long_rounded;
      case ExpenseCategory.education:     return Icons.school_rounded;
      case ExpenseCategory.other:         return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:          return const Color(0xFFFF6B6B);
      case ExpenseCategory.transport:     return const Color(0xFF4ECDC4);
      case ExpenseCategory.shopping:      return const Color(0xFFFFB347);
      case ExpenseCategory.health:        return const Color(0xFFFF8B94);
      case ExpenseCategory.entertainment: return const Color(0xFF88D8B0);
      case ExpenseCategory.bills:         return const Color(0xFF6C63FF);
      case ExpenseCategory.education:     return const Color(0xFFFFD93D);
      case ExpenseCategory.other:         return const Color(0xFF95A5A6);
    }
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.index,
        'note': note,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        category: ExpenseCategory.values[json['category'] as int],
        note: json['note'] as String?,
      );

  static String encodeList(List<Expense> expenses) =>
      jsonEncode(expenses.map((e) => e.toJson()).toList());

  static List<Expense> decodeList(String data) {
    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
