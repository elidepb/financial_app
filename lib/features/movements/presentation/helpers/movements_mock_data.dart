import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';

class MovementsMockData {
  static List<MovementItem> getSampleMovements() {
    final now = DateTime.now();
    return [
      MovementItem(
        id: '1',
        description: 'Supermercado',
        amount: -84.50,
        category: 'Alimentación',
        date: now.subtract(const Duration(hours: 2)),
        isExpense: true,
      ),
      MovementItem(
        id: '2',
        description: 'Suscripción Netflix',
        amount: -15.99,
        category: 'Entretenimiento',
        date: now.subtract(const Duration(days: 1)),
        isExpense: true,
      ),
      MovementItem(
        id: '3',
        description: 'Pago Freelance',
        amount: 1200.00,
        category: 'Trabajo',
        date: now.subtract(const Duration(days: 2)),
        isExpense: false,
      ),
      MovementItem(
        id: '4',
        description: 'Viaje en Uber',
        amount: -12.50,
        category: 'Transporte',
        date: now.subtract(const Duration(days: 3)),
        isExpense: true,
      ),
      MovementItem(
        id: '5',
        description: 'Compras en Amazon',
        amount: -89.99,
        category: 'Compras',
        date: now.subtract(const Duration(days: 5)),
        isExpense: true,
      ),
      MovementItem(
        id: '6',
        description: 'Salario',
        amount: 3500.00,
        category: 'Trabajo',
        date: now.subtract(const Duration(days: 7)),
        isExpense: false,
      ),
      MovementItem(
        id: '7',
        description: 'Cena en Restaurante',
        amount: -65.00,
        category: 'Alimentación',
        date: now.subtract(const Duration(days: 8)),
        isExpense: true,
      ),
    ];
  }
}

