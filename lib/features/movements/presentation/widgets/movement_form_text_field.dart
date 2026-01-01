import 'package:flutter/material.dart';

class MovementFormTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool isRequired;

  const MovementFormTextField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.maxLines,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: const TextStyle(
        color: Color(0xFFE0E6ED),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFFB0B8C4),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF8A92A0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF3A3F4E),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF3A3F4E),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF7E57C2),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      validator: validator ?? (isRequired 
        ? (value) {
            if (value == null || value.isEmpty) {
              return '$label es obligatorio';
            }
            return null;
          }
        : null),
      maxLines: maxLines ?? 1,
    );
  }
}

