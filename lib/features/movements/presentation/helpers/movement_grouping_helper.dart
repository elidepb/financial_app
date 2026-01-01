import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/slidable_transaction_tile.dart';

class MovementGroupingHelper {
  static List<Widget> buildGroupedSlivers({
    required List<MovementItem> movements,
    required String? highlightMovementId,
    required Function(String) onItemTap,
    required Function(String) onItemEdit,
    required Function(String) onItemDelete,
  }) {
    if (movements.isEmpty) return [];

    final groupedMap = <String, List<MovementItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    for (var movement in movements) {
      final mDate = DateTime(movement.date.year, movement.date.month, movement.date.day);
      String key;

      if (mDate == today) {
        key = 'Hoy';
      } else if (mDate == yesterday) {
        key = 'Ayer';
      } else if (mDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        key = 'Esta semana';
      } else {
        final months = [
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre'
        ];
        key = '${months[mDate.month - 1]} ${mDate.year}';
      }

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = [];
      }
      groupedMap[key]!.add(movement);
    }

    final List<Widget> slivers = [];

    groupedMap.forEach((header, movementsList) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7E57C2).withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  header,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final movement = movementsList[index];
              return SlidableTransactionTile(
                movement: movement,
                isHighlighted: movement.id == highlightMovementId,
                onTap: () => onItemTap(movement.id),
                onEdit: () => onItemEdit(movement.id),
                onDelete: () => onItemDelete(movement.id),
              );
            },
            childCount: movementsList.length,
          ),
        ),
      );
    });

    slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 100)));

    return slivers;
  }
}

