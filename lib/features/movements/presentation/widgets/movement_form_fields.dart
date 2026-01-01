import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/type_toggle.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/amount_text_field.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/category_dropdown.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/date_picker_field.dart';
import 'package:app_gestor_financiero/features/movements/presentation/widgets/movement_form_text_field.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';

export 'package:app_gestor_financiero/features/movements/presentation/widgets/category_dropdown.dart' show CategoryOption;

class MovementFormFields extends StatelessWidget {
  final MovementType type;
  final double? amountValue;
  final String description;
  final String? selectedCategoryId;
  final DateTime selectedDate;
  final String notes;
  final List<CategoryOption> categories;
  final ValueChanged<MovementType> onTypeChanged;
  final ValueChanged<double?> onAmountChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onNotesChanged;

  const MovementFormFields({
    super.key,
    required this.type,
    this.amountValue,
    required this.description,
    this.selectedCategoryId,
    required this.selectedDate,
    required this.notes,
    required this.categories,
    required this.onTypeChanged,
    required this.onAmountChanged,
    required this.onDescriptionChanged,
    required this.onCategoryChanged,
    required this.onDateChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TypeToggle(
          initialType: type,
          onTypeChanged: onTypeChanged,
        ),
        const SizedBox(height: 24),
        AmountTextField(
          initialValue: amountValue != null 
              ? amountValue!.toStringAsFixed(2) 
              : null,
          onChanged: (value) {},
          onAmountChanged: onAmountChanged,
        ),
        const SizedBox(height: 24),
        MovementFormTextField(
          label: 'Descripción',
          initialValue: description,
          onChanged: onDescriptionChanged,
          isRequired: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La descripción es obligatoria';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        CategoryDropdown(
          selectedCategoryId: selectedCategoryId,
          categories: categories,
          movementType: type,
          onCategoryChanged: onCategoryChanged,
        ),
        const SizedBox(height: 24),
        DatePickerField(
          initialDate: selectedDate,
          onDateChanged: onDateChanged,
        ),
        const SizedBox(height: 24),
        MovementFormTextField(
          label: 'Notas (opcional)',
          initialValue: notes,
          onChanged: onNotesChanged,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

