import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/dashboard_info_card.dart';
import 'package:app_gestor_financiero/features/dashboard/data/providers/dashboard_providers.dart';

class FinancialSummaryRow extends ConsumerStatefulWidget {
  const FinancialSummaryRow({super.key});

  @override
  ConsumerState<FinancialSummaryRow> createState() => _FinancialSummaryRowState();
}

class _FinancialSummaryRowState extends ConsumerState<FinancialSummaryRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        final cards = [
          _buildAnimatedItem(
            0,
            DashboardInfoCard(
              title: 'PRESUPUESTO RESTANTE',
              amount: summary.budgetRemaining ?? 0.0,
              icon: Icons.credit_card,
            ),
          ),
          _buildAnimatedItem(
            1,
            DashboardInfoCard(
              title: 'PROMEDIO DIARIO',
              amount: summary.averageDaily,
              icon: Icons.attach_money,
              iconColor: const Color(0xFFE91E63),
            ),
          ),
          _buildAnimatedItem(
            2,
            DashboardInfoCard(
              title: 'META DE AHORRO',
              amount: summary.balance > 0 ? summary.balance : 0.0,
              icon: Icons.account_balance_wallet,
              iconColor: const Color(0xFF00C853),
            ),
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: cards.map((c) => Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: c,
                ))).toList(),
              );
            } else {
              return Column(
                children: cards.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: c,
                )).toList(),
              );
            }
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.5 + (index * 0.2),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.2,
              0.5 + (index * 0.2),
              curve: Curves.easeIn,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
