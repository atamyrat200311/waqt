import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/settings/app_settings.dart';
import '../../prayer/domain/prayer_engine.dart';

enum NotificationKind { prayer, iftar, suhoor, taraweeh, adhkarMorning, adhkarEvening }

/// One notification to schedule. Pure value; `NotificationService` turns it
/// into a platform request.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.kind,
    required this.at,
    required this.day,
    this.prayer,
    this.alert = AlertType.silent,
  });

  final int id;
  final NotificationKind kind;

  /// Absolute instant (UTC-comparable).
  final DateTime at;

  /// Local prayer day this belongs to (location's calendar).
  final DayKey day;
  final Prayer? prayer;

  /// Sound style: adhan / silent (default system sound). Never `off` here.
  final AlertType alert;

  /// Tap payload, parsed by [NotificationPayload].
  String get payload => switch (kind) {
        NotificationKind.prayer || NotificationKind.iftar => 'mark:${prayer!.name}:${day.value}',
        NotificationKind.adhkarMorning => 'adhkar:morning',
        NotificationKind.adhkarEvening => 'adhkar:evening',
        NotificationKind.suhoor || NotificationKind.taraweeh => 'today',
      };

  @override
  String toString() => 'Planned($id, $kind, ${prayer?.name}, $at)';
}

/// Parsed notification tap payload.
sealed class NotificationPayload {
  const NotificationPayload();

  static NotificationPayload? parse(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    switch (parts.first) {
      case 'mark' when parts.length == 3:
        final p = Prayer.tryParse(parts[1]);
        if (p == null) return null;
        return MarkPayload(p, DayKey(parts[2]));
      case 'adhkar' when parts.length == 2:
        return AdhkarPayload(parts[1] == 'evening' ? AdhkarSet.evening : AdhkarSet.morning);
      case 'today':
        return const TodayPayload();
    }
    return null;
  }
}

class MarkPayload extends NotificationPayload {
  const MarkPayload(this.prayer, this.day);
  final Prayer prayer;
  final DayKey day;
}

class AdhkarPayload extends NotificationPayload {
  const AdhkarPayload(this.set);
  final AdhkarSet set;
}

class TodayPayload extends NotificationPayload {
  const TodayPayload();
}

/// Builds the list of notifications for the next [days] days.
///
/// * iOS allows 64 pending requests; we keep at most [maxPending] (60) so 4
///   stay free for "Remind me in 15 min".
/// * Period mode pauses prayer, suhoor, iftar and taraweeh alerts.
/// * In Ramadan with the iftar reminder on, the Maghrib alert becomes the
///   iftar notification (one notification, not two).
abstract final class NotificationPlanner {
  static const maxPending = 60;
  static const maxDays = 7;

  /// IDs at or above this are "remind me" notifications and are never
  /// cancelled by a reschedule.
  static const reminderIdBase = 900000;

  static List<PlannedNotification> plan({
    required PrayerEngine engine,
    required AppSettings settings,
    required DateTime now,
    required bool Function(DateTime localDate) isRamadan,
    int days = maxDays,
  }) {
    final out = <PlannedNotification>[];
    final start = engine.localDate(now);
    final paused = settings.periodMode;

    for (var i = 0; i < days.clamp(1, maxDays); i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final d = engine.day(date);
      final key = DayKey.fromDate(date);
      final ramadan = isRamadan(date);
      var slot = 0;
      int id() => i * 10 + slot++;

      if (!paused) {
        for (final p in Prayer.values) {
          final alert = settings.alertFor(p);
          final iftar = ramadan && settings.iftarReminder && p == Prayer.maghrib;
          if (alert == AlertType.off && !iftar) {
            slot++;
            continue;
          }
          out.add(PlannedNotification(
            id: id(),
            kind: iftar ? NotificationKind.iftar : NotificationKind.prayer,
            at: d[p],
            day: key,
            prayer: p,
            alert: alert == AlertType.off ? AlertType.silent : alert,
          ));
        }
      } else {
        slot += Prayer.values.length;
      }

      // Slots 5–9: extras.
      slot = 5;
      if (!paused && ramadan && settings.suhoorReminder) {
        out.add(PlannedNotification(
          id: id(),
          kind: NotificationKind.suhoor,
          at: d.fajr.subtract(Duration(minutes: settings.suhoorMinutes)),
          day: key,
          prayer: Prayer.fajr,
        ));
      } else {
        slot++;
      }
      if (!paused && ramadan && settings.taraweehReminder) {
        out.add(PlannedNotification(
          id: id(),
          kind: NotificationKind.taraweeh,
          at: d.isha.subtract(const Duration(minutes: 15)),
          day: key,
          prayer: Prayer.isha,
        ));
      } else {
        slot++;
      }
      if (settings.adhkarReminders) {
        out.add(PlannedNotification(
          id: id(),
          kind: NotificationKind.adhkarMorning,
          at: morningAdhkarTime(d),
          day: key,
        ));
        out.add(PlannedNotification(
          id: id(),
          kind: NotificationKind.adhkarEvening,
          at: eveningAdhkarTime(d),
          day: key,
        ));
      }
    }

    final future = out.where((n) => n.at.isAfter(now)).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
    return future.take(maxPending).toList();
  }

  /// Halfway between Fajr and sunrise (after the Fajr prayer, before the
  /// morning window closes).
  static DateTime morningAdhkarTime(PrayerDay d) =>
      d.fajr.add(Duration(seconds: d.sunrise.difference(d.fajr).inSeconds ~/ 2));

  /// 30 minutes after Asr, capped before Maghrib.
  static DateTime eveningAdhkarTime(PrayerDay d) {
    final t = d[Prayer.asr].add(const Duration(minutes: 30));
    final latest = d[Prayer.maghrib].subtract(const Duration(minutes: 10));
    return t.isBefore(latest) ? t : d[Prayer.asr];
  }
}
