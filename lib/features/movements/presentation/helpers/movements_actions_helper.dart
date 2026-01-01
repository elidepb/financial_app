import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/widgets/recent_movements_list.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';

class MovementsActionsHelper {
  static void showEditForm(
    BuildContext context,
    MovementItem movement,
    VoidCallback onSaved,
  ) {
    HapticFeedback.mediumImpact();
    
    MovementFormSheet.show(
      context,
      movementId: movement.id,
      initialType: movement.isExpense ? MovementType.expense : MovementType.income,
      onSaved: onSaved,
    );
  }

  static void showCreateForm(
    BuildContext context,
    MovementType type,
    VoidCallback onSaved,
  ) {
    MovementFormSheet.show(
      context,
      initialType: type,
      onSaved: onSaved,
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

