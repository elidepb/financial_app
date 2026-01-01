import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/slidable_transaction_tile.dart';

class GroupedMovementsList {
  static List<Widget> buildSlivers({
    required List<MovementItem> movements,
    String? highlightedMovementId,
    Function(String)? onItemTap,
    Function(String)? onItemEdit,
    Function(String)? onItemDelete,
    bool isLoadingMore = false,
  }) {
    final grouped = _groupMovementsByDate(movements);
    final slivers = <Widget>[];

    grouped.forEach((dateKey, movementsList) {
      slivers.add(
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            child: _buildStickyHeader(dateKey),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final movement = movementsList[index];
              return SlidableTransactionTile(
                key: ValueKey(movement.id),
                movement: movement,
                isHighlighted: movement.id == highlightedMovementId,
                onTap: () => onItemTap?.call(movement.id),
                onEdit: () => onItemEdit?.call(movement.id),
                onDelete: () => onItemDelete?.call(movement.id),
              );
            },
            childCount: movementsList.length,
          ),
        ),
      );
    });

    if (isLoadingMore) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7E57C2),
              ),
            ),
          ),
        ),
      );
    }

    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(height: 100),
      ),
    );

    return slivers;
  }

  static Map<String, List<MovementItem>> _groupMovementsByDate(
      List<MovementItem> movements) {
    final grouped = <String, List<MovementItem>>{};

    for (var movement in movements) {
      final dateKey = _getDateKey(movement.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(movement);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final orderA = _getDateKeyOrder(a.key);
        final orderB = _getDateKeyOrder(b.key);
        if (orderA != orderB) return orderB.compareTo(orderA);
        return b.key.compareTo(a.key);
      });

    return Map.fromEntries(sortedEntries);
  }

  static int _getDateKeyOrder(String key) {
    if (key == 'Hoy') return 3;
    if (key == 'Ayer') return 2;
    if (key == 'Esta semana') return 1;
    return 0;
  }

  static String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == yesterday) {
      return 'Ayer';
    } else if (dateOnly.isAfter(weekStart) || dateOnly == weekStart) {
      return 'Esta semana';
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
      return '${months[date.month - 1]} ${date.year}';
    }
  }

  static Widget _buildStickyHeader(String dateKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF050B18),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7E57C2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) => false;
}
