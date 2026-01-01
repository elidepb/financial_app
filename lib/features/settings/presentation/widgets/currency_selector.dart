import 'package:flutter/material.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';

class Currency {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });
}

class CurrencySelector extends StatefulWidget {
  final String? selectedCurrencyCode;
  final Function(String) onCurrencySelected;

  const CurrencySelector({
    super.key,
    this.selectedCurrencyCode,
    required this.onCurrencySelected,
  });

  static Future<void> show(
    BuildContext context, {
    String? selectedCurrencyCode,
    required Function(String) onCurrencySelected,
  }) {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => CurrencySelector(
          selectedCurrencyCode: selectedCurrencyCode,
          onCurrencySelected: onCurrencySelected,
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: CurrencySelector(
              selectedCurrencyCode: selectedCurrencyCode,
              onCurrencySelected: onCurrencySelected,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Currency> _popularCurrencies = [
    Currency(code: 'PEN', symbol: 'S/', name: 'Sol Peruano', flag: '🇵🇪'),
    Currency(code: 'USD', symbol: '\$', name: 'Dólar Estadounidense', flag: '🇺🇸'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
  ];

  final List<Currency> _allCurrencies = [
    Currency(code: 'PEN', symbol: 'S/', name: 'Sol Peruano', flag: '🇵🇪'),
    Currency(code: 'USD', symbol: '\$', name: 'Dólar Estadounidense', flag: '🇺🇸'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    Currency(code: 'GBP', symbol: '£', name: 'Libra Esterlina', flag: '🇬🇧'),
    Currency(code: 'JPY', symbol: '¥', name: 'Yen Japonés', flag: '🇯🇵'),
    Currency(code: 'CAD', symbol: 'C\$', name: 'Dólar Canadiense', flag: '🇨🇦'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Dólar Australiano', flag: '🇦🇺'),
    Currency(code: 'CHF', symbol: 'CHF', name: 'Franco Suizo', flag: '🇨🇭'),
    Currency(code: 'CNY', symbol: '¥', name: 'Yuan Chino', flag: '🇨🇳'),
    Currency(code: 'BRL', symbol: 'R\$', name: 'Real Brasileño', flag: '🇧🇷'),
    Currency(code: 'MXN', symbol: '\$', name: 'Peso Mexicano', flag: '🇲🇽'),
    Currency(code: 'ARS', symbol: '\$', name: 'Peso Argentino', flag: '🇦🇷'),
  ];

  List<Currency> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return _allCurrencies;
    }
    return _allCurrencies
        .where((currency) =>
            currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            currency.code.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.currency_exchange,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Seleccionar Moneda',
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
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar moneda...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        if (_searchQuery.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Populares',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._popularCurrencies.map((currency) => _buildCurrencyTile(
                currency,
                theme,
                isPopular: true,
              )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Todas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredCurrencies.length,
            itemBuilder: (context, index) {
              final currency = _filteredCurrencies[index];
              return _buildCurrencyTile(currency, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyTile(
    Currency currency,
    ThemeData theme, {
    bool isPopular = false,
  }) {
    final isSelected = widget.selectedCurrencyCode == currency.code;

    return RadioListTile<String>(
      value: currency.code,
      groupValue: widget.selectedCurrencyCode,
      onChanged: (value) {
        widget.onCurrencySelected(currency.code);
        Navigator.of(context).pop();
      },
      title: Row(
        children: [
          Text(
            currency.flag,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  currency.code,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            currency.symbol,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }
}

