import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/widgets/glass_container.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';

enum DateRange {
  threeMonths,
  sixMonths,
  oneYear,
  custom,
}

class DateRangeSelector extends StatefulWidget {
  final DateRange selectedRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final ValueChanged<DateRange> onRangeChanged;
  final ValueChanged<DateTimeRange?>? onCustomRangeChanged;

  const DateRangeSelector({
    super.key,
    required this.selectedRange,
    this.customStartDate,
    this.customEndDate,
    required this.onRangeChanged,
    this.onCustomRangeChanged,
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  late DateRange _selectedRange;
  bool _showCustomPicker = false;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.selectedRange;
    _showCustomPicker = widget.selectedRange == DateRange.custom;
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rango de Fechas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildChip('3M', DateRange.threeMonths),
              _buildChip('6M', DateRange.sixMonths),
              _buildChip('1A', DateRange.oneYear),
              _buildChip('Personalizado', DateRange.custom),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuart,
            height: _showCustomPicker ? 100 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showCustomPicker ? 1.0 : 0.0,
              curve: Curves.easeIn,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        'Desde',
                        widget.customStartDate,
                        (date) {
                          if (widget.onCustomRangeChanged != null) {
                            widget.onCustomRangeChanged!(
                              DateTimeRange(
                                start: date,
                                end: widget.customEndDate ?? date,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        'Hasta',
                        widget.customEndDate,
                        (date) {
                          if (widget.onCustomRangeChanged != null) {
                            widget.onCustomRangeChanged!(
                              DateTimeRange(
                                start: widget.customStartDate ?? date,
                                end: date,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, DateRange range) {
    final isSelected = _selectedRange == range;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppDimensions.breakpointMobile;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedRange = range;
                  _showCustomPicker = range == DateRange.custom;
                });
                widget.onRangeChanged(range);
              }
            },
            selectedColor: const Color(0xFF7E57C2),
            backgroundColor: isDesktop 
                ? const Color(0xFF1E293B).withOpacity(0.6)  // Fondo oscuro en desktop
                : const Color(0xFF1E293B).withOpacity(0.4),  // Fondo oscuro también en móvil
            labelStyle: TextStyle(
              color: Colors.white,  // Texto blanco siempre legible
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF7E57C2)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField(
      String label, DateTime? date, ValueChanged<DateTime> onDateSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF7E57C2),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E2C),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: const Color(0xFF1E1E2C),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                  : '--/--/----',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}