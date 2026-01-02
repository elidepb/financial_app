import '../../features/dashboard/presentation/widgets/recent_movements_list.dart';
import '../app_database.dart';

class MovementMapper {
  static MovementItem toMovementItem(Movement movement, Category category) {
    return MovementItem(
      id: movement.id,
      description: movement.description,
      amount: movement.type == 'expense' ? -movement.amount : movement.amount,
      category: category.name,
      date: movement.date,
      isExpense: movement.type == 'expense',
    );
  }

  static List<MovementItem> toMovementItems(List<Movement> movements, Map<String, Category> categoriesMap) {
    return movements.map((movement) {
      final category = categoriesMap[movement.categoryId];
      if (category == null) {
        throw Exception('Category not found: ${movement.categoryId}');
      }
      return toMovementItem(movement, category);
    }).toList();
  }
}

