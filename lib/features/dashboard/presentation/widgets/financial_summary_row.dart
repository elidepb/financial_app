import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/dashboard_info_card.dart';

class FinancialSummaryRow extends StatefulWidget {
  const FinancialSummaryRow({super.key});

  @override
  State<FinancialSummaryRow> createState() => _FinancialSummaryRowState();
}

class _FinancialSummaryRowState extends State<FinancialSummaryRow> with SingleTickerProviderStateMixin {
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
    final cards = [
      _buildAnimatedItem(
        0,
        const DashboardInfoCard(
          title: 'PRESUPUESTO RESTANTE',
          amount: 1560.0,
          icon: Icons.credit_card,
        ),
      ),
      _buildAnimatedItem(
        1,
        const DashboardInfoCard(
          title: 'PROMEDIO DIARIO',
          amount: 108.0,
          icon: Icons.attach_money,
          iconColor: Color(0xFFE91E63),
        ),
      ),
      _buildAnimatedItem(
        2,
        const DashboardInfoCard(
          title: 'META DE AHORRO',
          amount: 2500.0,
          icon: Icons.account_balance_wallet,
          iconColor: Color(0xFF00C853),
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