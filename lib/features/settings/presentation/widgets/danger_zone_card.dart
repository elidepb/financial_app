import 'package:flutter/material.dart';

class DangerZoneCard extends StatelessWidget {
  final VoidCallback? onClearAllData;

  const DangerZoneCard({
    super.key,
    this.onClearAllData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Zona Peligrosa',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Las acciones en esta sección no se pueden deshacer. Por favor, procede con precaución.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onClearAllData ??
                () => _showClearDataConfirmation(context),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Borrar Todos los Datos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool canConfirm = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Confirmar Eliminación',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esta acción eliminará TODOS tus datos de forma permanente. Esta acción no se puede deshacer.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Para confirmar, escribe "ELIMINAR" en el campo:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'ELIMINAR',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      canConfirm = value == 'ELIMINAR';
                    });
                  },
                  validator: (value) {
                    if (value != 'ELIMINAR') {
                      return 'Debes escribir exactamente "ELIMINAR"';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: canConfirm
                  ? () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(context).pop();
                        Navigator.of(dialogContext).pop();
                        onClearAllData?.call();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar Todo'),
            ),
          ],
        ),
      ),
    );
  }
}

