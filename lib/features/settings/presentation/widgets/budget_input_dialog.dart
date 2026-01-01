import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/widgets/currency_text_widget.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/amount_text_field.dart';

class BudgetInputDialog extends StatefulWidget {
  final double? currentBudget;
  final double? averageExpenses;
  final Function(double) onSave;

  const BudgetInputDialog({
    super.key,
    this.currentBudget,
    this.averageExpenses,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    double? currentBudget,
    double? averageExpenses,
    required Function(double) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BudgetInputDialog(
        currentBudget: currentBudget,
        averageExpenses: averageExpenses,
        onSave: onSave,
      ),
    );
  }

  @override
  State<BudgetInputDialog> createState() => _BudgetInputDialogState();
}

class _BudgetInputDialogState extends State<BudgetInputDialog> {
  final _formKey = GlobalKey<FormState>();
  double? _budget;
  double? _budgetValue;

  @override
  void initState() {
    super.initState();
    if (widget.currentBudget != null) {
      _budget = widget.currentBudget!.toStringAsFixed(2);
      _budgetValue = widget.currentBudget;
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate() && _budgetValue != null) {
      widget.onSave(_budgetValue!);
      Navigator.of(context).pop();
    }
  }

  double? _calculateRemaining() {
    if (_budgetValue == null || widget.averageExpenses == null) {
      return null;
    }
    return _budgetValue! - widget.averageExpenses!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _calculateRemaining();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Presupuesto Mensual',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AmountTextField(
                initialValue: _budget,
                onChanged: (value) {
                  setState(() {
                    _budget = value;
                  });
                },
                onAmountChanged: (value) {
                  setState(() {
                    _budgetValue = value;
                  });
                },
                currencySymbol: 'S/',
              ),
              if (remaining != null && widget.averageExpenses != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: remaining >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: remaining >= 0
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proyección Mensual',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gasto promedio:',
                            style: theme.textTheme.bodyMedium,
                          ),
                          CurrencyTextWidget(
                            amount: widget.averageExpenses!,
                            currencySymbol: 'S/',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Disponible:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CurrencyTextWidget(
                            amount: remaining,
                            currencySymbol: 'S/',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: remaining >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _budgetValue != null && _budgetValue! > 0
                          ? _handleSave
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

