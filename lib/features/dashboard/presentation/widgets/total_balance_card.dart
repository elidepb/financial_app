import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/features/dashboard/data/providers/dashboard_providers.dart';

class TotalBalanceCard extends ConsumerWidget {
  const TotalBalanceCard({super.key});

  double _calculatePercentageChange(double current, double previous) {
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        final percentageChange = _calculatePercentageChange(summary.balance, summary.balance * 0.9);
        
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
                tween: Tween<double>(begin: 0, end: summary.balance),
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
                      '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    'Ingresos',
                    summary.income,
                    const Color(0xFF34D399),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildInfoItem(
                    'Gastos',
                    summary.spent,
                    const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => GlassContainer(
        padding: const EdgeInsets.all(24),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildInfoItem(String label, double amount, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
