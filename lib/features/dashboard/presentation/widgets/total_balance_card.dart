import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';

class TotalBalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double spent;
  final double percentageChange;

  const TotalBalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.spent,
    required this.percentageChange,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, 
                color: Colors.white.withOpacity(0.9), size: 18),
              const SizedBox(width: 8),
              Text(
                'Balance Total',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9), 
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: balance),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutExpo,
            builder: (context, value, child) {
              return Text(
                '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 42, 
                  fontWeight: FontWeight.bold,
                  shadows: [
                     Shadow(
                       blurRadius: 15.0,
                       color: Colors.black45,
                       offset: Offset(0, 5),
                     ),
                  ]
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  blurRadius: 8,
                )
              ]
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF34D399), size: 16),
                const SizedBox(width: 6),
                Text(
                  '+$percentageChange% respecto al mes pasado',
                  style: const TextStyle(
                    color: Color(0xFF34D399), 
                    fontSize: 13, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStat(context, 'INGRESOS', income, const Color(0xFF34D399), Icons.south_west),
              const SizedBox(width: 40),
              _buildStat(context, 'GASTOS', spent, const Color(0xFFF87171), Icons.north_east),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, double amount, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 12),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7), 
                fontSize: 12, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: amount),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutQuart,
          builder: (context, value, _) {
            return Text(
              '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                  )
                ]
              ),
            );
          }
        ),
      ],
    );
  }
}