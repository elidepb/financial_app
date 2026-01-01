import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/core/theme/app_theme.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system);

  void setTheme(AppThemeMode mode) {
    state = mode;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  
  if (themeMode == AppThemeMode.light) {
    return AppTheme.lightTheme;
  } else if (themeMode == AppThemeMode.dark) {
    return AppTheme.darkTheme;
  } else {
    return brightness == Brightness.dark 
        ? AppTheme.darkTheme 
        : AppTheme.lightTheme;
  }
});

