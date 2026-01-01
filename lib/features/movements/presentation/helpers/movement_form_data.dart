import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/category_dropdown.dart';

class MovementFormDataHelper {
  static List<CategoryOption> getDefaultCategories() {
    return [
      CategoryOption(
        id: 'cat_food',
        name: 'Alimentación',
        icon: Icons.restaurant,
        color: const Color(0xFFFF5722),
        type: 'expense',
      ),
      CategoryOption(
        id: 'cat_transport',
        name: 'Transporte',
        icon: Icons.directions_car,
        color: const Color(0xFF2196F3),
        type: 'expense',
      ),
      CategoryOption(
        id: 'cat_home',
        name: 'Hogar',
        icon: Icons.home,
        color: const Color(0xFF4CAF50),
        type: 'expense',
      ),
      CategoryOption(
        id: 'cat_health',
        name: 'Salud',
        icon: Icons.local_hospital,
        color: const Color(0xFFE91E63),
        type: 'expense',
      ),
      CategoryOption(
        id: 'cat_entertainment',
        name: 'Entretenimiento',
        icon: Icons.movie,
        color: const Color(0xFF9C27B0),
        type: 'expense',
      ),
      CategoryOption(
        id: 'cat_salary',
        name: 'Salario',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF4CAF50),
        type: 'income',
      ),
      CategoryOption(
        id: 'cat_freelance',
        name: 'Freelance',
        icon: Icons.work,
        color: const Color(0xFF4CAF50),
        type: 'income',
      ),
      CategoryOption(
        id: 'cat_other_income',
        name: 'Otros Ingresos',
        icon: Icons.attach_money,
        color: const Color(0xFF00BCD4),
        type: 'income',
      ),
    ];
  }

  static List<Map<String, dynamic>> getMockMovements() {
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'description': 'Whole Foods Market',
        'amount': -84.50,
        'category': 'Food',
        'date': now.subtract(const Duration(hours: 2)),
        'isExpense': true,
        'notes': '',
      },
      {
        'id': '2',
        'description': 'Netflix Subscription',
        'amount': -15.99,
        'category': 'Entertainment',
        'date': now.subtract(const Duration(days: 1)),
        'isExpense': true,
        'notes': '',
      },
      {
        'id': '3',
        'description': 'Freelance Payment',
        'amount': 1200.00,
        'category': 'Work',
        'date': now.subtract(const Duration(days: 2)),
        'isExpense': false,
        'notes': '',
      },
      {
        'id': '4',
        'description': 'Uber Ride',
        'amount': -12.50,
        'category': 'Transport',
        'date': now.subtract(const Duration(days: 3)),
        'isExpense': true,
        'notes': '',
      },
      {
        'id': '5',
        'description': 'Amazon Shopping',
        'amount': -89.99,
        'category': 'Shopping',
        'date': now.subtract(const Duration(days: 5)),
        'isExpense': true,
        'notes': '',
      },
      {
        'id': '6',
        'description': 'Salary',
        'amount': 3500.00,
        'category': 'Work',
        'date': now.subtract(const Duration(days: 7)),
        'isExpense': false,
        'notes': '',
      },
      {
        'id': '7',
        'description': 'Restaurant Dinner',
        'amount': -65.00,
        'category': 'Food',
        'date': now.subtract(const Duration(days: 8)),
        'isExpense': true,
        'notes': '',
      },
    ];
  }

  static String? findCategoryIdByName(String categoryName, List<CategoryOption> categories) {
    final categoryMap = {
      'Food': 'cat_food',
      'Alimentación': 'cat_food',
      'Transport': 'cat_transport',
      'Transporte': 'cat_transport',
      'Home': 'cat_home',
      'Hogar': 'cat_home',
      'Health': 'cat_health',
      'Salud': 'cat_health',
      'Entertainment': 'cat_entertainment',
      'Entretenimiento': 'cat_entertainment',
      'Work': 'cat_salary',
      'Trabajo': 'cat_salary',
      'Freelance': 'cat_freelance',
      'Shopping': 'cat_food',
    };
    
    return categoryMap[categoryName] ?? categories.first.id;
  }
}

