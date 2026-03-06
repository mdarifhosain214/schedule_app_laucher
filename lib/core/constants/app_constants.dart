class AppConstants {
  AppConstants._();

  // Database
  static const String dbName = 'app_scheduler.db';
  static const int dbVersion = 1;
  static const String schedulesTable = 'schedules';
  static const String historyTable = 'schedule_history';

  // Platform Channel
  static const String platformChannel = 'com.example.open_exist_app/app_launcher';

  // Notification
  static const String notificationChannelId = 'app_scheduler_channel';
  static const String notificationChannelName = 'App Scheduler';
  static const String notificationChannelDesc = 'Notifications for scheduled app launches';

  // Alarm
  static const int alarmIdOffset = 1000;
}
