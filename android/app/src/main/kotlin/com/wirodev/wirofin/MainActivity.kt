package com.wirodev.wirofin

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
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
import android.util.Log

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
                "getInstalledBankingApps" -> {
                    val apps = getInstalledBankingApps()
                    result.success(apps)
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

    private fun getInstalledBankingApps(): List<Map<String, Any>> {
        val whitelist = listOf(
            "com.bca",                      // BCA Mobile
            "com.bca.mybca",                // myBCA
            "com.bca.mybca.omni.android",   // myBCA (Omni)
            "com.bcadigital.blu",           // Blu by BCA
            "id.co.bri.brimo",              // BRImo
            "id.bmri.livin",                // Livin' by Mandiri
            "id.bni.wondr",                  // wondr by BNI (baru)
            "com.mediasoft.bni",            // BNI Mobile Banking (lama)
            "com.jago.digitalBanking",      // Bank Jago
            "com.alloapp.yump",             // Allo Bank
            "id.co.btn.mobilebanking.android", // balé by BTN
            "com.btpn.dc",                  // Jenius
            "id.dana",                      // DANA
            "com.krom.android",             // Krom Bank
            "id.co.bankbkemobile.digitalbank" // Sea Bank
        )
        val result = mutableListOf<Map<String, Any>>()
        val pm = packageManager
        for (pkg in whitelist) {
            try {
                val appInfo = pm.getApplicationInfo(pkg, 0)
                val name = pm.getApplicationLabel(appInfo).toString()
                Log.d("WiroFinBankApps", "Found installed app: $pkg -> $name")

                // Get app icon as bytes - handle adaptive icons safely
                val iconBytes = try {
                    val iconDrawable = pm.getApplicationIcon(appInfo)
                    val bitmap = drawableToBitmap(iconDrawable)
                    val stream = java.io.ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    stream.toByteArray()
                } catch (iconErr: Exception) {
                    Log.e("WiroFinBankApps", "Icon error for $pkg: ${iconErr.message}")
                    ByteArray(0)
                }

                val appKey = when (pkg) {
                    "com.bca" -> "bca_mobile"
                    "com.bca.mybca", "com.bca.mybca.omni.android" -> "mybca"
                    "com.bcadigital.blu" -> "blu"
                    "id.co.bri.brimo" -> "brimo"
                    "id.bmri.livin" -> "livin"
                    "id.bni.wondr", "com.mediasoft.bni" -> "bni"
                    "com.jago.digitalBanking" -> "jago"
                    "com.alloapp.yump" -> "allobank"
                    "id.co.btn.mobilebanking.android" -> "btn"
                    "com.btpn.dc" -> "jenius"
                    "id.dana" -> "dana"
                    "com.krom.android" -> "krom"
                    "id.co.bankbkemobile.digitalbank" -> "seabank"
                    else -> pkg
                }

                // Avoid duplicates (e.g. com.bca.mybca and com.bca.mybca.omni.android)
                if (result.any { it["appKey"] == appKey }) {
                    Log.d("WiroFinBankApps", "Skipping duplicate appKey=$appKey for $pkg")
                    continue
                }

                result.add(mapOf(
                    "packageName" to pkg,
                    "name" to name,
                    "appKey" to appKey,
                    "icon" to iconBytes
                ))
            } catch (e: PackageManager.NameNotFoundException) {
                Log.d("WiroFinBankApps", "Not installed: $pkg")
            } catch (e: Exception) {
                Log.e("WiroFinBankApps", "Unexpected error for $pkg: ${e.message}", e)
            }
        }
        Log.d("WiroFinBankApps", "Total installed banking apps found: ${result.size}")
        return result
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            return drawable.bitmap
        }

        val size = 192 // High resolution
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        // AdaptiveIconDrawable (Android 8+) needs special handling
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && drawable is AdaptiveIconDrawable) {
            // Draw on white rounded background
            val paint = android.graphics.Paint().apply {
                color = android.graphics.Color.WHITE
                isAntiAlias = true
            }
            val radius = size / 2f
            canvas.drawCircle(radius, radius, radius, paint)
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)
        } else {
            val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else size
            val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else size
            val scaledBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val scaledCanvas = Canvas(scaledBitmap)
            drawable.setBounds(0, 0, width, height)
            drawable.draw(scaledCanvas)
            return scaledBitmap
        }
        return bitmap
    }


    private fun showNotification(title: String, message: String) {
        try {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = "wirofin_transactions"
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    channelId,
                    "WiroFin Transactions",
                    NotificationManager.IMPORTANCE_HIGH
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
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)

            notificationManager.notify(System.currentTimeMillis().toInt(), builder.build())
            Log.d("WiroFinMainActivity", "Notification sent successfully: title=$title, message=$message")
        } catch (e: Exception) {
            Log.e("WiroFinMainActivity", "Error sending notification: ${e.message}", e)
        }
    }
}
