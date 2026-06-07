package com.wirodev.wirofin

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log

class WiroFinNotificationListener : NotificationListenerService() {
    
    interface NotificationCallback {
        fun onNotificationReceived(packageName: String, title: String, text: String)
    }

    companion object {
        private var callback: NotificationCallback? = null
        
        fun setCallback(cb: NotificationCallback?) {
            callback = cb
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        val packageName = sbn.packageName ?: return
        Log.d("WiroFinNL", "onNotificationPosted: package=$packageName")
        println("WiroFinNL: onNotificationPosted: package=$packageName")
        
        // Whitelist packages
        val whitelist = setOf(
            "com.bca",                  // BCA Mobile
            "com.bca.mybca",            // myBCA
            "com.bca.mybca.omni.android", // myBCA Android Omni
            "com.wirodev.wirofin",      // WiroFin / Financial Diary (simulation/testing)
            "id.co.bri.brimo",          // BRImo BRI
            "com.bankmandiri.livin",    // Livin' by Mandiri
            "id.co.bni.newbnicust",     // BNI Mobile Banking
            "com.jago.app",             // Bank Jago
            "id.allobank.android",      // Allo Bank
            "id.co.btn.mobile",         // BTN Mobile
            "com.btpn.bwtn",            // Jenius
            "id.dana"                   // DANA
        )

        if (!whitelist.contains(packageName)) {
            Log.d("WiroFinNL", "onNotificationPosted: package=$packageName is NOT in whitelist, ignoring")
            println("WiroFinNL: onNotificationPosted: package=$packageName is NOT in whitelist, ignoring")
            return
        }

        val extras = sbn.notification.extras ?: return
        val title = extras.getString("android.title") ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val bigText = extras.getCharSequence("android.bigText")?.toString() ?: ""
        
        val fullText = if (text.length >= bigText.length) text else bigText

        Log.d("WiroFinNL", "onNotificationPosted: Whitelisted notification. title='$title', text='$text', bigText='$bigText', selectedFullText='$fullText'")
        println("WiroFinNL: onNotificationPosted: Whitelisted notification. title='$title', text='$text', bigText='$bigText', selectedFullText='$fullText'")

        // Stream it to the Flutter side via the active callback on the main thread
        Handler(Looper.getMainLooper()).post {
            if (callback != null) {
                Log.d("WiroFinNL", "onNotificationPosted: Sending to Flutter callback")
                println("WiroFinNL: onNotificationPosted: Sending to Flutter callback")
                callback?.onNotificationReceived(packageName, title, fullText)
            } else {
                Log.d("WiroFinNL", "onNotificationPosted: Flutter callback is NULL")
                println("WiroFinNL: onNotificationPosted: Flutter callback is NULL")
            }
        }
    }
}
