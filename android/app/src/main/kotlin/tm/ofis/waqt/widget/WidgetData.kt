package tm.ofis.waqt.widget

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONObject

/** One day of the payload written by `lib/features/widgets/domain/widget_payload.dart`. */
data class WidgetDay(
    val date: String,
    val hijri: String,
    val times: LongArray,
    val sunrise: Long,
    val marks: List<String>,
)

/** What the widget shows at one instant. */
data class Snapshot(
    val kicker: String,
    val bigTime: String,
    val countdownLine: String,
    /** Prayer whose window is open (0–4), or −1. */
    val currentIndex: Int,
    val marks: List<String>,
    val dayKey: String,
)

class WidgetData(
    val place: String,
    val names: List<String>,
    private val strings: JSONObject,
    val days: List<WidgetDay>,
) {
  fun str(key: String): String = strings.optString(key, "")

  /** Windows: Fajr→sunrise, Dhuhr→Asr, Asr→Maghrib, Maghrib→Isha, Isha→next Fajr. */
  fun snapshot(now: Long): Snapshot {
    var dayIdx = 0
    for (i in days.indices) if (days[i].times[0] <= now) dayIdx = i
    val day = days[dayIdx]
    val nextFajr = days.getOrNull(dayIdx + 1)?.times?.get(0) ?: (day.times[4] + 6 * 3600)
    val ends = longArrayOf(day.sunrise, day.times[2], day.times[3], day.times[4], nextFajr)
    var current = -1
    if (now >= day.times[0]) {
      for (p in 0 until 5) if (now >= day.times[p] && now < ends[p]) current = p
    }

    // Next prayer strictly after now.
    var nextName = names[0]
    var nextAt = nextFajr
    run loop@{
      for (i in dayIdx until days.size) for (p in 0 until 5) {
        if (days[i].times[p] > now) {
          nextName = names[p]
          nextAt = days[i].times[p]
          return@loop
        }
      }
    }

    val totalMin = ((nextAt - now + 59) / 60).coerceAtLeast(0)
    val h = totalMin / 60
    val m = totalMin % 60
    val cd = if (h > 0) "$h${str("h")} $m${str("m")}" else "$m${str("m")}"
    val inWord = str("in")
    val after = str("inAfter")
    val countdown =
        listOf(nextName, if (inWord.isNotEmpty()) inWord else null, cd + if (after.isNotEmpty()) " $after" else "")
            .filterNotNull()
            .joinToString(" ")

    val kicker = if (current >= 0) str("windowOpen").replace("%s", names[current]) else str("next") + " · " + nextName
    val big = hhmm(if (current >= 0) day.times[current] else nextAt)
    // Marks are only known for the day the app last wrote (index 0).
    val marks = if (dayIdx == 0) day.marks else List(5) { "" }
    return Snapshot(kicker, big, countdown, current, marks, day.date)
  }

  companion object {
    const val KEY = "waqt_widget"
    val PRAYER_IDS = listOf("fajr", "dhuhr", "asr", "maghrib", "isha")

    private fun hhmm(epochSec: Long): String =
        SimpleDateFormat("HH:mm", Locale.US).format(Date(epochSec * 1000))

    fun parse(json: String?): WidgetData? {
      if (json.isNullOrEmpty()) return null
      return try {
        val o = JSONObject(json)
        val names = o.getJSONArray("names").let { a -> List(a.length()) { a.getString(it) } }
        val days =
            o.getJSONArray("days").let { a ->
              List(a.length()) {
                val d = a.getJSONObject(it)
                val t = d.getJSONArray("t")
                val m = d.getJSONArray("m")
                WidgetDay(
                    date = d.getString("d"),
                    hijri = d.optString("hijri"),
                    times = LongArray(t.length()) { i -> t.getLong(i) },
                    sunrise = d.getLong("sunrise"),
                    marks = List(m.length()) { i -> m.getString(i) },
                )
              }
            }
        if (days.isEmpty()) null else WidgetData(o.optString("place"), names, o.getJSONObject("s"), days)
      } catch (_: Exception) {
        null
      }
    }
  }
}
