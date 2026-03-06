import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/utils/date_time_utils.dart';

/// A card widget displaying a scheduled app with info, time, countdown,
/// and edit/delete actions.
class ScheduleCard extends StatelessWidget {
  final int id;
  final String appName;
  final String packageName;
  final Uint8List? appIcon;
  final String? label;
  final DateTime scheduledDateTime;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const ScheduleCard({
    super.key,
    required this.id,
    required this.appName,
    required this.packageName,
    this.appIcon,
    this.label,
    required this.scheduledDateTime,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPast = scheduledDateTime.isBefore(DateTime.now());
    final relTime = DateTimeUtils.relativeTime(scheduledDateTime);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardTheme.color ?? const Color(0xFF16213E),
              (theme.cardTheme.color ?? const Color(0xFF16213E))
                  .withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: app icon + name + toggle
                Row(
                  children: [
                    // App icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: appIcon != null
                            ? Image.memory(appIcon!, fit: BoxFit.cover)
                            : Container(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.apps_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // App name + label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (label != null && label!.isNotEmpty)
                            Text(
                              label!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // Toggle switch
                    Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: isActive,
                        onChanged: (_) => onToggle(),
                        activeTrackColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Time info row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: isPast
                            ? Colors.redAccent
                            : theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${DateTimeUtils.friendlyDate(scheduledDateTime)}, ${DateTimeUtils.formatTime(scheduledDateTime)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isPast
                              ? Colors.redAccent.withValues(alpha: 0.15)
                              : theme.colorScheme.secondary
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          relTime,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isPast
                                ? Colors.redAccent
                                : theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent.withValues(alpha: 0.8),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
