import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_gestor_financiero/features/movements/domain/entities/movement_type.dart';

class TypeToggle extends StatefulWidget {
  final MovementType initialType;
  final ValueChanged<MovementType> onTypeChanged;

  const TypeToggle({
    super.key,
    required this.initialType,
    required this.onTypeChanged,
  });

  @override
  State<TypeToggle> createState() => _TypeToggleState();
}

class _TypeToggleState extends State<TypeToggle>
    with SingleTickerProviderStateMixin {
  late MovementType _selectedType;
  late AnimationController _controller;
  late Animation<Alignment> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Alignment>(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_selectedType == MovementType.income) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(MovementType type) {
    if (_selectedType != type) {
      setState(() {
        _selectedType = type;
      });
      HapticFeedback.lightImpact();
      if (type == MovementType.expense) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      widget.onTypeChanged(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Align(
                alignment: _slideAnimation.value,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _selectedType == MovementType.expense
                          ? [
                              Colors.red.withOpacity(0.3),
                              Colors.red.withOpacity(0.2),
                            ]
                          : [
                              Colors.green.withOpacity(0.3),
                              Colors.green.withOpacity(0.2),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (_selectedType == MovementType.expense
                                ? Colors.red
                                : Colors.green)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(MovementType.expense),
                  child: _buildTypeOption(
                    'Gasto',
                    Icons.arrow_downward_rounded,
                    MovementType.expense,
                    Colors.red,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(MovementType.income),
                  child: _buildTypeOption(
                    'Ingreso',
                    Icons.arrow_upward_rounded,
                    MovementType.income,
                    Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    IconData icon,
    MovementType type,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return AnimatedRotation(
      duration: const Duration(milliseconds: 200),
      turns: isSelected ? 0 : 0.5,
      child: Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : Colors.white.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

