package com.youngsolver.bicount

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.net.Uri
import android.os.Build
import android.util.Log
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

private const val TAG = "BicountHomeWidget"

/**
 * Mirrors `BicountHomeWidgetAction.openHomeUri()` on the Dart side. Hardcoded
 * on purpose: the empty card is rendered precisely when no action URI has
 * been published yet.
 */
private const val OPEN_HOME_URI = "bicount://widget/open-home?homeWidget=1"

class BicountHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        // A launcher shows "Can't load widget" whenever updateAppWidget() is
        // never called for an id (e.g. an uncaught exception here) or is
        // called with a RemoteViews that fails to inflate. Every fallback
        // below is deliberately simpler than the one before it, so a widget
        // never gets stuck on that placeholder even if something upstream
        // (bad/missing stored data, a chart bitmap, a launcher quirk with
        // the responsive API) goes wrong.
        val data = try {
            WidgetData.from(context, widgetData)
        } catch (error: Exception) {
            Log.e(TAG, "Failed to read widget data, using safe defaults", error)
            WidgetData.safeDefaults()
        }

        // Nothing published yet: one card at every size, no size map needed.
        if (!data.hasData) {
            appWidgetIds.forEach { widgetId ->
                try {
                    appWidgetManager.updateAppWidget(widgetId, buildEmptyViews(context))
                } catch (error: Exception) {
                    Log.e(TAG, "Empty layout failed for widget $widgetId", error)
                }
            }
            return
        }

        appWidgetIds.forEach { widgetId ->
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    // Android picks the largest entry that still fits the cell,
                    // so these must reflect the width each design actually
                    // needs. The two-column layouts (chart/wide) are unusable
                    // below ~250dp: each column would get ~70dp and every
                    // label would wrap or ellipsize.
                    val views = RemoteViews(
                        mapOf(
                            SizeF(110f, 110f) to buildXsViews(context, data),
                            SizeF(220f, 200f) to buildMediumViews(context, data),
                            SizeF(250f, 110f) to buildWideViews(context, data),
                            SizeF(250f, 170f) to buildChartViews(context, data),
                            SizeF(250f, 280f) to buildLargeViews(context, data, 3),
                            SizeF(250f, 380f) to buildLargeViews(context, data, 6),
                            SizeF(250f, 470f) to buildLargeViews(context, data, 10),
                        ),
                    )
                    appWidgetManager.updateAppWidget(widgetId, views)
                } else {
                    val options = appWidgetManager.getAppWidgetOptions(widgetId)
                    appWidgetManager.updateAppWidget(
                        widgetId,
                        buildViewsForOptions(context, data, options),
                    )
                }
            } catch (error: Exception) {
                Log.e(TAG, "Responsive layout failed for widget $widgetId, falling back", error)
                try {
                    val options = appWidgetManager.getAppWidgetOptions(widgetId)
                    appWidgetManager.updateAppWidget(
                        widgetId,
                        buildViewsForOptions(context, data, options),
                    )
                } catch (fallbackError: Exception) {
                    Log.e(TAG, "Single-size fallback also failed for widget $widgetId, using XS", fallbackError)
                    appWidgetManager.updateAppWidget(widgetId, buildXsViews(context, data))
                }
            }
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return
        }
        val data = WidgetData.from(context, HomeWidgetPlugin.getData(context))
        appWidgetManager.updateAppWidget(
            appWidgetId,
            buildViewsForOptions(context, data, newOptions),
        )
    }

    private fun buildViewsForOptions(
        context: Context,
        data: WidgetData,
        options: android.os.Bundle,
    ): RemoteViews {
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)

        // Mirrors the responsive breakpoints above: two-column designs
        // (chart/wide) only kick in once there is real width to split.
        return when {
            minWidth >= 250 && minHeight >= 470 -> buildLargeViews(context, data, 10)
            minWidth >= 250 && minHeight >= 380 -> buildLargeViews(context, data, 6)
            minWidth >= 250 && minHeight >= 280 -> buildLargeViews(context, data, 3)
            minWidth >= 250 && minHeight >= 170 -> buildChartViews(context, data)
            minWidth >= 250 -> buildWideViews(context, data)
            minWidth >= 220 && minHeight >= 200 -> buildMediumViews(context, data)
            else -> buildXsViews(context, data)
        }
    }

    // ── Layout builders ──────────────────────────────────────────────────

    /**
     * Card shown before the app has published anything: logo and a single
     * label, both following the system theme through resource qualifiers.
     * The tap target is wired to a fixed URI because the action URIs are
     * published with the data, so none exist yet — without it the card would
     * invite a tap and do nothing.
     */
    private fun buildEmptyViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.bicount_home_widget_empty)
        setClick(context, views, R.id.widget_empty_root, OPEN_HOME_URI)
        return views
    }

    private fun buildXsViews(context: Context, data: WidgetData): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.bicount_home_widget_xs)
        applyCommonSurface(views, data)
        views.setTextViewText(R.id.widget_eyebrow, data.eyebrow)
        views.setTextColor(R.id.widget_eyebrow, data.subtitleColor)
        views.setTextViewText(R.id.widget_balance, data.balance)
        views.setTextColor(R.id.widget_balance, data.balanceColor)
        views.setTextViewText(R.id.widget_month_income, data.incomeTotalText)
        views.setTextColor(R.id.widget_month_income, data.monthIncomeColor)
        views.setTextViewText(R.id.widget_month_expense, data.expenseTotalText)
        views.setTextViewText(R.id.widget_single_button, data.singleButtonLabel)
        views.setTextColor(R.id.widget_single_button, data.buttonTextColor)
        setClick(context, views, R.id.widget_root, data.mainActionUri)
        setClick(context, views, R.id.widget_single_button, data.singleButtonActionUri)
        return views
    }

    private fun buildChartViews(context: Context, data: WidgetData): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.bicount_home_widget_chart)
        applyCommonSurface(views, data)
        views.setTextViewText(R.id.widget_eyebrow, data.eyebrow)
        views.setTextColor(R.id.widget_eyebrow, data.subtitleColor)
        views.setTextViewText(R.id.widget_balance, data.balance)
        views.setTextColor(R.id.widget_balance, data.balanceColor)
        views.setTextViewText(R.id.widget_month_label, data.monthSectionLabel)
        views.setTextColor(R.id.widget_month_label, data.subtitleColor)
        views.setTextViewText(R.id.widget_income_word, data.entriesLabel)
        views.setTextViewText(R.id.widget_expense_word, data.exitsLabel)
        views.setTextColor(R.id.widget_income_word, data.subtitleColor)
        views.setTextColor(R.id.widget_expense_word, data.subtitleColor)
        views.setTextViewText(R.id.widget_month_income, data.monthIncomeLabel)
        views.setTextColor(R.id.widget_month_income, data.monthIncomeColor)
        views.setTextViewText(R.id.widget_month_expense, data.monthExpenseLabel)
        views.setImageViewBitmap(
            R.id.widget_chart_image,
            BarChartRenderer.twoBars(
                context,
                income = data.monthIncomeValue,
                expense = data.monthExpenseValue,
                widthDp = 86,
                heightDp = 40,
            ),
        )
        views.setTextViewText(R.id.widget_income_button, data.incomeButtonLabel)
        views.setTextViewText(R.id.widget_expense_button, data.expenseButtonLabel)
        setClick(context, views, R.id.widget_root, data.mainActionUri)
        setClick(context, views, R.id.widget_income_button, data.incomeButtonActionUri)
        setClick(context, views, R.id.widget_expense_button, data.expenseButtonActionUri)
        return views
    }

    private fun buildMediumViews(context: Context, data: WidgetData): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.bicount_home_widget_medium)
        applyCommonSurface(views, data)
        views.setTextViewText(R.id.widget_eyebrow, data.eyebrow)
        views.setTextColor(R.id.widget_eyebrow, data.subtitleColor)
        views.setTextViewText(R.id.widget_balance, data.balance)
        views.setTextColor(R.id.widget_balance, data.balanceColor)
        views.setTextViewText(R.id.widget_month_label, data.monthSectionLabel)
        views.setTextColor(R.id.widget_month_label, data.subtitleColor)
        views.setTextViewText(R.id.widget_income_word, data.entriesLabel)
        views.setTextViewText(R.id.widget_expense_word, data.exitsLabel)
        views.setTextColor(R.id.widget_income_word, data.subtitleColor)
        views.setTextColor(R.id.widget_expense_word, data.subtitleColor)
        views.setTextViewText(R.id.widget_month_income, data.monthIncomeLabel)
        views.setTextColor(R.id.widget_month_income, data.monthIncomeColor)
        views.setTextViewText(R.id.widget_month_expense, data.monthExpenseLabel)
        views.setTextViewText(R.id.widget_income_button, data.incomeButtonLabel)
        views.setTextViewText(R.id.widget_expense_button, data.expenseButtonLabel)
        setClick(context, views, R.id.widget_root, data.mainActionUri)
        setClick(context, views, R.id.widget_income_button, data.incomeButtonActionUri)
        setClick(context, views, R.id.widget_expense_button, data.expenseButtonActionUri)
        return views
    }

    /// [maxRows] is driven by the cell height: the taller the widget, the
    /// more recent transactions it lists. RemoteViews cannot measure itself,
    /// so the count is decided by which size bucket the launcher picked.
    private fun buildLargeViews(
        context: Context,
        data: WidgetData,
        maxRows: Int,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.bicount_home_widget_large)
        applyCommonSurface(views, data)
        views.setTextViewText(R.id.widget_eyebrow, data.eyebrow)
        views.setTextColor(R.id.widget_eyebrow, data.subtitleColor)
        views.setTextViewText(R.id.widget_balance, data.balance)
        views.setTextColor(R.id.widget_balance, data.balanceColor)
        views.setTextViewText(R.id.widget_week_section_label, data.monthCurveLabel)
        views.setTextColor(R.id.widget_week_section_label, data.subtitleColor)
        views.setTextViewText(R.id.widget_legend_income, data.incomeTotalText)
        views.setTextColor(R.id.widget_legend_income, data.monthIncomeColor)
        views.setTextViewText(R.id.widget_legend_expense, data.expenseTotalText)
        views.setImageViewBitmap(
            R.id.widget_chart_image,
            LineChartRenderer.dualSeries(
                context,
                incomeSeries = data.monthDailyIncome,
                expenseSeries = data.monthDailyExpense,
                widthDp = 300,
                heightDp = 120,
            ),
        )
        views.setTextViewText(R.id.widget_income_button, data.incomeButtonLabel)
        views.setTextViewText(R.id.widget_expense_button, data.expenseButtonLabel)

        val rows = data.recentItems.take(maxRows.coerceAtLeast(0))
        views.removeAllViews(R.id.widget_transactions_container)
        views.setViewVisibility(
            R.id.widget_transactions_divider,
            if (rows.isEmpty()) View.GONE else View.VISIBLE,
        )
        rows.forEach { item ->
            val row = RemoteViews(
                context.packageName,
                R.layout.bicount_home_widget_transaction_row,
            )
            row.setTextViewText(R.id.widget_transaction_label, item.label)
            row.setTextColor(R.id.widget_transaction_label, data.titleColor)
            row.setTextViewText(R.id.widget_transaction_amount, item.amountLabel)
            row.setTextColor(R.id.widget_transaction_amount, item.amountColor)
            // Each row opens its own transaction rather than the card action.
            setClick(context, row, R.id.widget_transaction_row, item.actionUri)
            views.addView(R.id.widget_transactions_container, row)
        }

        setClick(context, views, R.id.widget_root, data.mainActionUri)
        setClick(context, views, R.id.widget_income_button, data.incomeButtonActionUri)
        setClick(context, views, R.id.widget_expense_button, data.expenseButtonActionUri)
        return views
    }

    private fun buildWideViews(context: Context, data: WidgetData): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.bicount_home_widget_wide)
        applyCommonSurface(views, data)
        views.setTextViewText(R.id.widget_eyebrow, data.eyebrow)
        views.setTextColor(R.id.widget_eyebrow, data.subtitleColor)
        views.setTextViewText(R.id.widget_balance, data.balance)
        views.setTextColor(R.id.widget_balance, data.balanceColor)
        views.setTextViewText(R.id.widget_month_delta, data.monthDeltaLabel)
        views.setViewVisibility(
            R.id.widget_month_delta,
            if (data.monthDeltaLabel.isBlank()) View.GONE else View.VISIBLE,
        )
        views.setTextColor(R.id.widget_month_delta, data.monthDeltaColor)
        views.setTextViewText(
            R.id.widget_week_section_label,
            data.weekSectionCompactLabel,
        )
        views.setTextColor(R.id.widget_week_section_label, data.subtitleColor)
        views.setImageViewBitmap(
            R.id.widget_chart_image,
            BarChartRenderer.week(
                context,
                values = data.weekValues,
                highlightIndex = data.weekHighlightIndex,
                widthDp = 64,
                heightDp = 28,
            ),
        )
        views.setTextViewText(R.id.widget_income_button, data.incomeButtonLabel)
        views.setTextViewText(R.id.widget_expense_button, data.expenseButtonLabel)
        setClick(context, views, R.id.widget_root, data.mainActionUri)
        setClick(context, views, R.id.widget_income_button, data.incomeButtonActionUri)
        setClick(context, views, R.id.widget_expense_button, data.expenseButtonActionUri)
        return views
    }

    private fun applyCommonSurface(views: RemoteViews, data: WidgetData) {
        views.setInt(
            R.id.widget_root,
            "setBackgroundResource",
            if (data.isDarkTheme) R.drawable.widget_surface_dark else R.drawable.widget_surface_light,
        )
    }

    private fun setClick(context: Context, views: RemoteViews, viewId: Int, actionUri: String) {
        if (actionUri.isBlank()) {
            return
        }
        views.setOnClickPendingIntent(
            viewId,
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(actionUri)),
        )
    }
}

