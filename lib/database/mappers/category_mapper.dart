import '../../features/movements/presentation/widgets/category_dropdown.dart';
import '../app_database.dart';
import 'package:flutter/material.dart';

class CategoryMapper {
  static CategoryOption toCategoryOption(Category category) {
    final iconData = _getIconData(category.icon);
    final color = _parseColor(category.color);
    
    return CategoryOption(
      id: category.id,
      name: category.name,
      icon: iconData,
      color: color,
      type: category.type,
    );
  }

  static List<CategoryOption> toCategoryOptions(List<Category> categories) {
    return categories.map((category) => toCategoryOption(category)).toList();
  }

  static IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'local_hospital': Icons.local_hospital,
      'sports_esports': Icons.sports_esports,
      'checkroom': Icons.checkroom,
      'school': Icons.school,
      'build': Icons.build,
      'category': Icons.category,
      'work': Icons.work,
      'laptop': Icons.laptop,
      'trending_up': Icons.trending_up,
      'card_giftcard': Icons.card_giftcard,
      'attach_money': Icons.attach_money,
    };
    
    return iconMap[iconName] ?? Icons.category;
  }

  static Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}

