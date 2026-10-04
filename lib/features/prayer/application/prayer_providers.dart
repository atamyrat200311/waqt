import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/settings/settings_controller.dart';
import '../domain/prayer_engine.dart';

bool _tzReady = false;

/// Loads the bundled IANA database once (idempotent, synchronous).
void ensureTimeZones() {
  if (_tzReady) return;
  tzdata.initializeTimeZones();
  _tzReady = true;
}

/// Resolves an IANA id, falling back to UTC for unknown ids.
tz.Location locationFor(String id) {
  ensureTimeZones();
  try {
    return tz.getLocation(id);
  } on Exception {
    return tz.UTC;
  } on Error {
    return tz.UTC;
  }
}

/// Engine for the current settings. Rebuilt only when an input changes.
final prayerEngineProvider = Provider<PrayerEngine>((ref) {
  final loc = ref.watch(settingsProvider.select((s) => s.effectiveLocation));
  final method = ref.watch(settingsProvider.select((s) => s.calcMethod));
  final madhab = ref.watch(settingsProvider.select((s) => s.madhab));
  final offsets = ref.watch(settingsProvider.select((s) => s.offsets));
  return PrayerEngine(PrayerConfig(
    latitude: loc.latitude,
    longitude: loc.longitude,
    location: locationFor(loc.timezone),
    method: method,
    madhab: madhab,
    offsets: offsets,
  ));
});

/// Snapshot of where "now" sits in the prayer day. Recomputed every minute.
class PrayerNow {
  const PrayerNow({
    required this.now,
    required this.today,
    required this.next,
    required this.current,
  });

  final DateTime now;

  /// Today's times at the location.
  final PrayerDay today;
  final NextPrayer next;

  /// Open window, null between sunrise and Dhuhr.
  final PrayerWindow? current;

  /// Local date at the location as a [DayKey].
  DayKey get dayKey => DayKey.fromDate(today.date);

  /// Has [p]'s window started today?
  bool hasStarted(Prayer p) => !today[p].isAfter(now);
}

PrayerNow prayerNowAt(PrayerEngine engine, DateTime now) => PrayerNow(
      now: now,
      today: engine.today(now),
      next: engine.next(now),
      current: engine.currentWindow(now),
    );

/// Minute-resolution prayer state used by Home, Tasks, widgets…
final prayerNowProvider = Provider<PrayerNow>((ref) {
  final engine = ref.watch(prayerEngineProvider);
  final tick = ref.watch(minuteTickProvider).value ?? ref.read(clockProvider)();
  return prayerNowAt(engine, tick);
});

/// Local [DayKey] of "today" at the configured location.
final todayKeyProvider = Provider<DayKey>((ref) => ref.watch(prayerNowProvider).dayKey);
