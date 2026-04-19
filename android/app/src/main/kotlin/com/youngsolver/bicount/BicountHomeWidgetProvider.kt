package com.youngsolver.bicount

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BicountHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.bicount_home_widget)
            val isDarkTheme = widgetData.getBoolean(KEY_THEME_IS_DARK, false)
            val badge = widgetData.getString(KEY_BADGE, "").orEmpty()
            val title = widgetData.getString(
                KEY_TITLE,
                context.getString(R.string.bicount_home_widget_default_title),
            ).orEmpty()
            val amount = widgetData.getString(KEY_AMOUNT, "").orEmpty()
            val subtitle = widgetData.getString(
                KEY_SUBTITLE,
                context.getString(R.string.bicount_home_widget_default_subtitle),
            ).orEmpty()
            val buttonLabel = widgetData.getString(
                KEY_BUTTON_LABEL,
                context.getString(R.string.bicount_home_widget_default_button),
            ).orEmpty()
            val mainActionUri = widgetData.getString(KEY_MAIN_ACTION_URI, "").orEmpty()
            val buttonActionUri = widgetData.getString(KEY_BUTTON_ACTION_URI, mainActionUri).orEmpty()

            views.setInt(
                R.id.widget_root,
                "setBackgroundResource",
                if (isDarkTheme) R.drawable.widget_surface_dark else R.drawable.widget_surface_light,
            )
            views.setInt(
                R.id.widget_button,
                "setBackgroundResource",
                if (isDarkTheme) R.drawable.widget_button_dark else R.drawable.widget_button_light,
            )
            views.setTextViewText(R.id.widget_badge, badge)
            views.setViewVisibility(
                R.id.widget_badge,
                if (badge.isBlank()) View.GONE else View.VISIBLE,
            )
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_amount, amount)
            views.setViewVisibility(
                R.id.widget_amount,
                if (amount.isBlank()) View.GONE else View.VISIBLE,
            )
            views.setTextViewText(R.id.widget_subtitle, subtitle)
            views.setTextViewText(R.id.widget_button, buttonLabel)

            views.setTextColor(
                R.id.widget_title,
                widgetData.getColorCompat(KEY_TITLE_COLOR, 0xFF212121.toInt()),
            )
            views.setTextColor(
                R.id.widget_amount,
                widgetData.getColorCompat(KEY_AMOUNT_COLOR, 0xFF76A646.toInt()),
            )
            views.setTextColor(
                R.id.widget_subtitle,
                widgetData.getColorCompat(KEY_SUBTITLE_COLOR, 0xFF757575.toInt()),
            )
            views.setTextColor(
                R.id.widget_button,
                widgetData.getColorCompat(
                    KEY_BUTTON_TEXT_COLOR,
                    if (isDarkTheme) 0xFF2C2C2C.toInt() else 0xFFF9F9F9.toInt(),
                ),
            )

            if (mainActionUri.isNotBlank()) {
                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse(mainActionUri),
                    ),
                )
            }
            if (buttonActionUri.isNotBlank()) {
                views.setOnClickPendingIntent(
                    R.id.widget_button,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse(buttonActionUri),
                    ),
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    companion object {
        private const val KEY_THEME_IS_DARK = "bicount_widget_theme_is_dark"
        private const val KEY_BADGE = "bicount_widget_badge"
        private const val KEY_TITLE = "bicount_widget_title"
        private const val KEY_AMOUNT = "bicount_widget_amount"
        private const val KEY_SUBTITLE = "bicount_widget_subtitle"
        private const val KEY_BUTTON_LABEL = "bicount_widget_button_label"
        private const val KEY_MAIN_ACTION_URI = "bicount_widget_main_action_uri"
        private const val KEY_BUTTON_ACTION_URI = "bicount_widget_button_action_uri"
        private const val KEY_TITLE_COLOR = "bicount_widget_title_color"
        private const val KEY_AMOUNT_COLOR = "bicount_widget_amount_color"
        private const val KEY_SUBTITLE_COLOR = "bicount_widget_subtitle_color"
        private const val KEY_BUTTON_TEXT_COLOR = "bicount_widget_button_text_color"
    }
}

private fun SharedPreferences.getColorCompat(key: String, defaultValue: Int): Int {
    val value = all[key] ?: return defaultValue
    return when (value) {
        is Int -> value
        is Long -> value.toInt()
        is Float -> value.toInt()
        is String -> value.toLongOrNull()?.toInt() ?: defaultValue
        else -> defaultValue
    }
}