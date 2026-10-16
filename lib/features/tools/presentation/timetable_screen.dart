import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';

/// Month of prayer times at the saved location, shareable as text.
class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final engine = ref.watch(prayerEngineProvider);
    final today = ref.watch(todayKeyProvider);
    final hijri = ref.watch(hijriServiceProvider);
    final place = ref.watch(settingsProvider.select((s) => s.effectiveLocation.name));
    final base = today.date;
    final month = DateTime(base.year, base.month + _offset);
    final daysIn = DateTime(month.year, month.month + 1, 0).day;
    final days = [for (var d = 1; d <= daysIn; d++) engine.day(DateTime(month.year, month.month, d))];
    final title = '${l.monthName(monthKey(month))} ${month.year}';
    const cols = [null, Prayer.fajr, 'sunrise', Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];

    String header(Object? col) => switch (col) {
          null => '',
          'sunrise' => l.prayerSunrise,
          final Prayer p => l.prayer(p),
          _ => '',
        };

    String asText() {
      final b = StringBuffer('${l.timetableTitle} · $place · $title\n\n');
      for (final d in days) {
        final times = [d.fajr, d.sunrise, d[Prayer.dhuhr], d[Prayer.asr], d[Prayer.maghrib], d.isha].map(hhmm).join('  ');
        b.writeln('${d.date.day.toString().padLeft(2)}  $times');
      }
      b.write('\n${header(Prayer.fajr)} · ${header('sunrise')} · ${header(Prayer.dhuhr)} · ${header(Prayer.asr)} · ${header(Prayer.maghrib)} · ${header(Prayer.isha)}\n— Waqt');
      return b.toString();
    }

    return SubScreen(
      title: l.timetableTitle,
      backLabel: l.tabTools,
      trailing: CircleIconButton(
        icon: WaqtIcons.share,
        semanticLabel: l.share,
        background: c.card,
        border: true,
        onPressed: () => shareText(context, asText()),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 8, Gap.screen, 10),
            child: Row(
              children: [
                CircleIconButton(
                  icon: WaqtIcons.chevronLeft,
                  semanticLabel: l.back,
                  onPressed: () {
                    Haptics.tap();
                    setState(() => _offset--);
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(title, style: WaqtType.serif(20, weight: 500, color: c.ink)),
                      Text(place, style: WaqtType.sans(13, color: c.muted)),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: WaqtIcons.chevronRight,
                  semanticLabel: l.next,
                  onPressed: () {
                    Haptics.tap();
                    setState(() => _offset++);
                  },
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(Radii.card(context)),
              border: Border.all(color: c.hairline),
            ),
            sliver: SliverList.builder(
              itemCount: days.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                    child: Row(
                      children: [
                        for (final col in cols)
                          Expanded(
                            flex: col == null ? 5 : 4,
                            child: Text(
                              header(col),
                              textAlign: col == null ? TextAlign.start : TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: WaqtType.sans(10.5, weight: 700, color: c.muted),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                final d = days[i - 1];
                final isToday = DayKey.fromDate(d.date) == today;
                final h = hijri.fromGregorian(d.date);
                final friday = d.date.weekday == DateTime.friday;
                final times = [d.fajr, d.sunrise, d[Prayer.dhuhr], d[Prayer.asr], d[Prayer.maghrib], d.isha];
                return Container(
                  color: isToday ? c.mint : null,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${d.date.day} ${l.weekdayShort(weekdayKey(d.date))}',
                              style: WaqtType.sans(13, weight: isToday || friday ? 700 : 600, color: isToday ? c.onMint : (friday ? c.accent : c.ink)),
                            ),
                            Text('${h.day}', style: WaqtType.sans(10.5, color: c.muted)),
                          ],
                        ),
                      ),
                      for (final t in times)
                        Expanded(
                          flex: 4,
                          child: Text(
                            hhmm(t),
                            textAlign: TextAlign.center,
                            style: WaqtType.sans(12.5, weight: isToday ? 700 : 500, color: isToday ? c.onMint : c.ink, tabular: true),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
            child: Text(l.timetableNote, style: WaqtType.sans(12.5, color: c.muted, height: 1.4)),
          ),
        ),
      ],
    );
  }
}
