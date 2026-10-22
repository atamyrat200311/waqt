import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../calendar/domain/hijri_service.dart';
import '../../prayer/domain/prayer_engine.dart';
import '../../tools/domain/qibla.dart';
import '../../widgets/domain/widget_payload.dart';

/// Days of prayer times sent to the Apple Watch, so the watch app and its
/// complications stay right for a month without the phone.
const watchPayloadDays = 30;

/// Builds the JSON the Apple Watch app renders: the widget payload
/// (`buildWidgetPayload`, same `days` format) for [watchPayloadDays], plus
///
/// ```json
/// { "lang": "tk", "today": "2026-10-22", "qibla": 236.4, "streak": 4,
///   "adhkarDay": "2026-10-22", "adhkar": {"morning": {"m01": 1}, "evening": {}},
///   "w": {"today": "Şu gün", …} }
/// ```
/// `w` holds the watch's strings in the app language (Turkmen is not an
/// iOS system language, so the watch cannot localize on its own).
Map<String, Object?> buildWatchPayload({
  required PrayerEngine engine,
  required HijriService hijri,
  required AppLocalizations l10n,
  required String language,
  required String placeName,
  required double latitude,
  required double longitude,
  required DateTime now,
  required Map<Prayer, PrayerStatus> todayMarks,
  int streak = 0,
  Map<AdhkarSet, Map<String, int>> adhkarCounts = const {},
}) {
  final today = DayKey.fromDate(engine.localDate(now));
  return {
    ...buildWidgetPayload(
      engine: engine,
      hijri: hijri,
      l10n: l10n,
      placeName: placeName,
      now: now,
      todayMarks: todayMarks,
      days: watchPayloadDays,
    ),
    'lang': language,
    'today': today.value,
    'qibla': (qiblaBearing(latitude, longitude) * 10).round() / 10,
    'streak': streak,
    'adhkarDay': today.value,
    'adhkar': {for (final set in AdhkarSet.values) set.name: adhkarCounts[set] ?? const <String, int>{}},
    'w': watchStrings(l10n, streak: streak),
  };
}

/// Strings shown on the watch. `%s` / `{pos}` / `{total}` / `{done}` are
/// filled in natively.
Map<String, String> watchStrings(AppLocalizations l, {int streak = 0}) => {
  'today': l.today,
  'tasbih': l.tasbih,
  'qibla': l.qibla,
  'adhkar': l.toolsAdhkar,
  'morning': l.adhkarMorning,
  'evening': l.adhkarEvening,
  'onTime': l.markOnTime,
  'congregation': l.markCongregation,
  'late': l.markLate,
  'clear': l.markClear,
  'notStarted': l.markNotStarted,
  'now': l.chipNow,
  'done': l.chipDone,
  'missed': l.chipMissed,
  'excused': l.chipExcused,
  'qiblaTurn': l.qiblaTurn,
  'qiblaFacing': l.qiblaFacing,
  'qiblaNoSensor': l.qiblaNoSensor('%s'),
  'qiblaFromNorth': l.qiblaFromNorth('%s'),
  'tasbihOf': l.tasbihOf('%s'),
  'tasbihComplete': l.tasbihComplete('%s'),
  'tasbihTapAgain': l.tasbihTapAgain,
  'tasbihPreset': l.tasbihPreset,
  'dhikrFree': l.watchDhikrFree,
  'reset': l.reset,
  'tapToCount': l.adhkarTapToCount,
  'adhkarComplete': l.adhkarComplete,
  'adhkarSetDone': l.adhkarSetDone,
  'posOf': l.adhkarPosOf('{pos}', '{total}'),
  'prayedOf': l.watchPrayedOf('{done}', '{total}'),
  'streak': streak > 0 ? l.watchStreak(streak) : '',
  'timetable': l.timetableShort,
};

/// Something the user did on the watch, queued to the phone by
/// WatchConnectivity (`transferUserInfo` / `sendMessage`).
sealed class WatchEvent {
  const WatchEvent(this.at);

  /// When it happened on the watch (also the event's id).
  final DateTime at;

  /// Parses one event dictionary; null for unknown or malformed ones.
  ///
  /// - `{"t": "mark", "day": "2026-10-22", "p": "asr", "s": "onTime" | "congregation" | "late" | ""}`
  /// - `{"t": "tasbih", "phrase": "preset", "count": 100, "goal": 100}`
  /// - `{"t": "adhkar", "day": "2026-10-22", "set": "morning", "item": "m01", "count": 3}`
  ///
  /// Every event also carries `"at"` (epoch milliseconds).
  static WatchEvent? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final m = raw.map((k, v) => MapEntry(k.toString(), v));
    final atMs = m['at'];
    if (atMs is! num) return null;
    final at = DateTime.fromMillisecondsSinceEpoch(atMs.toInt());
    DayKey? day() {
      final d = m['day'];
      return d is String && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(d) ? DayKey(d) : null;
    }

    int? count(String key) {
      final v = m[key];
      return v is num && v >= 0 && v < 100000 ? v.toInt() : null;
    }

    switch (m['t']) {
      case 'mark':
        final d = day();
        final prayer = Prayer.tryParse(m['p'] as String?);
        if (d == null || prayer == null || !prayer.isObligatory) return null;
        // Missed / excused need the phone's qada confirmation, so the watch
        // only offers prayed statuses or clearing.
        final PrayerStatus? status;
        switch (m['s']) {
          case '':
            status = null;
          case 'onTime':
            status = PrayerStatus.onTime;
          case 'congregation':
            status = PrayerStatus.congregation;
          case 'late':
            status = PrayerStatus.late;
          default:
            return null;
        }
        return WatchMark(at, d, prayer, status);
      case 'tasbih':
        final phrase = m['phrase'];
        final n = count('count');
        final goal = count('goal');
        if (phrase is! String || phrase.isEmpty || n == null || n == 0 || goal == null) return null;
        return WatchTasbih(at, phrase, n, goal);
      case 'adhkar':
        final d = day();
        final set = AdhkarSet.values.where((s) => s.name == m['set']).firstOrNull;
        final item = m['item'];
        final n = count('count');
        if (d == null || set == null || item is! String || item.isEmpty || n == null) return null;
        return WatchAdhkar(at, d, set, item, n);
    }
    return null;
  }
}

/// Marks (or with a null [status] clears) a prayer.
final class WatchMark extends WatchEvent {
  const WatchMark(super.at, this.day, this.prayer, this.status);
  final DayKey day;
  final Prayer prayer;
  final PrayerStatus? status;

  /// Only prayers whose time has begun, on today or an earlier day.
  bool isAllowed(PrayerEngine engine, DateTime now) {
    final today = DayKey.fromDate(engine.localDate(now));
    if (day.value.compareTo(today.value) > 0) return false;
    return !engine.day(day.date)[prayer].isAfter(now);
  }
}

/// A finished or reset tasbih session ("preset" = 33 · 33 · 34).
final class WatchTasbih extends WatchEvent {
  const WatchTasbih(super.at, this.phrase, this.count, this.goal);
  final String phrase;
  final int count;
  final int goal;
}

/// Progress on one adhkar item.
final class WatchAdhkar extends WatchEvent {
  const WatchAdhkar(super.at, this.day, this.set, this.itemId, this.count);
  final DayKey day;
  final AdhkarSet set;
  final String itemId;
  final int count;
}
