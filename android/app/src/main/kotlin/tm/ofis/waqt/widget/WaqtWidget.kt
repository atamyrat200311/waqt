package tm.ofis.waqt.widget

import android.content.Context
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontFamily
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.actionStartActivity
import tm.ofis.waqt.MainActivity

/** Receiver registered in AndroidManifest.xml (name used from Dart). */
class WaqtWidgetReceiver : HomeWidgetGlanceWidgetReceiver<WaqtWidget>() {
  override val glanceAppWidget = WaqtWidget()
}

/** Design tokens (light / dark) from the style guide. */
private object Tok {
  val bg = ColorProvider(day = Color(0xFFF7F4EE), night = Color(0xFF121D18))
  val ink = ColorProvider(day = Color(0xFF14201B), night = Color(0xFFF0ECE3))
  val muted = ColorProvider(day = Color(0xFF56635C), night = Color(0xFFA3AFA8))
  val accent = ColorProvider(day = Color(0xFF0F4C3A), night = Color(0xFF6CC9A1))
  val hairline = ColorProvider(day = Color(0xFFE7E1D5), night = Color(0xFF22302A))
  val brass = ColorProvider(day = Color(0xFFB88A3E), night = Color(0xFFE0BD78))
  val primary = ColorProvider(day = Color(0xFF0F4C3A), night = Color(0xFF6CC9A1))
  val onPrimary = ColorProvider(day = Color(0xFFFFFFFF), night = Color(0xFF0A1310))
  val mint = ColorProvider(day = Color(0xFFDFECE4), night = Color(0xFF173328))
  val onMint = ColorProvider(day = Color(0xFF0F4C3A), night = Color(0xFF6CC9A1))
  val currentBar = ColorProvider(day = Color(0x590F4C3A), night = Color(0x596CC9A1))
}

class WaqtWidget : GlanceAppWidget() {
  override val stateDefinition = HomeWidgetGlanceStateDefinition()
  override val sizeMode = SizeMode.Single

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { Content(context, currentState()) }
  }

  override suspend fun providePreview(context: Context, widgetCategory: Int) {
    provideContent { Content(context, HomeWidgetGlanceState(HomeWidgetPlugin.getData(context))) }
  }

  @Composable
  private fun Content(context: Context, state: HomeWidgetGlanceState) {
    val data = WidgetData.parse(state.preferences.getString(WidgetData.KEY, null))
    val open = actionStartActivity<MainActivity>(context, Uri.parse("waqt://today?homeWidget"))
    Box(
        modifier =
            GlanceModifier.fillMaxSize()
                .background(Tok.bg)
                .cornerRadius(28.dp)
                .padding(18.dp)
                .clickable(open),
    ) {
      if (data == null) {
        Text("Waqt", style = TextStyle(color = Tok.ink, fontSize = 20.sp, fontFamily = FontFamily.Serif))
      } else {
        Body(context, data, data.snapshot(System.currentTimeMillis() / 1000))
      }
    }
  }

  @Composable
  private fun Body(context: Context, d: WidgetData, s: Snapshot) {
    Column(modifier = GlanceModifier.fillMaxSize()) {
      Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(
            s.kicker.uppercase(),
            maxLines = 1,
            style = TextStyle(color = Tok.accent, fontSize = 12.sp, fontWeight = FontWeight.Bold),
            modifier = GlanceModifier.defaultWeight(),
        )
        Text(d.place, maxLines = 1, style = TextStyle(color = Tok.muted, fontSize = 13.sp))
      }
      Spacer(GlanceModifier.height(8.dp))
      Row(verticalAlignment = Alignment.Bottom) {
        Text(
            s.bigTime,
            style = TextStyle(color = Tok.ink, fontSize = 34.sp, fontFamily = FontFamily.Serif),
        )
        Spacer(GlanceModifier.width(8.dp))
        Text(s.countdownLine, maxLines = 1, style = TextStyle(color = Tok.muted, fontSize = 14.sp))
      }
      Spacer(GlanceModifier.height(12.dp))
      Row(modifier = GlanceModifier.fillMaxWidth()) {
        for (i in 0 until 5) {
          val color =
              when {
                s.marks[i] == "done" -> Tok.brass
                i == s.currentIndex && s.marks[i].isEmpty() -> Tok.currentBar
                else -> Tok.hairline
              }
          Box(modifier = GlanceModifier.defaultWeight().height(4.dp).background(color).cornerRadius(2.dp)) {}
          if (i < 4) Spacer(GlanceModifier.width(6.dp))
        }
      }
      Spacer(GlanceModifier.defaultWeight())
      if (s.currentIndex >= 0) {
        val marked = s.marks[s.currentIndex] == "done"
        val name = d.names[s.currentIndex]
        val label = if (marked) d.str("marked").replace("%s", name) else d.str("mark")
        val action =
            if (marked) actionStartActivity<MainActivity>(context, Uri.parse("waqt://today?homeWidget"))
            else
                actionRunCallback<MarkPrayedAction>(
                    actionParametersOf(
                        MarkPrayedAction.prayerKey to WidgetData.PRAYER_IDS[s.currentIndex],
                        MarkPrayedAction.dayKey to s.dayKey,
                    )
                )
        Box(
            modifier =
                GlanceModifier.fillMaxWidth()
                    .height(48.dp)
                    .background(if (marked) Tok.mint else Tok.primary)
                    .cornerRadius(24.dp)
                    .clickable(action),
            contentAlignment = Alignment.Center,
        ) {
          Text(
              (if (marked) "✓  " else "") + label,
              style =
                  TextStyle(
                      color = if (marked) Tok.onMint else Tok.onPrimary,
                      fontSize = 15.sp,
                      fontWeight = FontWeight.Medium,
                  ),
          )
        }
      }
    }
  }
}

/** "Mark as prayed": hands off to Dart (`widgetInteraction`) in the background. */
class MarkPrayedAction : ActionCallback {
  companion object {
    val prayerKey = ActionParameters.Key<String>("prayer")
    val dayKey = ActionParameters.Key<String>("day")
  }

  override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
    val prayer = parameters[prayerKey] ?: return
    val day = parameters[dayKey] ?: return
    HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("waqt://mark?prayer=$prayer&day=$day"))
        .send()
  }
}
