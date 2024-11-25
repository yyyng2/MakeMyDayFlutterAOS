package io.github.yyyng2.make_my_day

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import android.util.TypedValue
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import io.realm.kotlin.Realm
import io.realm.kotlin.RealmConfiguration
import io.realm.kotlin.ext.query
import io.realm.kotlin.types.RealmInstant
import org.mongodb.kbson.ObjectId
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.ChronoUnit
import kotlin.math.abs

class HomeScreenWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val realm = getRealm()
        val isDdayEmpty = realm.query<DdayEntity>().count().find() == 0L
        val homeWidgetEmptyTitle = widgetData.getString("homeWidgetEmptyTitle", "")
        try {
            for (appWidgetId in appWidgetIds) {

                val widgetData = HomeWidgetPlugin.getData(context)

                val views = RemoteViews(context.packageName, R.layout.home_screen_widget).apply {
                    val ddayIdString = widgetData.getString("ddayId_$appWidgetId", "")
                    homeWidgetEmptyTitle
                    if (ddayIdString != null) {
                        if (ddayIdString != "") {
                            val ddayId = ObjectId(ddayIdString)
                            val results = realm.query<DdayEntity>("id == $0", ddayId).find()
                            if (results.isNotEmpty()) {
                                val dday = results.first()
                                setTextViewText(R.id.headline_title, dday.title)

                                val targetDate = realmInstantToLocalDate(dday.date)
                                val now = LocalDate.now()
                                var differenceInDays: Int

                                if (dday.repeatAnniversary) {
                                    // 올해의 같은 날짜로 설정
                                    var thisYearDate = LocalDate.of(
                                        now.year,
                                        targetDate.month,
                                        targetDate.dayOfMonth
                                    )

                                    // 만약 올해의 날짜가 이미 지났다면 내년으로 설정
                                    if (thisYearDate.isBefore(now)) {
                                        thisYearDate = LocalDate.of(
                                            now.year + 1,
                                            targetDate.month,
                                            targetDate.dayOfMonth
                                        )
                                    }

                                    differenceInDays = ChronoUnit.DAYS.between(now, thisYearDate).toInt()
                                } else {
                                    differenceInDays = ChronoUnit.DAYS.between(now, targetDate).toInt()
                                }

                                if (dday.dayPlus) {
                                    differenceInDays -= 1
                                }

                                val ddayText = when {
                                    differenceInDays == 0 -> "D-day"
                                    differenceInDays > 0 -> "D-${differenceInDays}"
                                    else -> "D+${abs(differenceInDays)}"
                                }

                                setTextViewText(R.id.headline_contents, ddayText)

                                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                                    context,
                                    MainActivity::class.java
                                )
                                setOnClickPendingIntent(R.id.appwidget_container, pendingIntent)
                            } else {
                                setTextViewText(R.id.headline_title, homeWidgetEmptyTitle)
                                setTextViewText(R.id.headline_contents, "")
                                println("result is empty")

                                if (isDdayEmpty) {

                                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                                        context,
                                        MainActivity::class.java
                                    )
                                    setOnClickPendingIntent(R.id.appwidget_container, pendingIntent)
                                } else {

                                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                                        context,
                                        MainActivity::class.java,
                                        android.net.Uri.parse("MakeMyDayAppWidget://ddaySelection/appWidgetId=$appWidgetId")
                                    )
                                    setOnClickPendingIntent(R.id.appwidget_container, pendingIntent)
                                }
                            }
                        } else {
                            setTextViewText(R.id.headline_title, homeWidgetEmptyTitle)
                            setTextViewText(R.id.headline_contents, "")

                            println("ddayIdString == 0, $isDdayEmpty")
                            if (isDdayEmpty) {

                                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                                    context,
                                    MainActivity::class.java
                                )
                                setOnClickPendingIntent(R.id.appwidget_container, pendingIntent)
                            } else {

                                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                                    context,
                                    MainActivity::class.java,
                                    android.net.Uri.parse("MakeMyDayAppWidget://ddaySelection/appWidgetId=$appWidgetId")
                                )
                                setOnClickPendingIntent(R.id.appwidget_container, pendingIntent)
                            }
                        }

                    } else {
                        setTextViewText(R.id.headline_title, homeWidgetEmptyTitle)
                        setTextViewText(R.id.headline_contents, "")
                        println("ddayIdString == null")

                        if (isDdayEmpty) {

                            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                                context,
                                MainActivity::class.java
                            )
                            setOnClickPendingIntent(R.id.appwidget_container, pendingIntent)
                        } else {

                            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                                context,
                                MainActivity::class.java,
                                android.net.Uri.parse("MakeMyDayAppWidget://ddaySelection/appWidgetId=$appWidgetId")
                            )
                            setOnClickPendingIntent(R.id.appwidget_container, pendingIntent)
                        }
                    }
                }

                // 화면 크기 확인
                val metrics = context.resources.displayMetrics

                // 화면 크기에 따라 텍스트 크기 조정
                val textSize = when {
                    metrics.widthPixels >= 1200 -> 17f
                    metrics.widthPixels >= 1150 -> 16f
                    metrics.widthPixels >= 1100 -> 15f
                    metrics.widthPixels >= 1050 -> 14f
                    metrics.widthPixels >= 1000 -> 13f
                    else -> 12f
                }

                // 텍스트 크기 설정
                views.setTextViewTextSize(R.id.headline_title, TypedValue.COMPLEX_UNIT_SP, textSize)
                views.setTextViewTextSize(R.id.headline_contents, TypedValue.COMPLEX_UNIT_SP, textSize)

                appWidgetManager.updateAppWidget(appWidgetId, views)

            }
        } catch (e: Exception) {
            println("Error updating widget: ${e.message}")
        }
        realm.close()
    }

    override
    fun onEnabled(context: Context) {
        super.onEnabled(context)
        println("HomeScreenWidget, onEnabled called")

    }

    override fun onDisabled(context: Context) {
        println("deleteWidget")
    }

    private fun realmInstantToLocalDate(realmInstant: RealmInstant): LocalDate {
        val instant = Instant.ofEpochSecond(realmInstant.epochSeconds, realmInstant.nanosecondsOfSecond.toLong())
        return instant.atZone(ZoneId.systemDefault()).toLocalDate()
    }

    private fun getRealm(): Realm {
//        val config = RealmConfiguration.create(schema = setOf(DdayEntity::class))
        val config = RealmConfiguration.Builder(
            schema = setOf(DdayEntity::class)
        )
            .schemaVersion(5)
            .build()
        return Realm.open(config)
    }
}