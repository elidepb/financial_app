import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/category_list_tile.dart';

class ReorderableCategoryList extends StatefulWidget {
  final List<CategoryData> categories;
  final Function(String, String) onReorder; // oldIndex, newIndex
  final Function(String) onEdit;
  final Function(String) onDelete;

  const ReorderableCategoryList({
    super.key,
    required this.categories,
    required this.onReorder,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ReorderableCategoryList> createState() =>
      _ReorderableCategoryListState();
}

class _ReorderableCategoryListState extends State<ReorderableCategoryList> {
  late List<CategoryData> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  @override
  void didUpdateWidget(ReorderableCategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categories != oldWidget.categories) {
      _categories = List.from(widget.categories);
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final item = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, item);
    });

    HapticFeedback.mediumImpact();
    widget.onReorder(_categories[oldIndex].id, _categories[newIndex].id);
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay categorías',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: _categories.length,
      onReorder: _handleReorder,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return CategoryListTile(
          key: ValueKey(category.id),
          category: category,
          onEdit: () => widget.onEdit(category.id),
          onDelete: () => widget.onDelete(category.id),
        );
      },
    );
  }
}

