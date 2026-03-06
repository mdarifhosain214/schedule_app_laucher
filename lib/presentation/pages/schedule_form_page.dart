import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/schedule.dart';
import '../providers/app_providers.dart';
import '../widgets/conflict_warning.dart';

/// Form page for creating or editing a schedule.
class ScheduleFormPage extends ConsumerStatefulWidget {
  /// If editing an existing schedule, pass it here.
  final Schedule? existingSchedule;

  /// If creating a new schedule, pass the selected app here.
  final AppInfo? selectedApp;

  const ScheduleFormPage({
    super.key,
    this.existingSchedule,
    this.selectedApp,
  });

  @override
  ConsumerState<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends ConsumerState<ScheduleFormPage> {
  late TextEditingController _labelController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  Schedule? _conflictingSchedule;
  bool _isChecking = false;
  bool _isSaving = false;

  bool get _isEditing => widget.existingSchedule != null;

  String get _appName =>
      widget.existingSchedule?.appName ?? widget.selectedApp?.appName ?? '';
  String get _packageName =>
      widget.existingSchedule?.packageName ??
      widget.selectedApp?.packageName ??
      '';

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.existingSchedule?.label ?? '',
    );

    if (_isEditing) {
      final dt = widget.existingSchedule!.scheduledDateTime;
      _selectedDate = DateTime(dt.year, dt.month, dt.day);
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    } else {
      final now = DateTime.now().add(const Duration(hours: 1));
      _selectedDate = DateTime(now.year, now.month, now.day);
      _selectedTime = TimeOfDay(hour: now.hour, minute: 0);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Schedule' : 'New Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── App info card ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: (widget.existingSchedule?.appIcon != null ||
                              widget.selectedApp?.icon != null)
                          ? Image.memory(
                              widget.existingSchedule?.appIcon ??
                                  widget.selectedApp!.icon!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              child: Icon(
                                Icons.apps_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _packageName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Label field ───
            Text(
              'Label (Optional)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: 'e.g., Daily Standup',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 28),

            // ─── Date & Time ───
            Text(
              'Date & Time',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateTimePicker(
                    icon: Icons.calendar_month_rounded,
                    label: DateTimeUtils.formatDate(_selectedDate),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTimePicker(
                    icon: Icons.access_time_rounded,
                    label: DateTimeUtils.formatTimeOfDay(
                      _selectedTime.hour,
                      _selectedTime.minute,
                    ),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Conflict warning ───
            if (_isChecking)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (_conflictingSchedule != null)
              ConflictWarning(conflictingSchedule: _conflictingSchedule!),

            // ─── Future time validation ───
            if (!DateTimeUtils.isFuture(_combinedDateTime))
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please select a future date and time.',
                        style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 36),

            // ─── Action buttons ───
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        (_isSaving || _conflictingSchedule != null || !DateTimeUtils.isFuture(_combinedDateTime))
                            ? null
                            : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Update' : 'Save Schedule'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _checkConflict();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _checkConflict();
    }
  }

  Future<void> _checkConflict() async {
    setState(() {
      _isChecking = true;
      _conflictingSchedule = null;
    });

    try {
      final repo = ref.read(scheduleRepositoryProvider);
      final conflict = await repo.findConflict(
        _combinedDateTime,
        excludeId: widget.existingSchedule?.id,
      );
      if (mounted) {
        setState(() {
          _conflictingSchedule = conflict;
          _isChecking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final schedule = Schedule(
        id: widget.existingSchedule?.id,
        appName: _appName,
        packageName: _packageName,
        appIcon: widget.existingSchedule?.appIcon ?? widget.selectedApp?.icon,
        label: _labelController.text.trim().isEmpty
            ? null
            : _labelController.text.trim(),
        scheduledDateTime: _combinedDateTime,
        isActive: true,
        createdAt: widget.existingSchedule?.createdAt ?? DateTime.now(),
      );

      final notifier = ref.read(schedulesProvider.notifier);
      final result = _isEditing
          ? await notifier.updateSchedule(schedule)
          : await notifier.createSchedule(schedule);

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Schedule updated successfully!'
                  : 'Schedule created successfully!',
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _conflictingSchedule = result.conflictingSchedule;
          _isSaving = false;
        });
        if (result.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

/// Reusable date/time picker tile widget.
class _DateTimePicker extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateTimePicker({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
