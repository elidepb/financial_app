import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_gestor_financiero/core/theme/theme_provider.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema de la Aplicación',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<AppThemeMode>(
          segments: const [
            ButtonSegment(
              value: AppThemeMode.light,
              label: Text('☀️ Claro'),
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment(
              value: AppThemeMode.dark,
              label: Text('🌙 Oscuro'),
              icon: Icon(Icons.dark_mode),
            ),
            ButtonSegment(
              value: AppThemeMode.system,
              label: Text('🔄 Sistema'),
              icon: Icon(Icons.brightness_auto),
            ),
          ],
          selected: {currentTheme},
          onSelectionChanged: (Set<AppThemeMode> newSelection) {
            themeNotifier.setTheme(newSelection.first);
          },
          multiSelectionEnabled: false,
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            selectedForegroundColor: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              _ColorPreview(
                color: theme.colorScheme.primary,
                label: 'Primary',
              ),
              const SizedBox(width: 12),
              _ColorPreview(
                color: theme.colorScheme.secondary,
                label: 'Secondary',
              ),
              const SizedBox(width: 12),
              _ColorPreview(
                color: theme.colorScheme.error,
                label: 'Error',
              ),
              const Spacer(),
              Icon(
                theme.brightness == Brightness.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorPreview extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorPreview({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

