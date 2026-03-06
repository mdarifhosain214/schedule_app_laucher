package com.example.open_exist_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * BroadcastReceiver that fires on BOOT_COMPLETED.
 * Reschedules all active future alarms from the SQLite database.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
        private const val DB_NAME = "app_scheduler.db"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        Log.d(TAG, "Boot completed — rescheduling active alarms")

        try {
            val dbFile = File(context.getDatabasePath(DB_NAME).parent, DB_NAME)
            if (!dbFile.exists()) {
                Log.d(TAG, "Database does not exist yet, nothing to reschedule")
                return
            }

            val db = SQLiteDatabase.openDatabase(
                dbFile.absolutePath, null, SQLiteDatabase.OPEN_READONLY
            )

            val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
            val nowStr = isoFormat.format(Date())

            // Query all active schedules in the future
            val cursor = db.rawQuery(
                """
                SELECT id, package_name, app_name, scheduled_date_time
                FROM schedules
                WHERE is_active = 1 AND scheduled_date_time > ?
                """.trimIndent(),
                arrayOf(nowStr)
            )

            var count = 0
            cursor.use {
                while (it.moveToNext()) {
                    val scheduleId = it.getInt(it.getColumnIndexOrThrow("id"))
                    val packageName = it.getString(it.getColumnIndexOrThrow("package_name"))
                    val appName = it.getString(it.getColumnIndexOrThrow("app_name"))
                    val dateTimeStr = it.getString(it.getColumnIndexOrThrow("scheduled_date_time"))

                    try {
                        val dateTime = isoFormat.parse(dateTimeStr)
                        if (dateTime != null && dateTime.time > System.currentTimeMillis()) {
                            NativeAlarmScheduler.scheduleExactAlarm(
                                context, scheduleId, dateTime.time, packageName, appName
                            )
                            count++
                            Log.d(TAG, "Rescheduled: id=$scheduleId, app=$appName")
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to reschedule id=$scheduleId: ${e.message}")
                    }
                }
            }

            db.close()
            Log.d(TAG, "Rescheduled $count alarms after boot")
        } catch (e: Exception) {
            Log.e(TAG, "Error rescheduling alarms: ${e.message}")
        }
    }
}
