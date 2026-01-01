import 'package:flutter/material.dart';

class CategoryDropdownEmptyState extends StatelessWidget {
  const CategoryDropdownEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay categorías',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crear una',
              style: TextStyle(
                color: const Color(0xFF7E57C2),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

