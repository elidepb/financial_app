import 'package:flutter/material.dart';

enum SettingsTileType {
  navigation,
  toggle,
  selection,
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final SettingsTileType type;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Widget? trailing;
  final Color? backgroundColor;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingIconColor,
    required this.type,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.trailing,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: type == SettingsTileType.toggle ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Row(
            children: [
              if (leadingIcon != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (leadingIconColor ?? theme.colorScheme.primary)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: leadingIconColor ?? theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              if (leadingIcon != null) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (type == SettingsTileType.navigation) ...[
                if (trailing != null) trailing!,
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey[400],
                ),
              ] else if (type == SettingsTileType.toggle) ...[
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 8),
                ],
                Switch(
                  value: switchValue ?? false,
                  onChanged: onSwitchChanged,
                ),
              ] else if (type == SettingsTileType.selection) ...[
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey[400],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

