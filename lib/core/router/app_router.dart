import 'package:go_router/go_router.dart';
import 'package:app_gestor_financiero/core/router/route_paths.dart';
import 'package:app_gestor_financiero/core/router/deep_link_config.dart';
import 'package:app_gestor_financiero/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:app_gestor_financiero/features/movements/presentation/pages/movements_page.dart';
import 'package:app_gestor_financiero/features/statistics/presentation/pages/statistics_page.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.dashboard,
  routes: [
    GoRoute(
      path: RoutePaths.dashboard,
      name: RoutePaths.routeNameDashboard,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const DashboardPage(),
      ),
    ),
    GoRoute(
      path: RoutePaths.expenses,
      name: RoutePaths.routeNameExpenses,
      pageBuilder: (context, state) {
        final movementId = state.uri.queryParameters['id'];
        final filters = Map<String, String>.from(state.uri.queryParameters);
        return NoTransitionPage(
          key: state.pageKey,
          child: MovementsPage(
            highlightMovementId: movementId,
            filters: filters,
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.statistics,
      name: RoutePaths.routeNameStatistics,
      pageBuilder: (context, state) {
        final categoryId = state.uri.queryParameters['category'];
        return NoTransitionPage(
          key: state.pageKey,
          child: StatisticsPage(categoryFilter: categoryId),
        );
      },
    ),
  ],
  redirect: (context, state) {
    final location = state.matchedLocation;
    final uri = state.uri;
    
    if (uri.scheme == DeepLinkConfig.scheme) {
      final mappedRoute = DeepLinkConfig.mapDeepLinkToRoute(uri.toString());
      if (mappedRoute != null) {
        return mappedRoute;
      }
    }
    
    final path = location.split('?').first;
    if (location.isEmpty || 
        !location.startsWith('/') ||
        ![
          RoutePaths.dashboard,
          RoutePaths.expenses,
          RoutePaths.statistics,
        ].contains(path)) {
      return RoutePaths.dashboard;
    }
    
    return null;
  },
);

