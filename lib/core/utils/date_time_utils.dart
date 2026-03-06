import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatTimeOfDay(int hour, int minute) {
    final dt = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(dt);
  }

  /// Returns a human‑readable relative time string.
  static String relativeTime(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);

    if (diff.isNegative) {
      return 'Past due';
    }

    if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      return 'In ${diff.inDays}d ${hours}h';
    }

    if (diff.inHours > 0) {
      final minutes = diff.inMinutes % 60;
      return 'In ${diff.inHours}h ${minutes}m';
    }

    if (diff.inMinutes > 0) {
      return 'In ${diff.inMinutes}m';
    }

    return 'Less than a minute';
  }

  /// Check if two DateTimes are within the same minute.
  static bool isConflicting(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  /// Returns true if [dateTime] is in the future.
  static bool isFuture(DateTime dateTime) {
    return dateTime.isAfter(DateTime.now());
  }

  /// Returns a friendly label like "Today", "Tomorrow", or the formatted date.
  static String friendlyDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return formatDate(dateTime);
  }
}
