import 'package:app_gestor_financiero/core/router/route_paths.dart';

class DeepLinkConfig {
  DeepLinkConfig._();

  static const String scheme = 'myapp';

  static String? mapDeepLinkToRoute(String deepLink) {
    final uri = Uri.tryParse(deepLink);
    if (uri == null || uri.scheme != scheme) {
      return null;
    }

    final path = uri.path;
    final queryParams = uri.queryParameters;

    if (path == '/dashboard' || path == 'dashboard' || path.isEmpty) {
      return RoutePaths.dashboard;
    }
    
    if (path == '/expenses' || path == 'expenses') {
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        return '${RoutePaths.expenses}?$queryString';
      }
      return RoutePaths.expenses;
    }
    
    if (path.startsWith('/expenses/') || path.startsWith('expenses/')) {
      final parts = path.split('/');
      if (parts.length >= 3) {
        final id = parts.last;
        return '${RoutePaths.expenses}?id=${Uri.encodeComponent(id)}';
      }
    }
    
    if (path == '/statistics' || path == 'statistics') {
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        return '${RoutePaths.statistics}?$queryString';
      }
      return RoutePaths.statistics;
    }

    return null;
  }

  static bool isValidDeepLink(String deepLink) {
    final uri = Uri.tryParse(deepLink);
    if (uri == null || uri.scheme != scheme) {
      return false;
    }

    final path = uri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    if (normalizedPath == '/dashboard' || normalizedPath == '/') {
      return true;
    }

    if (normalizedPath == '/expenses') {
      return true;
    }

    if (normalizedPath.startsWith('/expenses/')) {
      return true;
    }

    if (normalizedPath == '/statistics') {
      return true;
    }

    return false;
  }
}

