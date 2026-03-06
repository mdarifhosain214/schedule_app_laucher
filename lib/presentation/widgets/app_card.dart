import 'dart:typed_data';
import 'package:flutter/material.dart';

/// A card widget that displays an installed app's icon and name
/// in the app discovery grid.
class AppCard extends StatelessWidget {
  final String appName;
  final String packageName;
  final Uint8List? icon;
  final VoidCallback onTap;

  const AppCard({
    super.key,
    required this.appName,
    required this.packageName,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: icon != null
                      ? Image.memory(
                          icon!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _defaultIcon(theme),
                        )
                      : _defaultIcon(theme),
                ),
              ),
              const SizedBox(height: 6),
              // App name
              Flexible(
                child: Text(
                  appName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 2),
              // Package name
              Text(
                packageName.length > 25
                    ? '${packageName.substring(0, 22)}...'
                    : packageName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.2),
      child: Icon(
        Icons.apps_rounded,
        size: 28,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
