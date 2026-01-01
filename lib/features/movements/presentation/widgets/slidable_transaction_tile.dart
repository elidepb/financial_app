import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';

class SlidableTransactionTile extends StatelessWidget {
  final MovementItem movement;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isHighlighted;

  const SlidableTransactionTile({
    super.key,
    required this.movement,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Slidable(
        key: ValueKey(movement.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onEdit?.call();
              },
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                onDelete?.call();
              },
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: _buildTile(context),
      ),
    );
  }

  Widget _buildTile(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: isHighlighted
              ? Border.all(color: const Color(0xFF7E57C2), width: 2)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(14),
          borderRadius: 20,
          animateBorder: false,
          child: Row(
            children: [
              _buildCategoryIcon(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movement.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: isHighlighted ? TextDecoration.underline : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDate(movement.date),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        if (movement.category.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _getCategoryColor().withOpacity(0.3)),
                              ),
                              child: Text(
                                movement.category,
                                style: TextStyle(
                                  color: _getCategoryColor(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${movement.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: movement.isExpense
                          ? Colors.white
                          : const Color(0xFF34D399),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: movement.isExpense
                          ? []
                          : [
                              const Shadow(
                                color: Color(0xFF34D399),
                                blurRadius: 8,
                              ),
                            ],
                    ),
                  ),
                  if (movement.isExpense) 
                     Padding(
                       padding: const EdgeInsets.only(top: 2),
                       child: Icon(Icons.arrow_downward, size: 12, color: Colors.red[300]),
                     )
                  else
                     Padding(
                       padding: const EdgeInsets.only(top: 2),
                       child: Icon(Icons.arrow_upward, size: 12, color: const Color(0xFF34D399)),
                     )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _getCategoryColor().withOpacity(0.3)),
      ),
      child: Icon(
        _getCategoryIconData(),
        color: _getCategoryColor(),
        size: 22,
      ),
    );
  }

  IconData _getCategoryIconData() {
    final desc = movement.description.toLowerCase();
    final category = movement.category.toLowerCase();
    if (category.contains('food') || category.contains('alimentación') || desc.contains('food') || desc.contains('supermercado') || desc.contains('restaurante') || desc.contains('cena')) return Icons.restaurant;
    if (category.contains('transport') || category.contains('transporte') || desc.contains('uber') || desc.contains('taxi') || desc.contains('viaje')) {
      return Icons.directions_car;
    }
    if (category.contains('shopping') || category.contains('compras') || desc.contains('shopping') || desc.contains('amazon')) return Icons.shopping_bag;
    if (category.contains('entertainment') || category.contains('entretenimiento') || desc.contains('netflix')) return Icons.movie;
    if (category.contains('work') || category.contains('trabajo') || desc.contains('payment') || desc.contains('pago') || desc.contains('salary') || desc.contains('salario') || desc.contains('freelance')) {
      return Icons.work;
    }
    if (category.contains('housing') || category.contains('hogar') || desc.contains('rent')) return Icons.home;
    if (movement.isExpense) return Icons.receipt_long;
    return Icons.account_balance_wallet;
  }

  Color _getCategoryColor() {
    final category = movement.category.toLowerCase();
    if (category.contains('food') || category.contains('alimentación')) return const Color(0xFFE91E63);
    if (category.contains('transport') || category.contains('transporte')) return const Color(0xFF26C6DA);
    if (category.contains('shopping') || category.contains('compras')) return const Color(0xFFFFB300);
    if (category.contains('entertainment') || category.contains('entretenimiento')) return const Color(0xFF7E57C2);
    if (category.contains('work') || category.contains('trabajo')) return const Color(0xFF34D399);
    if (category.contains('housing') || category.contains('hogar')) return const Color(0xFFFF9800);
    if (!movement.isExpense) return const Color(0xFF34D399);
    return const Color(0xFF9E9E9E);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (dateOnly == today) {
      return 'Hoy';
    } else if (dateOnly == yesterday) {
      return 'Ayer';
    } else {
      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}