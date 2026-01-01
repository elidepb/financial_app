import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/color_picker.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/icon_picker.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/category_preview_card.dart';

class CategoryFormData {
  final String? id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryFormData({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CategoryFormDialog extends StatefulWidget {
  final CategoryFormData? initialData;
  final Function(CategoryFormData) onSave;

  const CategoryFormDialog({
    super.key,
    this.initialData,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    CategoryFormData? initialData,
    required Function(CategoryFormData) onSave,
  }) {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => CategoryFormDialog(
          initialData: initialData,
          onSave: onSave,
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
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: CategoryFormDialog(
              initialData: initialData,
              onSave: onSave,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late IconData _selectedIcon;
  late Color _selectedColor;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initialData != null;
    _nameController.text = widget.initialData?.name ?? '';
    _selectedIcon = widget.initialData?.icon ?? Icons.category;
    _selectedColor = widget.initialData?.color ?? const Color(0xFF2196F3);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(CategoryFormData(
        id: widget.initialData?.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEditing ? 'Editar Categoría' : 'Nueva Categoría',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isMobile) ...[
              CategoryPreviewCard(
                name: _nameController.text,
                icon: _selectedIcon,
                color: _selectedColor,
              ),
              const SizedBox(height: 24),
            ],
            Flexible(
              child: SingleChildScrollView(
                child: isMobile
                    ? Column(
                        children: [
                          _buildNameField(theme),
                          const SizedBox(height: 24),
                          ColorPicker(
                            selectedColor: _selectedColor,
                            onColorSelected: (color) {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          IconPicker(
                            selectedIcon: _selectedIcon,
                            onIconSelected: (icon) {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            },
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildNameField(theme),
                                const SizedBox(height: 24),
                                ColorPicker(
                                  selectedColor: _selectedColor,
                                  onColorSelected: (color) {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                ),
                                const SizedBox(height: 24),
                                IconPicker(
                                  selectedIcon: _selectedIcon,
                                  onIconSelected: (icon) {
                                    setState(() {
                                      _selectedIcon = icon;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: CategoryPreviewCard(
                              name: _nameController.text,
                              icon: _selectedIcon,
                              color: _selectedColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isEditing ? 'Actualizar' : 'Crear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nombre de la categoría',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El nombre es obligatorio';
        }
        return null;
      },
    );
  }

}

