import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/reorderable_category_list.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/category_form_dialog.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  static Future<void> show(BuildContext context) async {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    if (isMobile) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoriesPage(),
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
            child: const CategoriesPage(),
          ),
        ),
      );
    }
  }

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryData> _categories = [
    CategoryData(
      id: 'cat_food',
      name: 'Alimentación',
      icon: Icons.restaurant,
      color: const Color(0xFFFF5722),
      movementCount: 15,
    ),
    CategoryData(
      id: 'cat_transport',
      name: 'Transporte',
      icon: Icons.directions_car,
      color: const Color(0xFF2196F3),
      movementCount: 8,
    ),
    CategoryData(
      id: 'cat_home',
      name: 'Hogar',
      icon: Icons.home,
      color: const Color(0xFF4CAF50),
      movementCount: 12,
    ),
    CategoryData(
      id: 'cat_health',
      name: 'Salud',
      icon: Icons.local_hospital,
      color: const Color(0xFFE91E63),
      movementCount: 5,
    ),
    CategoryData(
      id: 'cat_entertainment',
      name: 'Entretenimiento',
      icon: Icons.movie,
      color: const Color(0xFF9C27B0),
      movementCount: 10,
    ),
  ];

  void _handleAddCategory() {
    CategoryFormDialog.show(
      context,
      onSave: (data) {
        setState(() {
          _categories.add(CategoryData(
            id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
            name: data.name,
            icon: data.icon,
            color: data.color,
          ));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoría "${data.name}" creada')),
        );
      },
    );
  }

  void _handleEditCategory(String categoryId) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    CategoryFormDialog.show(
      context,
      initialData: CategoryFormData(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
      ),
      onSave: (data) {
        setState(() {
          final index = _categories.indexWhere((c) => c.id == categoryId);
          if (index != -1) {
            _categories[index] = CategoryData(
              id: data.id ?? categoryId,
              name: data.name,
              icon: data.icon,
              color: data.color,
            movementCount: category.movementCount,
          );
        }
      });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoría "${data.name}" actualizada')),
        );
      },
    );
  }

  void _handleDeleteCategory(String categoryId) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${category.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _categories.removeWhere((c) => c.id == categoryId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Categoría "${category.name}" eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _handleReorder(String oldId, String newId) {
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleAddCategory,
            tooltip: 'Agregar categoría',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Mantén presionado y arrastra para reordenar las categorías',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: ReorderableCategoryList(
              categories: _categories,
              onReorder: _handleReorder,
              onEdit: _handleEditCategory,
              onDelete: _handleDeleteCategory,
            ),
          ),
        ],
      ),
    );
  }
}

