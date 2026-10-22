import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/l10n/l10n_ext.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/features/calendar/domain/hijri_service.dart';
import 'package:waqt/features/prayer/application/prayer_providers.dart';
import 'package:waqt/features/prayer/domain/prayer_engine.dart';
import 'package:waqt/features/watch/domain/watch_payload.dart';

void main() {
  setUpAll(ensureTimeZones);

  final engine = PrayerEngine(
    PrayerConfig(latitude: 37.9601, longitude: 58.3261, location: locationFor('Asia/Ashgabat')),
  );
  final now = DateTime.utc(2026, 10, 4, 11); // 16:00 Ashgabat
  final at = now.millisecondsSinceEpoch;

  Map<String, Object?> build({String lang = 'en', int streak = 0}) => buildWatchPayload(
    engine: engine,
    hijri: const HijriService(),
    l10n: lookupAppLocalizations(Locale(lang)),
    language: lang,
    placeName: 'Ashgabat',
    latitude: 37.9601,
    longitude: 58.3261,
    now: now,
    todayMarks: {Prayer.fajr: PrayerStatus.onTime},
    streak: streak,
    adhkarCounts: {AdhkarSet.morning: {'m01': 1}},
  );

  test('watch payload: 30 days, qibla, adhkar and strings, JSON-safe', () {
    final json = jsonDecode(jsonEncode(build(streak: 4))) as Map<String, Object?>;
    final days = (json['days']! as List).cast<Map<String, Object?>>();
    expect(days, hasLength(watchPayloadDays));
    expect(days.first['d'], '2026-10-04');
    expect(days.first['m'], ['done', '', '', '', '']);
    expect(json['today'], '2026-10-04');
    expect(json['lang'], 'en');
    // Ashgabat → Makkah is roughly south-west.
    expect(json['qibla'] as num, inInclusiveRange(220, 240));
    expect(json['adhkar'], {'morning': {'m01': 1}, 'evening': <String, int>{}});
    final w = json['w']! as Map<String, Object?>;
    expect(w['onTime'], 'Prayed on time');
    expect(w['prayedOf'], '{done} of {total} prayed');
    expect(w['posOf'], '{pos} of {total}');
    expect(w['qiblaFromNorth'], '%s° from north');
    expect(w['streak'], '4-day streak');
  });

  test('watch strings follow the app language, Turkmen included', () {
    final w = build(lang: 'tk')['w']! as Map<String, String>;
    expect(w['qibla'], 'Kybla');
    expect(w['streak'], '');
  });

  group('watch events', () {
    test('marks parse; missed/excused and witr are refused', () {
      final e = WatchEvent.tryParse({'t': 'mark', 'day': '2026-10-04', 'p': 'asr', 's': 'onTime', 'at': at});
      expect(e, isA<WatchMark>());
      final m = e! as WatchMark;
      expect(m.day, const DayKey('2026-10-04'));
      expect(m.prayer, Prayer.asr);
      expect(m.status, PrayerStatus.onTime);
      expect(m.at.millisecondsSinceEpoch, at);

      final clear = WatchEvent.tryParse({'t': 'mark', 'day': '2026-10-04', 'p': 'asr', 's': '', 'at': at});
      expect((clear! as WatchMark).status, isNull);

      for (final bad in [
        {'t': 'mark', 'day': '2026-10-04', 'p': 'asr', 's': 'missed', 'at': at},
        {'t': 'mark', 'day': '2026-10-04', 'p': 'witr', 's': 'onTime', 'at': at},
        {'t': 'mark', 'day': '4-10-2026', 'p': 'asr', 's': 'onTime', 'at': at},
        {'t': 'mark', 'day': '2026-10-04', 'p': 'asr', 's': 'onTime'},
        {'t': 'nope', 'at': at},
        'not a map',
      ]) {
        expect(WatchEvent.tryParse(bad), isNull, reason: '$bad');
      }
    });

    test('only prayers that have started can be marked', () {
      WatchMark mark(String day, Prayer p) => WatchMark(now, DayKey(day), p, PrayerStatus.onTime);
      // 16:00 local: Dhuhr has begun, Maghrib has not.
      expect(mark('2026-10-04', Prayer.dhuhr).isAllowed(engine, now), isTrue);
      expect(mark('2026-10-04', Prayer.maghrib).isAllowed(engine, now), isFalse);
      expect(mark('2026-10-03', Prayer.isha).isAllowed(engine, now), isTrue);
      expect(mark('2026-10-05', Prayer.fajr).isAllowed(engine, now), isFalse);
    });

    test('tasbih and adhkar events', () {
      final t = WatchEvent.tryParse({'t': 'tasbih', 'phrase': 'preset', 'count': 100, 'goal': 100, 'at': at});
      expect(t, isA<WatchTasbih>());
      expect((t! as WatchTasbih).count, 100);
      expect(WatchEvent.tryParse({'t': 'tasbih', 'phrase': 'preset', 'count': 0, 'goal': 100, 'at': at}), isNull);

      final a = WatchEvent.tryParse(
        {'t': 'adhkar', 'day': '2026-10-04', 'set': 'evening', 'item': 'e03', 'count': 3, 'at': at},
      );
      expect(a, isA<WatchAdhkar>());
      expect((a! as WatchAdhkar).set, AdhkarSet.evening);
      expect(WatchEvent.tryParse({'t': 'adhkar', 'day': '2026-10-04', 'set': 'noon', 'item': 'x', 'count': 1, 'at': at}),
          isNull);
    });
  });
}
