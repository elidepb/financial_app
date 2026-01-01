import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/category_icon.dart';

class CategoryData {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int movementCount;

  CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.movementCount = 0,
  });
}

class CategoryListTile extends StatelessWidget {
  final CategoryData category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isHighlighted;

  const CategoryListTile({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(category.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isHighlighted
              ? category.color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CategoryIcon(
            icon: category.icon,
            color: category.color,
            size: CategoryIconSize.medium,
          ),
          title: Text(
            category.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${category.movementCount} movimientos asociados',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: Icon(
            Icons.drag_handle,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

