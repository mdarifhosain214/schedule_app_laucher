import 'package:flutter/material.dart';
import '../../domain/entities/schedule.dart';

/// A warning banner shown when a scheduling time conflict is detected.
class ConflictWarning extends StatelessWidget {
  final Schedule conflictingSchedule;

  const ConflictWarning({
    super.key,
    required this.conflictingSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade300,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Conflict Detected!',
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${conflictingSchedule.appName}" is already scheduled at this time.',
                  style: TextStyle(
                    color: Colors.amber.shade200.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
