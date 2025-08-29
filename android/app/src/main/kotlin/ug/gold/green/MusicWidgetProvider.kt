// Make sure this package name matches your project's package name
package ug.gold.green

import ug.gold.green.R
import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.AppWidgetTarget
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import com.ryanheise.audioservice.AudioServiceActivity

class MusicWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: android.content.SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.music_widget_layout).apply {
                // Get data from Flutter
                val title = widgetData.getString("track_title", "Select a Song")
                val artist = widgetData.getString("track_artist", "Green Gold")
                val artworkUrl = widgetData.getString("artwork_url", null)

                // Update the text views
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_artist, artist)
                
                // ** NEW: Set the small app icon in the corner **
                setImageViewResource(R.id.widget_app_icon, R.mipmap.ic_launcher)

                // Load artwork using Glide
                if (artworkUrl != null && artworkUrl.isNotEmpty()) {
                    val awt: AppWidgetTarget = AppWidgetTarget(context, R.id.widget_artwork, this, widgetId)
                    Glide.with(context.applicationContext).asBitmap().load(artworkUrl).into(awt)
                } else {
                    setImageViewResource(R.id.widget_artwork, R.mipmap.ic_launcher)
                }
                
                // Set the pending intent to open the app's profile screen
                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    AudioServiceActivity::class.java,
                    Uri.parse("home_widget://open_profile")
                )
                setOnClickPendingIntent(R.id.widget_root, launchIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
