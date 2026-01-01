import 'package:flutter/material.dart';

class MovementFormHeader extends StatelessWidget {
  final bool isMobile;
  final bool isEditing;
  final VoidCallback onClose;

  const MovementFormHeader({
    super.key,
    required this.isMobile,
    required this.isEditing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (isMobile)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Row(
            children: [
              if (!isMobile) ...[
                Text(
                  isEditing ? 'Editar Movimiento' : 'Nuevo Movimiento',
                  style: const TextStyle(
                    color: Color(0xFFE0E6ED),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
              if (isMobile) ...[
                const Spacer(),
                Text(
                  isEditing ? 'Editar Movimiento' : 'Nuevo Movimiento',
                  style: const TextStyle(
                    color: Color(0xFFE0E6ED),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFFB0B8C4),
                ),
                tooltip: 'Cerrar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

