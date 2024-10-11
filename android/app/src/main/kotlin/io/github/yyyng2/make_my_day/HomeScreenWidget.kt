package io.github.yyyng2.make_my_day

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import io.realm.kotlin.Realm
import io.realm.kotlin.RealmConfiguration
import io.realm.kotlin.ext.query
import io.realm.kotlin.query.RealmResults
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
                                var differenceInDays =
                                    ChronoUnit.DAYS.between(now, targetDate).toInt()

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
        val config = RealmConfiguration.create(schema = setOf(DdayEntity::class))
        return Realm.open(config)
    }
}