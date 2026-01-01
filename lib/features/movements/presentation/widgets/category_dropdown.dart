import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/category_dropdown_styles.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/category_dropdown_empty_state.dart';

class CategoryOption {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String type;

  CategoryOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class CategoryDropdown extends StatefulWidget {
  final String? selectedCategoryId;
  final List<CategoryOption> categories;
  final ValueChanged<String> onCategoryChanged;
  final MovementType movementType;
  final String? Function(String?)? validator;

  const CategoryDropdown({
    super.key,
    this.selectedCategoryId,
    required this.categories,
    required this.onCategoryChanged,
    required this.movementType,
    this.validator,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryOption> get _filteredCategories {
    final type = widget.movementType == MovementType.expense
        ? 'expense'
        : 'income';
    var filtered = widget.categories
        .where((cat) => cat.type == type)
        .toList();
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cat) => 
        cat.name.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filtered;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField2<String>(
      value: widget.selectedCategoryId,
      isExpanded: true,
      decoration: CategoryDropdownStyles.getInputDecoration(),
      hint: Text(
        'Selecciona una categoría',
        style: TextStyle(
          color: const Color(0xFF8A92A0),
        ),
      ),
      items: _filteredCategories.isEmpty
          ? [
              DropdownMenuItem<String>(
                value: null,
                enabled: false,
                child: const CategoryDropdownEmptyState(),
              ),
            ]
          : _filteredCategories.map((category) {
              final isSelected = category.id == widget.selectedCategoryId;
              return DropdownMenuItem<String>(
                value: category.id,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (isSelected)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.check_circle,
                          key: ValueKey(category.id),
                          color: const Color(0xFF7E57C2),
                          size: 24,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
      onChanged: (value) {
        if (value != null) {
          widget.onCategoryChanged(value);
        }
      },
      validator: widget.validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'La categoría es obligatoria';
        }
        return null;
      },
      buttonStyleData: CategoryDropdownStyles.buttonStyle,
      iconStyleData: CategoryDropdownStyles.iconStyle,
      dropdownStyleData: CategoryDropdownStyles.getDropdownStyle(),
      dropdownSearchData: DropdownSearchData(
        searchController: _searchController,
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Container(
          height: 50,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 4,
            right: 8,
            left: 8,
          ),
          child: TextFormField(
            controller: _searchController,
              style: TextStyle(
                color: const Color(0xFFE0E6ED),
                fontSize: 12,
              ),
            decoration: CategoryDropdownStyles.getSearchDecoration(),
          ),
        ),
        searchMatchFn: (item, searchValue) {
          final category = widget.categories.firstWhere(
            (cat) => cat.id == item.value,
            orElse: () => widget.categories.first,
          );
          return category.name.toLowerCase().contains(
                searchValue.toLowerCase(),
              );
        },
      ),
      menuItemStyleData: CategoryDropdownStyles.menuItemStyle,
      selectedItemBuilder: (context) {
        return _filteredCategories.map((category) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

