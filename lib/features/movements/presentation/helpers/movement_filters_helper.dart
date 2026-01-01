import 'package:flutter/material.dart';

class MovementFiltersHelper {
  static IconData getFilterIcon(String key) {
    switch (key.toLowerCase()) {
      case 'date':
      case 'fecha':
        return Icons.calendar_today;
      case 'category':
      case 'categoria':
        return Icons.category;
      case 'amount':
      case 'monto':
        return Icons.attach_money;
      default:
        return Icons.filter_alt;
    }
  }

  static Color getFilterColor(String key) {
    switch (key.toLowerCase()) {
      case 'date':
      case 'fecha':
        return const Color(0xFF7E57C2);
      case 'category':
      case 'categoria':
        return const Color(0xFFE91E63);
      case 'amount':
      case 'monto':
        return const Color(0xFF26C6DA);
      default:
        return const Color(0xFF7E57C2);
    }
  }
}

