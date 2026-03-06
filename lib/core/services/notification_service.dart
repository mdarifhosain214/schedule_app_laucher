/// Notification service stub.
/// Notifications are now handled natively by [AppLaunchReceiver] in Kotlin,
/// so this Dart-side service is no longer used.
class NotificationService {
  NotificationService._();

  static Future<void> initialize() async {
    // No-op: notifications are handled on the native Android side.
  }
}
