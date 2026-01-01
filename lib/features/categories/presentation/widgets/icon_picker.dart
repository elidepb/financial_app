import 'package:flutter/material.dart';

class IconPicker extends StatefulWidget {
  final IconData? selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const IconPicker({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  late IconData _selectedIcon;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final Map<String, List<IconData>> _iconCategories = {
    'all': [],
    'Comida': [
      Icons.restaurant,
      Icons.restaurant_menu,
      Icons.local_pizza,
      Icons.fastfood,
      Icons.cake,
      Icons.local_cafe,
      Icons.local_dining,
      Icons.emoji_food_beverage,
      Icons.lunch_dining,
      Icons.dinner_dining,
    ],
    'Transporte': [
      Icons.directions_car,
      Icons.directions_bus,
      Icons.train,
      Icons.flight,
      Icons.directions_bike,
      Icons.electric_scooter,
      Icons.local_taxi,
      Icons.directions_walk,
    ],
    'Casa': [
      Icons.home,
      Icons.apartment,
      Icons.house_siding,
      Icons.construction,
      Icons.electric_bolt,
      Icons.water_drop,
      Icons.local_laundry_service,
      Icons.cleaning_services,
    ],
    'Salud': [
      Icons.local_hospital,
      Icons.medical_services,
      Icons.medication,
      Icons.fitness_center,
      Icons.sports_gymnastics,
      Icons.pool,
    ],
    'Entretenimiento': [
      Icons.movie,
      Icons.music_note,
      Icons.sports_esports,
      Icons.theater_comedy,
      Icons.library_books,
      Icons.headphones,
    ],
    'Ropa': [
      Icons.checkroom,
      Icons.shopping_bag,
      Icons.diamond,
      Icons.watch,
    ],
    'Educación': [
      Icons.school,
      Icons.menu_book,
      Icons.auto_stories,
      Icons.computer,
    ],
    'Otros': [
      Icons.more_horiz,
      Icons.category,
      Icons.label,
      Icons.tag,
      Icons.attach_money,
      Icons.account_balance_wallet,
      Icons.receipt,
      Icons.payment,
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon ?? Icons.category;
    _iconCategories['all'] = _iconCategories.values
        .where((list) => list.isNotEmpty)
        .expand((list) => list)
        .toList();
  }

  List<IconData> get _filteredIcons {
    var icons = _iconCategories[_selectedCategory] ?? [];

    if (_searchQuery.isNotEmpty) {
      icons = icons.where((icon) {
        final iconName = icon.toString().toLowerCase();
        return iconName.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return icons;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icono',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar icono...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _iconCategories.keys.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _filteredIcons.length,
            itemBuilder: (context, index) {
              final icon = _filteredIcons[index];
              final isSelected = _selectedIcon == icon;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                  widget.onIconSelected(icon);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _selectedIcon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Icono seleccionado',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

