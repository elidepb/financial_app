import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_gestor_financiero/core/constants/app_dimensions.dart';
import 'package:app_gestor_financiero/core/router/route_paths.dart';
import 'package:app_gestor_financiero/core/widgets/custom_bottom_nav.dart';
import 'package:app_gestor_financiero/features/settings/presentation/pages/settings_page.dart';
import 'package:app_gestor_financiero/features/categories/presentation/pages/categories_page.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showNavigation;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppDimensions.breakpointMobile;
        
        if (isMobile) {
          return _MobileScaffold(
            body: body,
            title: title,
            actions: actions,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            showNavigation: showNavigation,
          );
        } else {
          return _DesktopScaffold(
            body: body,
            title: title,
            actions: actions,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            showNavigation: showNavigation,
          );
        }
      },
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showNavigation;

  const _MobileScaffold({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: [
                if (actions != null) ...actions!,
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    SettingsPage.show(context);
                  },
                  tooltip: 'Configuración',
                ),
              ],
            )
          : null,
      drawer: _buildDrawer(context),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: showNavigation ? const CustomBottomNavigationBar() : null,
    );
  }

  Widget? _buildDrawer(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  'Gestor Financiero',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: currentLocation == RoutePaths.dashboard,
            onTap: () {
              context.go(RoutePaths.dashboard);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Movimientos'),
            selected: currentLocation == RoutePaths.expenses,
            onTap: () {
              context.go(RoutePaths.expenses);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Estadísticas'),
            selected: currentLocation == RoutePaths.statistics,
            onTap: () {
              context.go(RoutePaths.statistics);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () {
              Navigator.pop(context);
              CategoriesPage.show(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              SettingsPage.show(context);
            },
          ),
        ],
      ),
    );
  }
}

class _DesktopScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showNavigation;

  const _DesktopScaffold({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: [
                if (actions != null) ...actions!,
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    SettingsPage.show(context);
                  },
                  tooltip: 'Configuración',
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (showNavigation)
            NavigationRail(
              extended: MediaQuery.of(context).size.width >= AppDimensions.breakpointDesktop,
              selectedIndex: _getSelectedIndex(currentLocation),
              onDestinationSelected: (index) {
                _navigateToRoute(context, index);
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('Movimientos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Estadísticas'),
                ),
              ],
            ),
          Expanded(
            child: body,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  int _getSelectedIndex(String location) {
    if (location == RoutePaths.dashboard) return 0;
    if (location == RoutePaths.expenses) return 1;
    if (location == RoutePaths.statistics) return 2;
    return 0;
  }

  void _navigateToRoute(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RoutePaths.dashboard);
        break;
      case 1:
        context.go(RoutePaths.expenses);
        break;
      case 2:
        context.go(RoutePaths.statistics);
        break;
    }
  }
}

