package com.example.open_exist_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Utility class that wraps Android's AlarmManager for scheduling exact alarms.
 * Each alarm fires [AppLaunchReceiver] with schedule data in the intent extras.
 */
object NativeAlarmScheduler {

    private const val REQUEST_CODE_OFFSET = 2000

    fun scheduleExactAlarm(
        context: Context,
        scheduleId: Int,
        dateTimeMillis: Long,
        packageName: String,
        appName: String
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AppLaunchReceiver::class.java).apply {
            action = "com.example.open_exist_app.LAUNCH_APP"
            putExtra("scheduleId", scheduleId)
            putExtra("packageName", packageName)
            putExtra("appName", appName)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_OFFSET + scheduleId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Intent to show when user taps the alarm icon (required by AlarmClockInfo)
        val showIntent = Intent(context, MainActivity::class.java)
        val showPendingIntent = PendingIntent.getActivity(
            context,
            REQUEST_CODE_OFFSET + scheduleId,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmClockInfo = AlarmManager.AlarmClockInfo(dateTimeMillis, showPendingIntent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+ — check if we can schedule exact alarms
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            } else {
                // Fallback: use setAndAllowWhileIdle (less precise but works)
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    dateTimeMillis,
                    pendingIntent
                )
            }
        } else {
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
        }
    }

    fun cancelAlarm(context: Context, scheduleId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AppLaunchReceiver::class.java).apply {
            action = "com.example.open_exist_app.LAUNCH_APP"
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_OFFSET + scheduleId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }
}
