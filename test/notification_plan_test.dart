import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/features/notifications/application/notification_taps.dart';
import 'package:waqt/features/notifications/domain/notification_plan.dart';
import 'package:waqt/features/prayer/application/prayer_providers.dart';
import 'package:waqt/features/prayer/domain/prayer_engine.dart';

void main() {
  setUpAll(ensureTimeZones);

  PrayerEngine engine() => PrayerEngine(PrayerConfig(
        latitude: 37.9601,
        longitude: 58.3261,
        location: locationFor('Asia/Ashgabat'),
      ));

  // 03:00 in Ashgabat, before Fajr.
  final now = DateTime.utc(2026, 10, 3, 22);

  List<PlannedNotification> plan(AppSettings s, {bool ramadan = false}) => NotificationPlanner.plan(
        engine: engine(),
        settings: s,
        now: now,
        isRamadan: (_) => ramadan,
      );

  test('5 prayers × 7 days, all in the future, sorted, unique ids', () {
    final p = plan(const AppSettings());
    expect(p, hasLength(35));
    expect(p.every((n) => n.at.isAfter(now)), isTrue);
    for (var i = 1; i < p.length; i++) {
      expect(!p[i].at.isBefore(p[i - 1].at), isTrue);
    }
    expect(p.map((n) => n.id).toSet(), hasLength(p.length));
    expect(p.every((n) => n.id < NotificationPlanner.reminderIdBase), isTrue);
    expect(p.first.prayer, Prayer.fajr);
    expect(p.first.alert, AlertType.silent);
  });

  test('never more than 60 pending', () {
    final p = plan(
      const AppSettings(adhkarReminders: true, suhoorReminder: true, taraweehReminder: true),
      ramadan: true,
    );
    expect(p.length, NotificationPlanner.maxPending);
    expect(p.last.at.difference(now).inDays, lessThanOrEqualTo(7));
  });

  test('alerts set to off are skipped; adhan is passed through', () {
    final p = plan(const AppSettings(alerts: {Prayer.dhuhr: AlertType.off, Prayer.fajr: AlertType.adhan}));
    expect(p.where((n) => n.prayer == Prayer.dhuhr), isEmpty);
    expect(p.where((n) => n.prayer == Prayer.fajr).every((n) => n.alert == AlertType.adhan), isTrue);
  });

  test('period mode pauses prayer alerts but keeps adhkar reminders', () {
    final p = plan(const AppSettings(periodMode: true, adhkarReminders: true));
    expect(p.where((n) => n.kind == NotificationKind.prayer), isEmpty);
    expect(p.where((n) => n.kind == NotificationKind.adhkarMorning), hasLength(7));
  });

  test('Ramadan: iftar replaces the Maghrib alert; suhoor comes before Fajr', () {
    final p = plan(const AppSettings(suhoorMinutes: 30), ramadan: true);
    expect(p.where((n) => n.kind == NotificationKind.prayer && n.prayer == Prayer.maghrib), isEmpty);
    expect(p.where((n) => n.kind == NotificationKind.iftar), hasLength(7));
    final firstSuhoor = p.firstWhere((n) => n.kind == NotificationKind.suhoor);
    final fajr = engine().day(DateTime(2026, 10, 4)).fajr;
    expect(fajr.difference(firstSuhoor.at), const Duration(minutes: 30));
  });

  test('ids are stable for the same day and slot across runs', () {
    final a = plan(const AppSettings());
    final b = plan(const AppSettings(adhkarReminders: true));
    final idsA = {for (final n in a) '${n.day.value}-${n.prayer}': n.id};
    for (final n in b.where((n) => n.kind == NotificationKind.prayer)) {
      expect(idsA['${n.day.value}-${n.prayer}'], n.id);
    }
  });

  test('payloads round-trip to routes', () {
    final p = plan(const AppSettings(adhkarReminders: true));
    final mark = NotificationPayload.parse(p.first.payload)! as MarkPayload;
    expect(mark.prayer, Prayer.fajr);
    expect(mark.day, const DayKey('2026-10-04'));
    expect(routeForPayload(mark), '/today?mark=fajr&day=2026-10-04');
    expect(routeForPayload(NotificationPayload.parse('adhkar:evening')!), '/adhkar/evening');
    expect(NotificationPayload.parse('garbage'), isNull);
  });

  test('adhkar times sit inside their windows', () {
    final d = engine().day(DateTime(2026, 10, 4));
    final m = NotificationPlanner.morningAdhkarTime(d);
    expect(m.isAfter(d.fajr) && m.isBefore(d.sunrise), isTrue);
    final ev = NotificationPlanner.eveningAdhkarTime(d);
    expect(ev.isAfter(d[Prayer.asr]) && ev.isBefore(d[Prayer.maghrib]), isTrue);
  });
}
