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
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/rows.dart';
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';
import '../domain/ramadan.dart';

/// Ramadan mode, today's fast, the month's fasts and reminders.
class RamadanScreen extends ConsumerWidget {
  const RamadanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final settings = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final hijri = ref.watch(hijriServiceProvider);
    final today = ref.watch(todayKeyProvider);
    final info = ramadanDay(hijri, today.date);
    final active = ref.watch(ramadanTodayProvider);
    final bar = ref.watch(ramadanFastBarProvider).value;
    final todayFast = (ref.watch(fastsInRangeProvider((today, today))).value ?? const {})[today];
    final fajr = ref.watch(prayerNowProvider).today.fajr;

    return SubScreen(
      title: l.ramadanTitle,
      backLabel: l.tabTools,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.title, 8, Gap.title, 0),
            child: Text(
              info != null
                  ? l.ramadanDayOf('${info.day}', '${info.total}')
                  : l.ramadanInDays('${daysUntilRamadan(hijri, today.date)}'),
              style: WaqtType.sans(15, color: c.muted),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
          sliver: SliverList.list(children: [
            WaqtCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.ramadanMode, style: WaqtType.sans(16, weight: 600, color: c.ink)),
                  const SizedBox(height: 12),
                  Segmented<RamadanMode>(
                    value: settings.ramadanMode,
                    options: [
                      (RamadanMode.auto, l.ramadanAuto),
                      (RamadanMode.on, l.ramadanOn),
                      (RamadanMode.off, l.ramadanOff),
                    ],
                    onChanged: ctl.setRamadanMode,
                  ),
                  if (settings.ramadanMode == RamadanMode.auto && info == null) ...[
                    const SizedBox(height: 10),
                    Text(l.ramadanNotNow, style: WaqtType.sans(13, color: c.muted, height: 1.4)),
                  ],
                ],
              ),
            ),
            if (active) ...[
              const SizedBox(height: 12),
              WaqtCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.ramadanTodayFast, style: WaqtType.sans(16, weight: 600, color: c.ink)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final s in FastStatus.values) ...[
                          if (s != FastStatus.fasted) const SizedBox(width: 8),
                          Expanded(
                            child: PillButton(
                              label: l.fastStatus(s),
                              height: 48,
                              radius: 14,
                              expand: true,
                              style: todayFast?.status == s
                                  ? (s == FastStatus.fasted ? PillStyle.brass : PillStyle.primary)
                                  : (s == FastStatus.fasted ? PillStyle.brassSoft : PillStyle.fill),
                              onPressed: () {
                                Haptics.tap();
                                ref.read(fastRepositoryProvider).set(
                                      today,
                                      FastType.ramadan,
                                      todayFast?.status == s ? null : s,
                                    );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (bar != null) ...[
              const SizedBox(height: 12),
              WaqtCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(l.ramadanFasts, style: WaqtType.sans(16, weight: 600, color: c.ink))),
                        Text(
                          '${bar.fasts.where((f) => f == FastStatus.fasted).length} / ${bar.total}',
                          style: WaqtType.serif(22, color: c.ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (var i = 0; i < bar.total; i++)
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: i < bar.day ? () => showFastSheet(context, DayKey.fromDate(info!.first).addDays(i)) : null,
                            child: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: bar.fasts[i] == FastStatus.fasted
                                    ? c.brass
                                    : i == bar.day - 1
                                        ? c.mint
                                        : c.fill,
                              ),
                              child: Text(
                                '${i + 1}',
                                style: WaqtType.sans(
                                  12,
                                  weight: 600,
                                  color: bar.fasts[i] == FastStatus.fasted
                                      ? c.onBrassText
                                      : i < bar.day
                                          ? c.ink
                                          : c.muted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            WaqtGroup(children: [
              ToggleRow(
                value: settings.suhoorReminder,
                onChanged: ctl.setSuhoorReminder,
                title: l.ramadanSuhoorReminder,
                subtitle:
                    '${l.ramadanSuhoorBefore('${settings.suhoorMinutes}')} · ${hhmm(fajr.subtract(Duration(minutes: settings.suhoorMinutes)))}',
              ),
              if (settings.suhoorReminder)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Segmented<int>(
                    value: settings.suhoorMinutes,
                    options: [for (final m in const [15, 30, 45, 60]) (m, l.minutesShort('$m'))],
                    onChanged: ctl.setSuhoorMinutes,
                  ),
                ),
              ToggleRow(
                value: settings.iftarReminder,
                onChanged: ctl.setIftarReminder,
                title: l.ramadanIftarReminder,
              ),
              ToggleRow(
                value: settings.taraweehReminder,
                onChanged: ctl.setTaraweehReminder,
                title: l.ramadanTaraweehReminder,
              ),
            ]),
          ]),
        ),
      ],
    );
  }
}
