import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../calendar/domain/hijri_service.dart';
import '../../prayer/domain/prayer_engine.dart';

/// Shared-storage key read by the native widgets (WidgetKit / Glance).
const widgetDataKey = 'waqt_widget';

/// Builds the JSON the home-screen widgets render. Contract (v1):
///
/// ```json
/// {
///   "v": 1, "place": "Ashgabat", "dark": false,
///   "names": ["Fajr", …5],
///   "s": {"next": "Next", "in": "in", "inAfter": "", "h": "h", "m": "m",
///         "windowOpen": "%s · window open", "mark": "Mark as prayed", "marked": "%s marked"},
///   "days": [{"d": "2026-10-04", "hijri": "22 Rabīʿ II",
///             "t": [epochSeconds ×5], "sunrise": epochSeconds,
///             "m": ["done" | "missed" | "excused" | "", ×5]}, …7]
/// }
/// ```
/// Native code derives "next" / "window open" / countdown from `t` and the
/// current time, so the widget stays right for a week without the app.
Map<String, Object?> buildWidgetPayload({
  required PrayerEngine engine,
  required HijriService hijri,
  required AppLocalizations l10n,
  required String placeName,
  required DateTime now,
  required Map<Prayer, PrayerStatus> todayMarks,
  int days = 7,
}) {
  final start = engine.localDate(now);
  final today = DayKey.fromDate(start);
  String mark(PrayerStatus? s) => switch (s) {
    null => '',
    PrayerStatus.missed => 'missed',
    PrayerStatus.excused => 'excused',
    _ => 'done',
  };
  int sec(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

  return {
    'v': 1,
    'place': placeName,
    'names': [for (final p in Prayer.values) l10n.prayer(p)],
    's': {
      'next': l10n.widgetNext,
      'in': l10n.homeIn,
      'inAfter': l10n.homeInAfter,
      'h': l10n.unitH,
      'm': l10n.unitM,
      'windowOpen': l10n.widgetWindowOpen('%s'),
      'mark': l10n.widgetMarkPrayed,
      'marked': l10n.widgetMarked('%s'),
    },
    'days': [
      for (var i = 0; i < days; i++)
        () {
          final date = DateTime(start.year, start.month, start.day + i);
          final d = engine.day(date);
          final h = hijri.fromGregorian(date);
          final key = DayKey.fromDate(date);
          return {
            'd': key.value,
            'hijri': l10n.dayMonthHijri(h.day, h.month),
            't': [for (final p in Prayer.values) sec(d[p])],
            'sunrise': sec(d.sunrise),
            'm': [
              for (final p in Prayer.values)
                key == today ? mark(todayMarks[p]) : '',
            ],
          };
        }(),
    ],
  };
}

/// Instants at which the widget's visible state changes (prayer starts,
/// sunrise) over the payload's days, plus a denser grid in the coming hours
/// so the Android countdown stays close (Android has no live text timers).
List<DateTime> widgetUpdateTimes(
  Map<String, Object?> payload,
  DateTime now, {
  Duration step = const Duration(minutes: 15),
  Duration dense = const Duration(hours: 6),
}) {
  final out = <DateTime>{};
  for (final day in (payload['days']! as List).cast<Map<String, Object?>>()) {
    for (final t in (day['t']! as List).cast<int>()) {
      out.add(DateTime.fromMillisecondsSinceEpoch(t * 1000));
    }
    out.add(
      DateTime.fromMillisecondsSinceEpoch((day['sunrise']! as int) * 1000),
    );
  }
  final first = DateTime.fromMillisecondsSinceEpoch(
    now.millisecondsSinceEpoch -
        now.millisecondsSinceEpoch % step.inMilliseconds,
  ).add(step);
  for (var t = first; t.isBefore(now.add(dense)); t = t.add(step)) {
    out.add(t);
  }
  return out.where((t) => t.isAfter(now)).toList()..sort();
}
