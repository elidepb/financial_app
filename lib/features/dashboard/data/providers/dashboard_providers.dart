import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/database/database_provider.dart';

class DashboardSummary {
  final double balance;
  final double income;
  final double spent;
  final double? budgetRemaining;
  final double averageDaily;

  DashboardSummary({
    required this.balance,
    required this.income,
    required this.spent,
    this.budgetRemaining,
    required this.averageDaily,
  });
}

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final movementsDao = ref.watch(movementsDaoProvider);
  final settingsDao = ref.watch(settingsDaoProvider);

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final movements = await movementsDao.getMovementsByDateRange(startOfMonth, endOfMonth);

  double totalIncome = 0.0;
  double totalExpenses = 0.0;

  for (var movement in movements) {
    if (movement.type == 'income') {
      totalIncome += movement.amount;
    } else {
      totalExpenses += movement.amount;
    }
  }

  final balance = totalIncome - totalExpenses;
  final daysInMonth = now.day;
  final averageDaily = daysInMonth > 0 ? totalExpenses / daysInMonth : 0.0;

  final budgetSetting = await settingsDao.getSettingValueAsDouble('monthly_budget');
  final budgetRemaining = budgetSetting != null && budgetSetting > 0
      ? budgetSetting - totalExpenses
      : null;

  return DashboardSummary(
    balance: balance,
    income: totalIncome,
    spent: totalExpenses,
    budgetRemaining: budgetRemaining,
    averageDaily: averageDaily,
  );
});

class CategoryBreakdown {
  final String categoryId;
  final String name;
  final double amount;
  final String color;

  CategoryBreakdown({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.color,
  });
}

final categoryBreakdownProvider = FutureProvider<List<CategoryBreakdown>>((ref) async {
  final movementsDao = ref.watch(movementsDaoProvider);
  final categoriesDao = ref.watch(categoriesDaoProvider);

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final totals = await movementsDao.getCategoryTotalsByDateRange(
    startOfMonth,
    endOfMonth,
    type: 'expense',
  );

  final categories = await categoriesDao.getAllCategories();
  final categoriesMap = {for (var cat in categories) cat.id: cat};

  return totals.map((total) {
    final category = categoriesMap[total.categoryId];
    if (category == null) {
      return CategoryBreakdown(
        categoryId: total.categoryId,
        name: 'Desconocida',
        amount: total.total,
        color: '#9E9E9E',
      );
    }
    return CategoryBreakdown(
      categoryId: category.id,
      name: category.name,
      amount: total.total,
      color: category.color,
    );
  }).toList();
});


