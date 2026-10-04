import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/l10n/l10n_ext.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/features/calendar/domain/hijri_service.dart';
import 'package:waqt/features/prayer/application/prayer_providers.dart';
import 'package:waqt/features/prayer/domain/prayer_engine.dart';
import 'package:waqt/features/widgets/application/widget_sync.dart';
import 'package:waqt/features/widgets/domain/widget_payload.dart';

void main() {
  setUpAll(ensureTimeZones);

  final engine = PrayerEngine(PrayerConfig(
    latitude: 37.9601,
    longitude: 58.3261,
    location: locationFor('Asia/Ashgabat'),
  ));
  final now = DateTime.utc(2026, 10, 4, 11); // 16:00 Ashgabat

  Map<String, Object?> build({String lang = 'en'}) => buildWidgetPayload(
        engine: engine,
        hijri: const HijriService(),
        l10n: lookupAppLocalizations(Locale(lang)),
        placeName: 'Ashgabat',
        now: now,
        todayMarks: {Prayer.fajr: PrayerStatus.onTime, Prayer.dhuhr: PrayerStatus.missed},
      );

  test('payload: 7 days of epoch-second times, marks only for today, JSON-safe', () {
    final p = build();
    final json = jsonDecode(jsonEncode(p)) as Map<String, Object?>;
    final days = (json['days']! as List).cast<Map<String, Object?>>();
    expect(days, hasLength(7));
    expect(days.first['d'], '2026-10-04');
    expect(days.first['m'], ['done', 'missed', '', '', '']);
    expect(days[1]['m'], ['', '', '', '', '']);
    final t = (days.first['t']! as List).cast<int>();
    expect(t, hasLength(5));
    expect(t[1] * 1000, engine.day(DateTime(2026, 10, 4))[Prayer.dhuhr].millisecondsSinceEpoch);
    expect(json['names'], ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']);
    final s = json['s']! as Map<String, Object?>;
    expect(s['windowOpen'], '%s · window open');
    expect(s['marked'], '%s marked');
  });

  test('payload is localized', () {
    final p = build(lang: 'ru');
    expect((p['names']! as List).first, 'Фаджр');
  });

  test('update times: prayer boundaries plus a 15-minute grid, all in the future', () {
    final times = widgetUpdateTimes(build(), now);
    expect(times.every((t) => t.isAfter(now)), isTrue);
    expect(times.first.difference(now), lessThanOrEqualTo(const Duration(minutes: 15)));
    final asr = engine.day(DateTime(2026, 10, 4))[Prayer.asr];
    expect(times.any((t) => t.isAtSameMomentAs(asr)), isTrue);
  });

  test('widget tap URIs map to routes', () {
    expect(routeForWidgetUri(Uri.parse('waqt://today?homeWidget&mark=asr&day=2026-10-04')),
        '/today?mark=asr&day=2026-10-04');
    expect(routeForWidgetUri(Uri.parse('waqt://today?homeWidget')), '/today');
    expect(routeForWidgetUri(null), isNull);
  });
}
