import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/features/categories/presentation/widgets/category_icon.dart';

class CategoryPreviewCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryPreviewCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Vista Previa',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          CategoryIcon(
            icon: icon,
            color: color,
            size: CategoryIconSize.large,
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty ? 'Nombre' : name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

