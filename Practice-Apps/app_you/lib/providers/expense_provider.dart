import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isDarkMode = true;
  String _selectedFilter = 'All';
  ExpenseCategory? _selectedCategory;

  static const String _expensesKey = 'expenses';
  static const String _themeKey = 'isDarkMode';
  final _uuid = const Uuid();

  List<Expense> get expenses => _filteredExpenses;
  bool get isDarkMode => _isDarkMode;
  String get selectedFilter => _selectedFilter;
  ExpenseCategory? get selectedCategory => _selectedCategory;

  List<Expense> get _filteredExpenses {
    List<Expense> result = List.from(_expenses);

    if (_selectedCategory != null) {
      result = result.where((e) => e.category == _selectedCategory).toList();
    }

    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        result = result
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .toList();
        break;
      case 'Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        result = result.where((e) => e.date.isAfter(weekAgo)).toList();
        break;
      case 'Month':
        result = result
            .where((e) =>
                e.date.year == now.year && e.date.month == now.month)
            .toList();
        break;
      default:
        break;
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  double get totalExpenses =>
      _filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  double get monthlyTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get todayTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<ExpenseCategory, double> get categoryTotals {
    final Map<ExpenseCategory, double> totals = {};
    for (final expense in _filteredExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true;
    final expenseData = prefs.getString(_expensesKey);
    if (expenseData != null) {
      _expenses = Expense.decodeList(expenseData);
    }
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? note,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      date: date,
      category: category,
      note: note,
    );
    _expenses.insert(0, expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(ExpenseCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expensesKey, Expense.encodeList(_expenses));
  }
}
