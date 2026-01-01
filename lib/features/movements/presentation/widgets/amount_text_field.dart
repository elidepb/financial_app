import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountTextField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<double?>? onAmountChanged;
  final String? currencySymbol;
  final String? Function(String?)? validator;

  const AmountTextField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.onAmountChanged,
    this.currencySymbol,
    this.validator,
  });

  @override
  State<AmountTextField> createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<AmountTextField>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _validateAndFormat(String value) {
    final formatted = _formatAmount(value);
    if (_controller.text != formatted) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    final amount = _parseAmount(formatted);
    widget.onChanged(formatted);
    widget.onAmountChanged?.call(amount);

    if (amount != null && amount <= 0) {
      setState(() => _hasError = true);
      _shakeController.forward(from: 0).then((_) {
        _shakeController.reverse();
      });
    } else {
      setState(() => _hasError = false);
    }
  }

  String _formatAmount(String value) {
    if (value.isEmpty) return '';

    String digitsOnly = value.replaceAll(RegExp(r'[^\d.]'), '');

    if (digitsOnly.split('.').length > 2) {
      digitsOnly = digitsOnly.split('.').first +
          '.' +
          digitsOnly.split('.').sublist(1).join();
    }

    String decimalPart = '';
    String integerPart = digitsOnly;
    
    if (digitsOnly.contains('.')) {
      final parts = digitsOnly.split('.');
      integerPart = parts[0];
      decimalPart = parts[1];
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }
    }

    if (integerPart.isEmpty) return decimalPart.isEmpty ? '' : '0.$decimalPart';

    final number = int.tryParse(integerPart) ?? 0;
    final formattedInteger = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return decimalPart.isEmpty 
        ? formattedInteger 
        : '$formattedInteger.$decimalPart';
  }

  double? _parseAmount(String value) {
    if (value.isEmpty) return null;
    final cleanValue = value.replaceAll(',', '');
    return double.tryParse(cleanValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = widget.currencySymbol ?? 'S/';

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_hasError ? _shakeAnimation.value : 0, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: _hasError
                            ? Colors.red.withOpacity(0.3)
                            : theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE0E6ED),
              ),
              decoration: InputDecoration(
                labelText: 'Monto',
                labelStyle: TextStyle(
                  color: const Color(0xFFB0B8C4),
                ),
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: const Color(0xFF8A92A0),
                ),
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      currencySymbol,
                      key: ValueKey(currencySymbol),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7E57C2),
                      ),
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _hasError
                        ? Colors.red
                        : const Color(0xFF3A3F4E),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _hasError
                        ? Colors.red
                        : const Color(0xFF3A3F4E),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _hasError
                        ? Colors.red
                        : const Color(0xFF7E57C2),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                errorText: _hasError ? 'El monto debe ser mayor a 0' : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
              onChanged: _validateAndFormat,
              validator: widget.validator ?? (value) {
                if (value == null || value.isEmpty) {
                  return 'El monto es obligatorio';
                }
                final amount = _parseAmount(value);
                if (amount == null || amount <= 0) {
                  return 'El monto debe ser mayor a 0';
                }
                return null;
              },
            ),
          ),
        );
      },
    );
  }
}

