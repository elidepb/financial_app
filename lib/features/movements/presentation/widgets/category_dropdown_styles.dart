import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CategoryDropdownStyles {
  static InputDecoration getInputDecoration() {
    return InputDecoration(
      labelText: 'Categoría',
      labelStyle: const TextStyle(
        color: Color(0xFFB0B8C4),
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
    );
  }

  static InputDecoration getSearchDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      hintText: 'Buscar categoría...',
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF8A92A0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3A3F4E),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3A3F4E),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF7E57C2),
        ),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
    );
  }

  static BoxDecoration getDropdownDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFF1A1F2E),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  static const ButtonStyleData buttonStyle = ButtonStyleData(
    padding: EdgeInsets.symmetric(horizontal: 16),
    height: 60,
  );

  static const IconStyleData iconStyle = IconStyleData(
    icon: Icon(Icons.arrow_drop_down),
    iconSize: 24,
    iconEnabledColor: Color(0xFF7E57C2),
  );

  static const MenuItemStyleData menuItemStyle = MenuItemStyleData(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    height: 56,
  );

  static DropdownStyleData getDropdownStyle() {
    return DropdownStyleData(
      maxHeight: 300,
      decoration: getDropdownDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}

