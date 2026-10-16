import 'dart:async';

import '../../../core/utils/dates.dart';
import '../../../data/repositories/quran_repository.dart';

/// Decides when ayahs count as "read" and batches the writes.
///
/// The reader calls [tick] about once a second with the ayahs that are
/// currently on screen. An ayah that stays visible for [dwellTicks] ticks is
/// recorded — fast scrolling never counts, a normal reading pace always does.
class ReadTracker {
  ReadTracker({
    required this.repository,
    required this.today,
    this.dwellTicks = 2,
    this.flushEvery = 5,
  });

  final QuranRepository repository;
  final DayKey Function() today;
  final int dwellTicks;
  final int flushEvery;

  final Map<int, int> _seen = {};
  final Set<int> _pending = {};
  final Set<int> _recorded = {};
  int _ticks = 0;

  /// Ayahs recorded during this session (for the "read" ticks in the UI).
  Set<int> get recorded => _recorded;

  void tick(Iterable<int> visible) {
    final now = visible.toSet();
    _seen.removeWhere((k, _) => !now.contains(k));
    for (final a in now) {
      final n = (_seen[a] ?? 0) + 1;
      _seen[a] = n;
      if (n == dwellTicks && _recorded.add(a)) _pending.add(a);
    }
    if (++_ticks % flushEvery == 0) unawaited(flush());
  }

  /// Marks a whole range at once (Mushaf page viewed long enough).
  void markAll(Iterable<int> ayahs) {
    for (final a in ayahs) {
      if (_recorded.add(a)) _pending.add(a);
    }
  }

  Future<void> flush() async {
    if (_pending.isEmpty) return;
    final batch = _pending.toList();
    _pending.clear();
    await repository.markRead(today(), batch);
  }
}
