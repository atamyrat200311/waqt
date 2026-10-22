import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/fast_repository.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../shared/widgets/status_marks.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';
import '../../today/domain/today_logic.dart';
import '../../today/presentation/mark_sheet.dart';
import '../domain/fast_day.dart';

/// Prayer times and one-tap worship tracking for a selected calendar day.
class PrayerTrackerCard extends ConsumerWidget {
  const PrayerTrackerCard({super.key, required this.day, required this.onFastDetails});

  final DayKey day;
  final VoidCallback onFastDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final today = ref.watch(todayKeyProvider);
    final now = ref.watch(prayerNowProvider);
    final times = ref.watch(prayerEngineProvider).day(day.date);
    final marks = ref.watch(dayMarksProvider(day)).value ?? const <Prayer, PrayerStatus>{};
    final fast = ref.watch(dayFastProvider(day)).value;
    final fastType =
        fast?.type ??
        fastTypeFor(
          ref.watch(hijriServiceProvider),
          day.date,
          ramadan: day == today && ref.watch(ramadanTodayProvider),
        );
    final completed = Prayer.obligatory.where((p) => marks[p]?.isPrayed == true).length;

    bool canEditPrayer(Prayer prayer) {
      if (marks[prayer] != null) return true;
      if (day.isBefore(today)) return true;
      return day == today && now.hasStarted(prayer);
    }

    Future<void> togglePrayer(Prayer prayer) async {
      if (!canEditPrayer(prayer)) return;
      Haptics.tap();
      final current = marks[prayer];
      await ref
          .read(prayerRepositoryProvider)
          .mark(day, prayer, current?.isPrayed == true ? null : PrayerStatus.prayed);
    }

    final canEditFast = !day.isAfter(today) || fast != null;
    Future<void> toggleFast() async {
      if (!canEditFast) return;
      Haptics.tap();
      await ref
          .read(fastRepositoryProvider)
          .set(day, fastType, fast?.status == FastStatus.fasted ? null : FastStatus.fasted);
    }

    return WaqtCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l.calendarTrackerTitle, style: WaqtType.sans(17, weight: 700, color: c.ink)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(20)),
                      child: Text('$completed/5', style: WaqtType.sans(13, weight: 700, color: c.brassText)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(l.longDate(day.date), style: WaqtType.sans(13, color: c.muted)),
                const SizedBox(height: 9),
                Row(
                  children: [
                    WaqtIcon(WaqtIcons.sun, size: 16, color: c.brass),
                    const SizedBox(width: 6),
                    Text(
                      '${l.prayerSunrise} ${hhmm(times.sunrise)}',
                      style: WaqtType.sans(12, weight: 600, color: c.muted, tabular: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: c.hairline),
          for (final prayer in Prayer.obligatory) ...[
            _PrayerTrackerRow(
              prayer: prayer,
              time: times[prayer],
              state: chipStateForDay(prayer, marks[prayer], now, day),
              enabled: canEditPrayer(prayer),
              onDetails: () => showMarkSheet(context, prayer, day),
              onToggle: () => togglePrayer(prayer),
            ),
            Divider(height: 1, thickness: 1, indent: 18, color: c.hairline),
          ],
          _PrayerTrackerRow(
            prayer: Prayer.witr,
            time: times[Prayer.witr],
            subtitle: l.witrSeparateHint,
            state: chipStateForDay(Prayer.witr, marks[Prayer.witr], now, day),
            enabled: canEditPrayer(Prayer.witr),
            onDetails: () => showMarkSheet(context, Prayer.witr, day),
            onToggle: () => togglePrayer(Prayer.witr),
          ),
          Divider(height: 1, thickness: 1, indent: 18, color: c.hairline),
          _FastTrackerRow(
            type: fastType,
            status: fast?.status,
            enabled: canEditFast,
            onDetails: onFastDetails,
            onToggle: toggleFast,
          ),
        ],
      ),
    );
  }
}

