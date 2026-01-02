import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';

class MovementItem {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;

  MovementItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
  });
}

class RecentMovementsList extends StatelessWidget {
  final List<MovementItem> movements;
  final VoidCallback onViewAll;
  final Function(String) onItemTap;

  const RecentMovementsList({
    super.key,
    required this.movements,
    required this.onViewAll,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transacciones Recientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'Ver Todos',
                style: TextStyle(color: Color(0xFF7E57C2), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            movements.length,
            (index) {
              final movement = movements[index];
              return Padding(
                key: ValueKey('movement_${movement.id}'),
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildMovementCard(movement),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovementCard(MovementItem movement) {
    return InkWell(
      onTap: () => onItemTap(movement.id),
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        key: ValueKey('glass_${movement.id}'),
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        animateBorder: false,
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              _getCategoryIcon(movement.description),
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(movement.date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(
                 '${movement.amount > 0 ? '+' : ''}${movement.amount.toStringAsFixed(2)}',
                 style: TextStyle(
                   color: movement.isExpense
                       ? Colors.white
                       : const Color(0xFF34D399),
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   shadows: [
                     if(!movement.isExpense)
                       const Shadow(color: Color(0xFF34D399), blurRadius: 10)
                   ]
                 ),
               ),
             ],
           ),
        ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('foods') || desc.contains('starbucks')) return Icons.coffee_rounded;
    if (desc.contains('netflix')) return Icons.grid_view_rounded;
    if (desc.contains('payment')) return Icons.account_balance_wallet_rounded;
    if (desc.contains('uber')) return Icons.directions_car_filled_rounded;
    return Icons.receipt_long_rounded;
  }

  String _formatDate(DateTime date) {
    return 'Oct 23, 2023';
  }
}