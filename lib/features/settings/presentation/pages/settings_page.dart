import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/features/settings/presentation/widgets/settings_section.dart';
import 'package:app_gestor_financiero/features/settings/presentation/widgets/settings_tile.dart';
import 'package:app_gestor_financiero/features/settings/presentation/widgets/budget_input_dialog.dart';
import 'package:app_gestor_financiero/features/settings/presentation/widgets/currency_selector.dart';
import 'package:app_gestor_financiero/features/settings/presentation/widgets/theme_toggle.dart';
import 'package:app_gestor_financiero/features/settings/presentation/widgets/danger_zone_card.dart';
import 'package:app_gestor_financiero/features/categories/presentation/pages/categories_page.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  static void show(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <
        AppDimensions.breakpointMobile;

    if (isMobile) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: const SettingsPage(),
          ),
        ),
      );
    }
  }

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  double? _monthlyBudget;
  String _currencyCode = 'PEN';
  double? _averageExpenses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: 'Presupuesto',
            children: [
              SettingsTile(
                title: 'Presupuesto Mensual',
                subtitle: _monthlyBudget != null
                    ? 'S/ ${_monthlyBudget!.toStringAsFixed(2)}'
                    : 'No establecido',
                leadingIcon: Icons.account_balance_wallet,
                leadingIconColor: Colors.blue,
                type: SettingsTileType.selection,
                onTap: () {
                  BudgetInputDialog.show(
                    context,
                    currentBudget: _monthlyBudget,
                    averageExpenses: _averageExpenses,
                    onSave: (budget) {
                      setState(() {
                        _monthlyBudget = budget;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          SettingsSection(
            title: 'Apariencia',
            children: [
              const ThemeToggle(),
              const SizedBox(height: 16),
              SettingsTile(
                title: 'Moneda',
                subtitle: _getCurrencyName(_currencyCode),
                leadingIcon: Icons.currency_exchange,
                leadingIconColor: Colors.green,
                type: SettingsTileType.selection,
                trailing: Text(
                  _getCurrencySymbol(_currencyCode),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onTap: () {
                  CurrencySelector.show(
                    context,
                    selectedCurrencyCode: _currencyCode,
                    onCurrencySelected: (code) {
                      setState(() {
                        _currencyCode = code;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          SettingsSection(
            title: 'Gestión',
            children: [
              SettingsTile(
                title: 'Categorías',
                subtitle: 'Gestionar categorías personalizadas',
                leadingIcon: Icons.category,
                leadingIconColor: Colors.purple,
                type: SettingsTileType.navigation,
                onTap: () {
                  CategoriesPage.show(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          SettingsSection(
            title: 'Respaldo',
            children: [
              SettingsTile(
                title: 'Hacer Respaldo',
                subtitle: 'Exportar todos tus datos',
                leadingIcon: Icons.backup,
                leadingIconColor: Colors.orange,
                type: SettingsTileType.navigation,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de respaldo en desarrollo')),
                  );
                },
              ),
              SettingsTile(
                title: 'Restaurar Datos',
                subtitle: 'Importar datos desde respaldo',
                leadingIcon: Icons.restore,
                leadingIconColor: Colors.teal,
                type: SettingsTileType.navigation,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de restauración en desarrollo')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          SettingsSection(
            title: 'Peligro',
            children: [
              DangerZoneCard(
                onClearAllData: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de limpieza en desarrollo')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'PEN':
        return 'S/';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return code;
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'PEN':
        return 'Sol Peruano';
      case 'USD':
        return 'Dólar Estadounidense';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'Libra Esterlina';
      default:
        return code;
    }
  }
}

