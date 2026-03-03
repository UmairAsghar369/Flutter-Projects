import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/category_chart.dart';
import '../widgets/filter_chips.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _listFade;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _listFade = CurvedAnimation(parent: _listController, curve: Curves.easeOut);

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _listController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isDark = provider.isDarkMode;
    final formatter = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildHeader(provider, isDark, formatter),
              ),
            ),
            const SizedBox(height: 12),
            _buildTabBar(isDark),
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  FadeTransition(
                    opacity: _listFade,
                    child: _buildExpensesTab(provider, isDark, formatter),
                  ),
                  CategoryChart(
                    isDark: isDark,
                    provider: provider,
                    formatter: formatter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildHeader(ExpenseProvider provider, bool isDark, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: provider.monthlyTotal),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (context, value, _) => Text(
                      formatter.format(value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: provider.toggleTheme,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    provider.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Today',
                  amount: provider.todayTotal,
                  icon: Icons.today_rounded,
                  gradient: AppTheme.expenseGradient,
                  formatter: formatter,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  label: 'Transactions',
                  amount: provider.expenses.length.toDouble(),
                  icon: Icons.receipt_rounded,
                  gradient: AppTheme.incomeGradient,
                  formatter: formatter,
                  isCount: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildTab('Expenses', 0, isDark),
            _buildTab('Analytics', 1, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, bool isDark) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppTheme.textGrey : Colors.grey),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesTab(ExpenseProvider provider, bool isDark, NumberFormat formatter) {
    return Column(
      children: [
        const FilterChipsRow(),
        const SizedBox(height: 8),
        Expanded(
          child: provider.expenses.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = provider.expenses[index];
                    return ExpenseListItem(
                      expense: expense,
                      index: index,
                      isDark: isDark,
                      formatter: formatter,
                      onDelete: () => provider.deleteExpense(expense.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 52,
              color: AppTheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet!',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first expense',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey.withOpacity(0.6) : Colors.grey.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const AddExpenseScreen(),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