/** One recent-transaction row, deep-linking to its own transaction. */
private class RecentItem(
    val label: String,
    val amountLabel: String,
    val amountColor: Int,
    val actionUri: String,
)

/** All the widget's persisted state, read once per update pass. */
private class WidgetData(
    /**
     * Whether the app has ever published a snapshot. False on a fresh install
     * and while the app has been installed but never opened: the data layouts
     * would then render with a placeholder balance, blank totals and an empty
     * chart, so the empty card is shown instead.
     */
    val hasData: Boolean,
    val isDarkTheme: Boolean,
    val eyebrow: String,
    val balance: String,
    val balanceColor: Int,
    val mainActionUri: String,
    val monthDeltaLabel: String,
    val monthDeltaColor: Int,
    val monthIncomeValue: Double,
    val monthExpenseValue: Double,
    val monthIncomeLabel: String,
    val monthIncomeColor: Int,
    val monthExpenseLabel: String,
    val nextItemLabel: String,
    val nextItemAmountLabel: String,
    val nextItemAmountColor: Int,
    val nextItemActionUri: String,
    val weekDayLabels: List<String>,
    val weekValues: List<Double>,
    val weekHighlightIndex: Int,
    val recentItemLabel: String,
    val recentItemAmountLabel: String,
    val recentItemAmountColor: Int,
    val singleButtonLabel: String,
    val singleButtonActionUri: String,
    val incomeButtonLabel: String,
    val incomeButtonActionUri: String,
    val expenseButtonLabel: String,
    val expenseButtonActionUri: String,
    val monthDailyIncome: List<Double>,
    val monthDailyExpense: List<Double>,
    val monthCurveLabel: String,
    val incomeLegendLabel: String,
    val expenseLegendLabel: String,
    val recentItems: List<RecentItem>,
    val monthSectionLabel: String,
    val nextItemSectionLabel: String,
    val weekSectionLabel: String,
    val weekSectionCompactLabel: String,
    val entriesLabel: String,
    val exitsLabel: String,
    val titleColor: Int,
    val subtitleColor: Int,
    val buttonTextColor: Int,
) {
    /// "In 480 $" / "Out 100 $" — the legend word and its amount in one
    /// string, so narrow layouts can show both in a single TextView.
    val incomeTotalText: String
        get() = listOf(entriesLabel, monthIncomeLabel).filter { it.isNotBlank() }.joinToString(" ")

    val expenseTotalText: String
        get() = listOf(exitsLabel, monthExpenseLabel).filter { it.isNotBlank() }.joinToString(" ")

    companion object {
        private const val LIST_DELIMITER = "|"
        private const val DOUBLE_FLAG_PREFIX = "home_widget.double."

        private fun parseRecentItems(raw: String): List<RecentItem> {
            if (raw.isBlank()) return emptyList()
            return try {
                val array = JSONArray(raw)
                (0 until array.length()).mapNotNull { index ->
                    val obj = array.optJSONObject(index) ?: return@mapNotNull null
                    RecentItem(
                        label = obj.optString("label"),
                        amountLabel = obj.optString("amount"),
                        amountColor = obj.optLong("color", 0xFF212121L).toInt(),
                        actionUri = obj.optString("uri"),
                    )
                }
            } catch (error: Exception) {
                Log.e(TAG, "Malformed recent items payload", error)
                emptyList()
            }
        }

        /** Never touches SharedPreferences — used when reading stored data itself fails. */
        fun safeDefaults(): WidgetData = WidgetData(
            hasData = false,
            isDarkTheme = false,
            eyebrow = "BICOUNT",
            balance = "Bicount",
            balanceColor = 0xFF212121.toInt(),
            mainActionUri = "",
            monthDeltaLabel = "",
            monthDeltaColor = 0xFF76A646.toInt(),
            monthIncomeValue = 0.0,
            monthExpenseValue = 0.0,
            monthIncomeLabel = "",
            monthIncomeColor = 0xFF76A646.toInt(),
            monthExpenseLabel = "",
            nextItemLabel = "",
            nextItemAmountLabel = "",
            nextItemAmountColor = 0xFFF44336.toInt(),
            nextItemActionUri = "",
            weekDayLabels = emptyList(),
            weekValues = emptyList(),
            weekHighlightIndex = -1,
            recentItemLabel = "",
            recentItemAmountLabel = "",
            recentItemAmountColor = 0xFF212121.toInt(),
            singleButtonLabel = "Open app",
            singleButtonActionUri = "",
            incomeButtonLabel = "",
            incomeButtonActionUri = "",
            expenseButtonLabel = "",
            expenseButtonActionUri = "",
            monthDailyIncome = emptyList(),
            monthDailyExpense = emptyList(),
            monthCurveLabel = "",
            incomeLegendLabel = "",
            expenseLegendLabel = "",
            recentItems = emptyList(),
            monthSectionLabel = "",
            nextItemSectionLabel = "",
            weekSectionLabel = "",
            weekSectionCompactLabel = "",
            entriesLabel = "",
            exitsLabel = "",
            titleColor = 0xFF212121.toInt(),
            subtitleColor = 0xFF9AA0A6.toInt(),
            buttonTextColor = 0xFFF9F9F9.toInt(),
        )

        fun from(context: Context, prefs: SharedPreferences): WidgetData {
            fun str(key: String, default: String = "") = prefs.getString(key, default).orEmpty()
            // The home_widget plugin cannot store a Double directly in
            // SharedPreferences, so it writes the raw IEEE-754 bits into a
            // Long and flags the key with "home_widget.double.<key>" = true.
            // Reading such a Long as a number yields ~4.6e18 instead of 100.0,
            // which silently destroys every chart scale.
            fun dbl(key: String): Double {
                val raw = prefs.all[key] ?: return 0.0
                if (raw is Long && prefs.getBoolean("$DOUBLE_FLAG_PREFIX$key", false)) {
                    return java.lang.Double.longBitsToDouble(raw)
                }
                return when (raw) {
                    is Double -> raw
                    is Float -> raw.toDouble()
                    is Long -> raw.toDouble()
                    is Int -> raw.toDouble()
                    is String -> raw.toDoubleOrNull() ?: 0.0
                    else -> 0.0
                }
            }
            fun color(key: String, default: Int) = prefs.getColorCompat(key, default)

            val defaultTitle = context.getString(R.string.bicount_home_widget_default_title)
            val defaultButton = context.getString(R.string.bicount_home_widget_default_button)

            return WidgetData(
                // Published explicitly by the app. Falling back on the balance
                // key is only for snapshots written before this key existed:
                // testing its presence alone is not enough, since signing out
                // used to write it as an empty string.
                hasData = when (prefs.getString("bicount_widget_state", null)) {
                    "signed_out" -> false
                    "empty", "populated" -> true
                    else -> str("bicount_widget_balance").isNotBlank()
                },
                isDarkTheme = prefs.getBoolean("bicount_widget_theme_is_dark", false),
                eyebrow = str("bicount_widget_eyebrow", "BICOUNT"),
                balance = str("bicount_widget_balance", defaultTitle),
                balanceColor = color("bicount_widget_balance_color", 0xFF212121.toInt()),
                mainActionUri = str("bicount_widget_main_action_uri"),
                monthDeltaLabel = str("bicount_widget_month_delta_label"),
                monthDeltaColor = color("bicount_widget_month_delta_color", 0xFF76A646.toInt()),
                monthIncomeValue = dbl("bicount_widget_month_income_value"),
                monthExpenseValue = dbl("bicount_widget_month_expense_value"),
                monthIncomeLabel = str("bicount_widget_month_income_label"),
                monthIncomeColor = color("bicount_widget_month_income_color", 0xFF76A646.toInt()),
                monthExpenseLabel = str("bicount_widget_month_expense_label"),
                nextItemLabel = str("bicount_widget_next_item_label"),
                nextItemAmountLabel = str("bicount_widget_next_item_amount_label"),
                nextItemAmountColor = color("bicount_widget_next_item_amount_color", 0xFFF44336.toInt()),
                nextItemActionUri = str("bicount_widget_next_item_action_uri"),
                weekDayLabels = str("bicount_widget_week_day_labels")
                    .split(LIST_DELIMITER)
                    .filter { it.isNotEmpty() },
                weekValues = str("bicount_widget_week_values")
                    .split(LIST_DELIMITER)
                    .mapNotNull { it.toDoubleOrNull() },
                weekHighlightIndex = prefs.all["bicount_widget_week_highlight_index"]
                    ?.let { (it as? Number)?.toInt() } ?: -1,
                recentItemLabel = str("bicount_widget_recent_item_label"),
                recentItemAmountLabel = str("bicount_widget_recent_item_amount_label"),
                recentItemAmountColor = color("bicount_widget_recent_item_amount_color", 0xFF212121.toInt()),
                singleButtonLabel = str("bicount_widget_single_button_label", defaultButton),
                singleButtonActionUri = str("bicount_widget_single_button_action_uri"),
                incomeButtonLabel = str(
                    "bicount_widget_income_button_label",
                    context.getString(R.string.bicount_home_widget_default_income_button),
                ),
                incomeButtonActionUri = str("bicount_widget_income_button_action_uri"),
                expenseButtonLabel = str(
                    "bicount_widget_expense_button_label",
                    context.getString(R.string.bicount_home_widget_default_expense_button),
                ),
                expenseButtonActionUri = str("bicount_widget_expense_button_action_uri"),
                monthDailyIncome = str("bicount_widget_month_daily_income")
                    .split(LIST_DELIMITER)
                    .mapNotNull { it.toDoubleOrNull() },
                monthDailyExpense = str("bicount_widget_month_daily_expense")
                    .split(LIST_DELIMITER)
                    .mapNotNull { it.toDoubleOrNull() },
                monthCurveLabel = str("bicount_widget_month_curve_label"),
                incomeLegendLabel = str("bicount_widget_income_legend_label"),
                expenseLegendLabel = str("bicount_widget_expense_legend_label"),
                recentItems = parseRecentItems(str("bicount_widget_recent_items")),
                monthSectionLabel = str("bicount_widget_month_section_label"),
                nextItemSectionLabel = str("bicount_widget_next_item_section_label"),
                weekSectionLabel = str("bicount_widget_week_section_label"),
                weekSectionCompactLabel = str("bicount_widget_week_section_compact_label"),
                entriesLabel = str(
                    "bicount_widget_entries_label",
                    context.getString(R.string.bicount_home_widget_default_entries),
                ),
                exitsLabel = str(
                    "bicount_widget_exits_label",
                    context.getString(R.string.bicount_home_widget_default_exits),
                ),
                titleColor = color("bicount_widget_title_color", 0xFF212121.toInt()),
                subtitleColor = color("bicount_widget_subtitle_color", 0xFF9AA0A6.toInt()),
                buttonTextColor = color("bicount_widget_button_text_color", 0xFFF9F9F9.toInt()),
            )
        }
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

/**
 * Hand-drawn bar charts. RemoteViews cannot run Flutter/Compose or set
 * per-child layout_weight dynamically pre-API 31, so charts are rendered
 * once as a Bitmap and displayed through a plain ImageView.
 */
private object BarChartRenderer {
    private const val POSITIVE_COLOR = 0xFF76A646.toInt()
    private const val NEGATIVE_COLOR = 0xFFF44336.toInt()
    private const val NEUTRAL_COLOR = 0xFFD5D8DC.toInt()

    fun twoBars(context: Context, income: Double, expense: Double, widthDp: Int, heightDp: Int): Bitmap {
        return draw(
            context,
            values = listOf(income, expense),
            colors = listOf(POSITIVE_COLOR, NEGATIVE_COLOR),
            widthDp = widthDp,
            heightDp = heightDp,
            gapDp = 10,
        )
    }

    fun week(context: Context, values: List<Double>, highlightIndex: Int, widthDp: Int, heightDp: Int): Bitmap {
        val safeValues = if (values.isEmpty()) List(7) { 0.0 } else values
        val colors = safeValues.indices.map { index ->
            if (index == highlightIndex) POSITIVE_COLOR else NEUTRAL_COLOR
        }
        return draw(context, safeValues, colors, widthDp, heightDp, gapDp = 4)
    }

    private fun draw(
        context: Context,
        values: List<Double>,
        colors: List<Int>,
        widthDp: Int,
        heightDp: Int,
        gapDp: Int,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val widthPx = (widthDp * density)
        val heightPx = (heightDp * density)
        val bitmap = Bitmap.createBitmap(widthPx.toInt().coerceAtLeast(1), heightPx.toInt().coerceAtLeast(1), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val maxValue = (values.maxOrNull() ?: 0.0).coerceAtLeast(0.01)
        val gapPx = gapDp * density
        val barCount = values.size.coerceAtLeast(1)
        val barWidthPx = ((widthPx - gapPx * (barCount - 1)) / barCount).coerceAtLeast(2f)
        val cornerRadius = (2 * density).coerceAtMost(barWidthPx / 2)
        val minBarHeightPx = (4 * density)

        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        values.forEachIndexed { index, value ->
            val ratio = (value / maxValue).toFloat().coerceIn(0f, 1f)
            val barHeightPx = (heightPx * ratio).coerceAtLeast(minBarHeightPx)
            val left = index * (barWidthPx + gapPx)
            val top = heightPx - barHeightPx
            paint.color = colors.getOrElse(index) { Color.GRAY }
            canvas.drawRoundRect(
                RectF(left, top, left + barWidthPx, heightPx),
                cornerRadius,
                cornerRadius,
                paint,
            )
        }
        return bitmap
    }
}

/**
 * Two overlaid line curves (daily income vs daily expense over the month).
 * Drawn by hand for the same reason as the bars: a widget process cannot
 * host Flutter or a charting library.
 */
private object LineChartRenderer {
    private const val INCOME_COLOR = 0xFF76A646.toInt()
    private const val EXPENSE_COLOR = 0xFFF44336.toInt()

    fun dualSeries(
        context: Context,
        incomeSeries: List<Double>,
        expenseSeries: List<Double>,
        widthDp: Int,
        heightDp: Int,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val widthPx = (widthDp * density).coerceAtLeast(1f)
        val heightPx = (heightDp * density).coerceAtLeast(1f)
        val bitmap = Bitmap.createBitmap(
            widthPx.toInt(),
            heightPx.toInt(),
            Bitmap.Config.ARGB_8888,
        )
        val canvas = Canvas(bitmap)

        val pointCount = maxOf(incomeSeries.size, expenseSeries.size)
        if (pointCount == 0) {
            return bitmap
        }

        // Both curves share one scale so they stay visually comparable.
        val maxValue = maxOf(
            incomeSeries.maxOrNull() ?: 0.0,
            expenseSeries.maxOrNull() ?: 0.0,
        ).coerceAtLeast(0.01)

        val strokePx = 2f * density
        val inset = strokePx
        drawSeries(canvas, incomeSeries, pointCount, maxValue, widthPx, heightPx, inset, strokePx, INCOME_COLOR)
        drawSeries(canvas, expenseSeries, pointCount, maxValue, widthPx, heightPx, inset, strokePx, EXPENSE_COLOR)
        return bitmap
    }

    private fun drawSeries(
        canvas: Canvas,
        series: List<Double>,
        pointCount: Int,
        maxValue: Double,
        widthPx: Float,
        heightPx: Float,
        inset: Float,
        strokePx: Float,
        color: Int,
    ) {
        if (series.isEmpty()) {
            return
        }
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            style = Paint.Style.STROKE
            strokeWidth = strokePx
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
        }
        val path = Path()
        val usableHeight = heightPx - inset * 2
        val stepX = if (pointCount > 1) (widthPx - inset * 2) / (pointCount - 1) else 0f

        series.forEachIndexed { index, value ->
            val ratio = (value / maxValue).toFloat().coerceIn(0f, 1f)
            val x = inset + stepX * index
            val y = inset + usableHeight * (1f - ratio)
            if (index == 0) path.moveTo(x, y) else path.lineTo(x, y)
        }

        // A single data point has no line to stroke, so mark it with a dot.
        if (series.size == 1) {
            val ratio = (series[0] / maxValue).toFloat().coerceIn(0f, 1f)
            paint.style = Paint.Style.FILL
            canvas.drawCircle(inset, inset + usableHeight * (1f - ratio), strokePx, paint)
            return
        }
        canvas.drawPath(path, paint)
    }
}
