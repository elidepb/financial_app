import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool allowFutureDates;
  final String? Function(String?)? validator;

  const DatePickerField({
    super.key,
    this.initialDate,
    required this.onDateChanged,
    this.allowFutureDates = false,
    this.validator,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late DateTime _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: widget.allowFutureDates
          ? DateTime(2100)
          : DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateChanged(picked);
    }
  }

  void _setQuickDate(Duration duration) {
    final newDate = DateTime.now().add(duration);
    if (!widget.allowFutureDates && newDate.isAfter(DateTime.now())) {
      return;
    }
    setState(() {
      _selectedDate = newDate;
    });
    widget.onDateChanged(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: _dateFormat.format(_selectedDate),
          ),
          style: TextStyle(
            color: const Color(0xFFE0E6ED),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'Fecha',
            labelStyle: TextStyle(
              color: const Color(0xFFB0B8C4),
            ),
            hintStyle: TextStyle(
              color: const Color(0xFF8A92A0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF3A3F4E),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF3A3F4E),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF7E57C2),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: const Color(0xFF7E57C2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onTap: () => _selectDate(context),
          validator: widget.validator ??
              (String? value) {
                if (value == null || value.isEmpty) {
                  return 'La fecha es obligatoria';
                }
                return null;
              },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickDateChip(
              label: 'Hoy',
              onTap: () => _setQuickDate(Duration.zero),
              isSelected: _isSameDay(_selectedDate, DateTime.now()),
            ),
            _QuickDateChip(
              label: 'Ayer',
              onTap: () => _setQuickDate(const Duration(days: -1)),
              isSelected: _isSameDay(_selectedDate,
                  DateTime.now().subtract(const Duration(days: 1))),
            ),
            _QuickDateChip(
              label: 'Hace 1 semana',
              onTap: () => _setQuickDate(const Duration(days: -7)),
              isSelected: _isSameDay(_selectedDate,
                  DateTime.now().subtract(const Duration(days: 7))),
            ),
          ],
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _QuickDateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _QuickDateChip({
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF7E57C2)
            : const Color(0xFF2A2F3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF7E57C2)
              : const Color(0xFF3A3F4E),
          width: 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF7E57C2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFB0B8C4),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