class _PrayerTrackerRow extends StatelessWidget {
  const _PrayerTrackerRow({
    required this.prayer,
    required this.time,
    this.subtitle,
    required this.state,
    required this.enabled,
    required this.onDetails,
    required this.onToggle,
  });

  final Prayer prayer;
  final DateTime time;
  final String? subtitle;
  final ChipState state;
  final bool enabled;
  final VoidCallback onDetails;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final checked = state == ChipState.done;
    return Material(
      color: checked ? c.brassSoft.withValues(alpha: c.isDark ? 0.34 : 0.48) : Colors.transparent,
      child: InkWell(
        onTap: enabled ? onDetails : null,
        child: SizedBox(
          height: subtitle == null ? 58 : 64,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 18, end: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.prayer(prayer), style: WaqtType.sans(16, weight: 600, color: c.ink)),
                        if (subtitle != null)
                          Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: WaqtType.sans(11, color: c.muted)),
                      ],
                    ),
                  ),
                  Text(
                    prayer == Prayer.witr ? l.homeAfterIshaKicker(hhmm(time)) : hhmm(time),
                    style: WaqtType.sans(13, weight: 500, color: c.muted, tabular: true),
                  ),
                  const SizedBox(width: 7),
                  _QuickCheck(
                    label: l.calendarTogglePrayer(l.prayer(prayer)),
                    checked: checked,
                    enabled: enabled,
                    state: state,
                    onPressed: onToggle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FastTrackerRow extends StatelessWidget {
  const _FastTrackerRow({
    required this.type,
    required this.status,
    required this.enabled,
    required this.onDetails,
    required this.onToggle,
  });

  final FastType type;
  final FastStatus? status;
  final bool enabled;
  final VoidCallback onDetails;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final checked = status == FastStatus.fasted;
    final state = switch (status) {
      FastStatus.fasted => ChipState.done,
      FastStatus.missed => ChipState.missed,
      FastStatus.excused => ChipState.excused,
      null => enabled ? ChipState.unmarked : ChipState.upcoming,
    };
    return Material(
      color: checked ? c.brassSoft.withValues(alpha: c.isDark ? 0.34 : 0.48) : Colors.transparent,
      child: InkWell(
        onTap: onDetails,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 18, end: 7),
            child: Row(
              children: [
                WaqtIcon(WaqtIcons.moon, size: 19, color: c.accent),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.calendarFast, style: WaqtType.sans(16, weight: 600, color: c.ink)),
                      const SizedBox(height: 2),
                      Text(l.fastType(type), style: WaqtType.sans(12, color: c.muted)),
                    ],
                  ),
                ),
                WaqtIcon(WaqtIcons.edit, size: 16, color: c.muted),
                const SizedBox(width: 5),
                _QuickCheck(
                  label: l.calendarToggleFast,
                  checked: checked,
                  enabled: enabled,
                  state: state,
                  onPressed: onToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCheck extends StatelessWidget {
  const _QuickCheck({
    required this.label,
    required this.checked,
    required this.enabled,
    required this.state,
    required this.onPressed,
  });

  final String label;
  final bool checked;
  final bool enabled;
  final ChipState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    checked: checked,
    enabled: enabled,
    label: label,
    excludeSemantics: true,
    child: IconButton(
      tooltip: label,
      onPressed: enabled ? onPressed : null,
      icon: _StateMark(state: state),
    ),
  );
}

class _StateMark extends StatelessWidget {
  const _StateMark({required this.state});

  final ChipState state;

  @override
  Widget build(BuildContext context) => switch (state) {
    ChipState.done => const DoneMark(size: 28, animate: false),
    ChipState.current => const CurrentMark(size: 28),
    ChipState.upcoming => const Opacity(opacity: 0.55, child: UpcomingMark(size: 28)),
    ChipState.unmarked => const UnmarkedMark(size: 28),
    ChipState.missed => const MissedMark(size: 28),
    ChipState.excused => const ExcusedMark(size: 28),
  };
}
