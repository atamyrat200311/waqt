import '../../../data/db/enums.dart';

/// Pure qada rules (unit tested in test/qada_rules_test.dart).
abstract final class QadaRules {
  /// How the qada count for a prayer changes when its mark goes from [from] to
  /// [to] (null = unmarked). Only `missed` ever creates qada; `excused` (period
  /// mode) and unmarked prayers never do.
  static int deltaForTransition(PrayerStatus? from, PrayerStatus? to) {
    final before = from == PrayerStatus.missed ? 1 : 0;
    final after = to == PrayerStatus.missed ? 1 : 0;
    return after - before;
  }

  /// Applies [delta] to [remaining], never going below zero.
  static int apply(int remaining, int delta) {
    final next = remaining + delta;
    return next < 0 ? 0 : next;
  }

  /// Making up one prayer: returns null when there is nothing to make up.
  static int? makeUp(int remaining) => remaining > 0 ? remaining - 1 : null;
}
