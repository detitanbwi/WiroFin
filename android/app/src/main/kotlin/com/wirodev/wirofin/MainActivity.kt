package com.wirodev.wirofin

import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.wirodev.wirofin/auto_track"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkNotificationPermission" -> {
                    val isEnabled = isNotificationServiceEnabled()
                    result.success(isEnabled)
                }
                "openNotificationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Could not open notification listener settings", e.message)
                    }
                }
                "showLocalNotification" -> {
                    val title = call.argument<String>("title") ?: "WiroFin"
                    val message = call.argument<String>("message") ?: ""
                    showNotification(title, message)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Set up notification callback
        WiroFinNotificationListener.setCallback(object : WiroFinNotificationListener.NotificationCallback {
            override fun onNotificationReceived(packageName: String, title: String, text: String) {
                runOnUiThread {
                    val data = mapOf(
                        "package" to packageName,
                        "title" to title,
                        "text" to text
                    )
                    channel.invokeMethod("onNotification", data)
                }
            }
        })
    }

    override fun onDestroy() {
        WiroFinNotificationListener.setCallback(null)
        super.onDestroy()
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val cn = android.content.ComponentName(this, WiroFinNotificationListener::class.java)
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return flat != null && flat.contains(cn.flattenToString())
    }

    private fun showNotification(title: String, message: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "wirofin_transactions"
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "WiroFin Transactions",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for tracked transactions"
            }
            notificationManager.createNotificationChannel(channel)
        }

        val iconId = resources.getIdentifier("ic_launcher", "mipmap", packageName)
        val smallIcon = if (iconId != 0) iconId else android.R.drawable.ic_dialog_info

        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(smallIcon)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)

        notificationManager.notify(System.currentTimeMillis().toInt(), builder.build())
    }
}
