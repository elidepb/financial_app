import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_gestor_financiero/core/router/route_paths.dart';
import 'package:app_gestor_financiero/core/widgets/custom_bottom_nav.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/custom_fab.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/total_balance_card.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/dynamic_spending_chart.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/financial_summary_row.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildWelcomeSection(context),
                const SizedBox(height: 24),
                const TotalBalanceCard(
                  balance: 12450.0,
                  income: 5800.0,
                  spent: 3241.0,
                  percentageChange: 12.5,
                ),
                const SizedBox(height: 24),
                const FinancialSummaryRow(),
                const SizedBox(height: 24),
                DynamicSpendingChart(
                  categoryBreakdown: {
                    'food': CategoryData(
                      name: 'Alimentación',
                      amount: 1200.0,
                      color: const Color(0xFF7E57C2),
                      icon: 'restaurant',
                    ),
                    'transport': CategoryData(
                      name: 'Transporte',
                      amount: 800.0,
                      color: const Color(0xFFE91E63),
                    ),
                    'shopping': CategoryData(
                      name: 'Compras',
                      amount: 600.0,
                      color: const Color(0xFF26C6DA),
                    ),
                    'housing': CategoryData(
                      name: 'Hogar',
                      amount: 640.5,
                      color: const Color(0xFFFFB300),
                    ),
                  },
                ),
                const SizedBox(height: 24),
                RecentMovementsList(
                  movements: _getSampleMovements(),
                  onViewAll: () => context.go(RoutePaths.expenses),
                  onItemTap: (id) {
                    MovementFormSheet.show(
                      context,
                      movementId: id,
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (fabContext) {
          return CustomFAB(
            onExpensePressed: () {
              if (!fabContext.mounted) return;
              MovementFormSheet.show(
                fabContext,
                initialType: MovementType.expense,
                onSaved: () {
                  if (fabContext.mounted) {
                    ScaffoldMessenger.of(fabContext).showSnackBar(
                      const SnackBar(
                        content: Text('Gasto registrado exitosamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
            onIncomePressed: () {
              if (!fabContext.mounted) return;
              MovementFormSheet.show(
                fabContext,
                initialType: MovementType.income,
                onSaved: () {
                  if (fabContext.mounted) {
                    ScaffoldMessenger.of(fabContext).showSnackBar(
                      const SnackBar(
                        content: Text('Ingreso registrado exitosamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel de Control',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Bienvenido de nuevo, Alex',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF673AB7).withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
          ),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF673AB7),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  List<MovementItem> _getSampleMovements() {
    return [
      MovementItem(
        id: '1',
        description: 'Supermercado',
        amount: -84.50,
        category: 'Alimentación',
        date: DateTime.now(),
        isExpense: true,
      ),
      MovementItem(
        id: '2',
        description: 'Suscripción Netflix',
        amount: -15.99,
        category: 'Entretenimiento',
        date: DateTime.now(),
        isExpense: true,
      ),
      MovementItem(
        id: '3',
        description: 'Pago Freelance',
        amount: 1200.00,
        category: 'Trabajo',
        date: DateTime.now(),
        isExpense: false,
      ),
    ];
  }
}