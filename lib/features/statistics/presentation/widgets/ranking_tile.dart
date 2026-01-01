import 'package:flutter/material.dart';

class RankingTile extends StatelessWidget {
  final int position;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double amount;
  final double maxAmount;
  final VoidCallback onTap;

  const RankingTile({
    super.key,
    required this.position,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.maxAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = maxAmount > 0 ? (amount / maxAmount) : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              _buildMedal(position),
              
              const SizedBox(width: 12),

              Icon(
                categoryIcon,
                color: categoryColor,
                size: 20,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 4,
                          width: 60 * percentage,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withOpacity(0.5),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                'S/${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedal(int pos) {
    Color medalColor;
    switch (pos) {
      case 1:
        medalColor = const Color(0xFFFFD700); // Oro
        break;
      case 2:
        medalColor = const Color(0xFFC0C0C0); // Plata
        break;
      case 3:
        medalColor = const Color(0xFFCD7F32); // Bronce
        break;
      default:
        medalColor = Colors.white.withOpacity(0.5);
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: medalColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: medalColor.withOpacity(0.3), width: 1),
      ),
      child: Center(
        child: pos <= 3 
          ? Icon(Icons.emoji_events, size: 14, color: medalColor)
          : Text(
              '#$pos',
              style: TextStyle(
                color: medalColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }
}