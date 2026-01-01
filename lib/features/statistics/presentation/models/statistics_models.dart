import 'package:flutter/material.dart';

class MonthlyData {
  final DateTime date;
  final double amount;

  MonthlyData({
    required this.date,
    required this.amount,
  });
}

class CategoryRankData {
  final String name;
  final IconData icon;
  final Color color;
  final double amount;

  const CategoryRankData({
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
  });
}

