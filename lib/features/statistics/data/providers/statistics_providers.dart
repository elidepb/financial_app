import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/database/database_provider.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/models/statistics_models.dart';

final monthlyDataProvider = FutureProvider.family<List<MonthlyData>, DateTimeRange>((ref, range) async {
    final movementsDao = ref.watch(movementsDaoProvider);
    final movements = await movementsDao.getMovementsByDateRange(range.start, range.end);
    
    final Map<DateTime, double> monthlyTotals = {};
    
    for (var movement in movements) {
      if (movement.type == 'expense') {
        final month = DateTime(movement.date.year, movement.date.month, 1);
        monthlyTotals[month] = (monthlyTotals[month] ?? 0.0) + movement.amount;
      }
    }
    
    final result = monthlyTotals.entries
        .map((entry) => MonthlyData(date: entry.key, amount: entry.value))
        .toList();
    
    result.sort((a, b) => a.date.compareTo(b.date));
    
    return result;
  });

final topCategoriesProvider = FutureProvider.family<List<CategoryRankData>, DateTimeRange>((ref, range) async {
  final movementsDao = ref.watch(movementsDaoProvider);
  final categoriesDao = ref.watch(categoriesDaoProvider);
  
  final totals = await movementsDao.getCategoryTotalsByDateRange(
    range.start,
    range.end,
    type: 'expense',
  );
  
  final categories = await categoriesDao.getAllCategories();
  final categoriesMap = {for (var cat in categories) cat.id: cat};
  
  final iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'local_hospital': Icons.local_hospital,
    'sports_esports': Icons.sports_esports,
    'checkroom': Icons.checkroom,
    'school': Icons.school,
    'build': Icons.build,
    'category': Icons.category,
  };
  
  final result = totals.take(4).map((total) {
    final category = categoriesMap[total.categoryId];
    if (category == null) {
      return CategoryRankData(
        name: 'Desconocida',
        icon: Icons.category,
        color: const Color(0xFF9E9E9E),
        amount: total.total,
      );
    }
    
    final icon = iconMap[category.icon] ?? Icons.category;
    final color = _parseColor(category.color);
    
    return CategoryRankData(
      name: category.name,
      icon: icon,
      color: color,
      amount: total.total,
    );
  }).toList();
  
  result.sort((a, b) => b.amount.compareTo(a.amount));
  
  return result;
});

Color _parseColor(String hexColor) {
  try {
    final hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF9E9E9E);
  } catch (e) {
    return const Color(0xFF9E9E9E);
  }
}

