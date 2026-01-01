import 'package:flutter/material.dart';

enum CategoryIconSize {
  small,
  medium,
  large,
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final CategoryIconSize size;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = CategoryIconSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize;
    final double containerSize;

    switch (size) {
      case CategoryIconSize.small:
        iconSize = 16;
        containerSize = 32;
        break;
      case CategoryIconSize.medium:
        iconSize = 24;
        containerSize = 48;
        break;
      case CategoryIconSize.large:
        iconSize = 32;
        containerSize = 64;
        break;
    }

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }
}

