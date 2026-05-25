package com.wirodev.wirofin

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WiroFinSmallWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_small)

            val balance = widgetData.getString("widget_balance", "Rp 0")
            val activeMode = widgetData.getString("widget_active_mode", "personal") ?: "personal"

            views.setTextViewText(R.id.tv_balance, balance)
            views.setTextViewText(R.id.tv_mode_badge, activeMode.uppercase())

            // Update badge and button depending on business mode, but leave background/text to system Dark Mode
            if (activeMode == "company") {
                views.setInt(R.id.tv_mode_badge, "setBackgroundResource", R.drawable.bg_badge_company)
                views.setInt(R.id.btn_add_ai, "setBackgroundResource", R.drawable.bg_button_company)
                views.setInt(R.id.tv_btn_text, "setTextColor", Color.parseColor("#0F172A"))
            } else {
                views.setInt(R.id.tv_mode_badge, "setBackgroundResource", R.drawable.bg_badge_personal)
                views.setInt(R.id.btn_add_ai, "setBackgroundResource", R.drawable.bg_button_personal)
                views.setInt(R.id.tv_btn_text, "setTextColor", Color.parseColor("#FFFFFF"))
            }

            val intent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse("wirofin://add_transaction")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_add_ai, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
