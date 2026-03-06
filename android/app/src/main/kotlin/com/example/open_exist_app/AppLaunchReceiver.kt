package com.example.open_exist_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * BroadcastReceiver that fires when a scheduled alarm triggers.
 * Launches the target app using applicationContext (no Activity needed),
 * updates the SQLite database, and shows a notification.
 */
class AppLaunchReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AppLaunchReceiver"
        private const val CHANNEL_ID = "app_scheduler_channel"
        private const val CHANNEL_NAME = "App Scheduler"
        private const val DB_NAME = "app_scheduler.db"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val scheduleId = intent.getIntExtra("scheduleId", -1)
        val packageName = intent.getStringExtra("packageName") ?: return
        val appName = intent.getStringExtra("appName") ?: return

        Log.d(TAG, "Alarm fired for scheduleId=$scheduleId, package=$packageName")

        if (scheduleId == -1) return

        var launched = false

        try {
            // Launch the app using applicationContext (works from background)
            val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
                )
                context.startActivity(launchIntent)
                launched = true
                Log.d(TAG, "Successfully launched $packageName")
            } else {
                Log.e(TAG, "No launch intent found for $packageName")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch $packageName: ${e.message}")
        }

        // Update database: insert history record and deactivate schedule
        try {
            updateDatabase(context, scheduleId, appName, packageName, launched)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update database: ${e.message}")
        }

        // Show notification
        showNotification(context, scheduleId, appName, launched)
    }

    private fun updateDatabase(
        context: Context,
        scheduleId: Int,
        appName: String,
        packageName: String,
        wasSuccessful: Boolean
    ) {
        val dbPath = File(context.getDatabasePath(DB_NAME).parent, DB_NAME).absolutePath
        val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)

        try {
            // Insert history record
            val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
            val now = isoFormat.format(Date())

            val historyValues = ContentValues().apply {
                put("schedule_id", scheduleId)
                put("app_name", appName)
                put("package_name", packageName)
                put("executed_at", now)
                put("was_successful", if (wasSuccessful) 1 else 0)
            }
            db.insert("schedule_history", null, historyValues)

            // Deactivate the schedule (one-shot)
            val scheduleValues = ContentValues().apply {
                put("is_active", 0)
            }
            db.update("schedules", scheduleValues, "id = ?", arrayOf(scheduleId.toString()))

            Log.d(TAG, "Database updated for scheduleId=$scheduleId")
        } finally {
            db.close()
        }
    }

    private fun showNotification(
        context: Context,
        scheduleId: Int,
        appName: String,
        launched: Boolean
    ) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel (required for Android 8+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for scheduled app launches"
            }
            notificationManager.createNotificationChannel(channel)
        }

        val title = if (launched) "App Launched" else "Launch Failed"
        val body = if (launched) {
            "$appName was launched as scheduled."
        } else {
            "Failed to launch $appName. The app may have been uninstalled."
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(scheduleId, notification)
    }
}
