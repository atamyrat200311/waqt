import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/fast_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';
import '../domain/hijri_service.dart';

/// Fasts logged in an inclusive day range.
final fastsInRangeProvider = StreamProvider.family<Map<DayKey, FastLog>, (DayKey, DayKey)>(
  (ref, r) => ref.watch(fastRepositoryProvider).watchRange(r.$1, r.$2),
);

/// The voluntary-fast type that fits a day (Ramadan > white days > Mon/Thu).
FastType fastTypeFor(HijriService hijri, DateTime day, {required bool ramadan}) {
  final h = hijri.fromGregorian(day);
  if (ramadan || h.isRamadan) return FastType.ramadan;
  if (h.isWhiteDay) return FastType.whiteDays;
  if (day.weekday == DateTime.monday || day.weekday == DateTime.thursday) return FastType.monThu;
  return FastType.other;
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// (Hijri year, month) shown; null = month of today.
  (int, int)? _month;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final hijri = ref.watch(hijriServiceProvider);
    final today = ref.watch(todayKeyProvider);
    final th = hijri.fromGregorian(today.date);
    final (year, month) = _month ?? (th.year, th.month);
    final first = hijri.toGregorian(year, month, 1);
    final length = hijri.monthLength(year, month);
    final last = DateTime(first.year, first.month, first.day + length - 1);
    final fasts = ref.watch(fastsInRangeProvider((DayKey.fromDate(first), DayKey.fromDate(last)))).value ?? const {};

    void shift(int delta) {
      var m = month + delta;
      var y = year;
      if (m < 1) {
        m = 12;
        y--;
      } else if (m > 12) {
        m = 1;
        y++;
      }
      setState(() => _month = (y, m));
    }

    String short(DateTime d) => '${d.day} ${l.monthShort(monthKey(d))}';
    final range = l.calendarRange('$year', short(first), '${short(last)} ${last.year}');
    final events = upcomingEvents(hijri, today.date, limit: 5);

    return SubScreen(
      title: l.hijriMonthName(month, long: true),
      backLabel: l.tabTools,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.title, 4, 12, 0),
            child: Row(
              children: [
                Expanded(child: Text(range, style: WaqtType.sans(14, color: c.muted))),
                CircleIconButton(
                  icon: WaqtIcons.chevronLeft,
                  border: true,
                  foreground: c.muted,
                  iconSize: 20,
                  semanticLabel: l.calendarPrevMonth,
                  onPressed: () => shift(-1),
                ),
                const SizedBox(width: 4),
                CircleIconButton(
                  icon: WaqtIcons.chevronRight,
                  border: true,
                  foreground: c.ink,
                  iconSize: 20,
                  semanticLabel: l.calendarNextMonth,
                  onPressed: () => shift(1),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
            child: WaqtCard(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final k in weekdayKeys)
                        Expanded(
                          child: Text(
                            l.weekdayShort(k),
                            textAlign: TextAlign.center,
                            style: WaqtType.sans(12, weight: 600, color: c.muted),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _MonthGrid(
                    hYear: year,
                    hMonth: month,
                    first: first,
                    length: length,
                    today: today,
                    fasts: fasts,
                    onDay: (d) => showFastSheet(context, DayKey.fromDate(d)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _Legend(dot: _Dot.white, label: l.calendarWhiteDays),
                      _Legend(dot: _Dot.monThu, label: l.calendarMonThu),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SectionTitle(l.calendarUpcoming, size: 22, padding: const EdgeInsets.fromLTRB(22, 26, 22, 10))),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: WaqtGroup(
              children: [
                for (final e in events)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 64),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.event(e.event), style: WaqtType.sans(16, weight: 600, color: c.ink)),
                                const SizedBox(height: 2),
                                Text(
                                  '${e.event.day} ${l.hijriMonthName(e.event.month)} · '
                                  '${e.event.night ? l.calendarEveningOf(l.shortWeekdayDate(e.evening)) : l.shortWeekdayDate(e.date)}',
                                  style: WaqtType.sans(13, color: c.muted),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: '${e.daysAway}',
                                style: WaqtType.serif(26, tracking: -0.02, color: c.ink),
                              ),
                              TextSpan(
                                text: ' ${l.daysUnit(e.daysAway)}',
                                style: WaqtType.sans(12, color: c.muted),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
            child: Text(
              l.calendarMoonNote,
              textAlign: TextAlign.center,
              style: WaqtType.sans(13, color: c.muted, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

enum _Dot { white, monThu }

class _Legend extends StatelessWidget {
  const _Legend({required this.dot, required this.label});
  final _Dot dot;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dotWidget(c, dot, 6),
        const SizedBox(width: 6),
        Text(label, style: WaqtType.sans(12, color: c.muted)),
      ],
    );
  }
}

Widget _dotWidget(WaqtColors c, _Dot dot, double size, {double opacity = 1}) => Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dot == _Dot.white ? c.brass : null,
          border: dot == _Dot.monThu ? Border.all(color: c.accent, width: 1.5) : null,
        ),
      ),
    );

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({
    required this.hYear,
    required this.hMonth,
    required this.first,
    required this.length,
    required this.today,
    required this.fasts,
    required this.onDay,
  });

  final int hYear;
  final int hMonth;
  final DateTime first;
  final int length;
  final DayKey today;
  final Map<DayKey, FastLog> fasts;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lead = first.weekday - 1;
    final cells = lead + length;
    final rows = (cells / 7).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: Builder(builder: (context) {
                      final i = r * 7 + col - lead;
                      if (i < 0 || i >= length) return const SizedBox(height: 52);
                      final g = DateTime(first.year, first.month, first.day + i);
                      final key = DayKey.fromDate(g);
                      final hDay = i + 1;
                      final isToday = key == today;
                      final white = hDay >= 13 && hDay <= 15;
                      final monThu = col == 0 || col == 3;
                      final past = key.isBefore(today);
                      final fast = fasts[key];
                      final gLabel = g.day == 1 ? '${l.monthShort(monthKey(g))} 1' : '${g.day}';
                      return Semantics(
                        button: true,
                        selected: isToday,
                        label: '${l.hijriFull(hDay, hMonth, hYear)} · ${l.longDate(g)}',
                        excludeSemantics: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onDay(g),
                          child: SizedBox(
                            height: 52,
                            child: Center(
                              child: Container(
                                width: 46,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isToday ? c.primary : white ? c.brassSoft : null,
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$hDay',
                                            style: WaqtType.serif(
                                              19,
                                              height: 1,
                                              color: isToday
                                                  ? c.onPrimary
                                                  : white
                                                      ? c.brassText
                                                      : past
                                                          ? c.muted
                                                          : c.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            gLabel,
                                            maxLines: 1,
                                            style: WaqtType.sans(
                                              10,
                                              color: isToday ? c.onPrimary.withValues(alpha: 0.85) : c.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (fast != null)
                                      Positioned(
                                        top: 4,
                                        right: 5,
                                        child: WaqtIcon(
                                          fast.status == FastStatus.fasted ? WaqtIcons.check : WaqtIcons.minus,
                                          size: 11,
                                          strokeWidth: 3,
                                          color: isToday ? c.onPrimary : c.brass,
                                        ),
                                      )
                                    else if (!isToday && (white || monThu))
                                      Positioned(
                                        top: 5,
                                        right: 7,
                                        child: _dotWidget(
                                          c,
                                          white ? _Dot.white : _Dot.monThu,
                                          5,
                                          opacity: past && !white ? 0.45 : 1,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Log a fast for a day.
Future<void> showFastSheet(BuildContext context, DayKey day) =>
    Adaptive.showSheet<void>(context, builder: (_) => _FastSheet(day: day));

class _FastSheet extends ConsumerStatefulWidget {
  const _FastSheet({required this.day});
  final DayKey day;

  @override
  ConsumerState<_FastSheet> createState() => _FastSheetState();
}

class _FastSheetState extends ConsumerState<_FastSheet> {
  FastType? _type;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final hijri = ref.watch(hijriServiceProvider);
    final existing = (ref.watch(fastsInRangeProvider((widget.day, widget.day))).value ?? const {})[widget.day];
    final type = _type ??
        existing?.type ??
        fastTypeFor(hijri, widget.day.date, ramadan: ref.read(ramadanTodayProvider) && widget.day == ref.read(todayKeyProvider));
    final future = widget.day.isAfter(ref.watch(todayKeyProvider));
    final repo = ref.read(fastRepositoryProvider);

    Future<void> set(FastStatus? s) async {
      Haptics.tap();
      await repo.set(widget.day, type, s);
      if (context.mounted) await Navigator.of(context).maybePop();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.fastLogTitle(l.dayMonth(widget.day.date)), style: WaqtType.serif(28, tracking: -0.015, color: c.ink)),
          const SizedBox(height: 4),
          Text(
            () {
              final h = hijri.fromGregorian(widget.day.date);
              return l.hijriFull(h.day, h.month, h.year);
            }(),
            style: WaqtType.sans(14, color: c.muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in FastType.values)
                PillButton(
                  label: l.fastType(t),
                  style: t == type ? PillStyle.primary : PillStyle.fill,
                  height: 36,
                  fontSize: 13,
                  onPressed: () => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final s in FastStatus.values) ...[
                if (s != FastStatus.fasted) const SizedBox(width: 8),
                Expanded(
                  child: PillButton(
                    label: l.fastStatus(s),
                    style: existing?.status == s
                        ? (s == FastStatus.fasted ? PillStyle.brass : PillStyle.primary)
                        : (s == FastStatus.fasted ? PillStyle.brassSoft : PillStyle.mint),
                    height: 52,
                    radius: 16,
                    expand: true,
                    onPressed: future && s == FastStatus.fasted ? null : () => set(s),
                  ),
                ),
              ],
            ],
          ),
          if (existing != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => set(null),
              child: Text(l.fastClear, style: WaqtType.sans(15, weight: 600, color: c.muted)),
            ),
          ],
        ],
      ),
    );
  }
}
