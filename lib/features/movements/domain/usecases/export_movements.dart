import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';

class ExportMovements {
  String call(List<MovementItem> movements) {
    final buffer = StringBuffer();
    buffer.writeln('Movimientos Financieros\n');
    buffer.writeln('Fecha de exportación: ${DateTime.now().toString().split(' ')[0]}\n');
    buffer.writeln('Total de movimientos: ${movements.length}\n');
    buffer.writeln('─' * 50);

    for (var movement in movements) {
      final dateStr = movement.date.toString().split(' ')[0];
      final amountStr = movement.amount.toStringAsFixed(2);
      buffer.writeln('$dateStr | ${movement.description} | \$$amountStr | ${movement.category}');
    }

    buffer.writeln('─' * 50);
    final total = movements.fold<double>(
      0.0,
      (sum, m) => sum + (m.isExpense ? m.amount : -m.amount),
    );
    buffer.writeln('Total: \$${total.abs().toStringAsFixed(2)}');

    return buffer.toString();
  }
}

