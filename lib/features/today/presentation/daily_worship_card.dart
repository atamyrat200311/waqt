import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/fast_repository.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../calendar/domain/fast_day.dart';
import '../../prayer/application/prayer_providers.dart';
import '../application/today_providers.dart';

/// A compact, always-visible checklist for today's prayers and fast.
class DailyWorshipCard extends ConsumerWidget {
  const DailyWorshipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final day = ref.watch(todayKeyProvider);
    final now = ref.watch(prayerNowProvider);
    final marks = ref.watch(todayMarksProvider).value ?? const <Prayer, PrayerStatus>{};
    final fast = ref.watch(todayFastProvider).value;
    final fastType =
        fast?.type ?? fastTypeFor(ref.watch(hijriServiceProvider), day.date, ramadan: ref.watch(ramadanTodayProvider));
    final prayerCount = marks.values.where((status) => status.isPrayed).length;

    Future<void> togglePrayer(Prayer prayer) async {
      final current = marks[prayer];
      if (!now.hasStarted(prayer) && current == null) return;
      Haptics.tap();
      await ref
          .read(prayerRepositoryProvider)
          .mark(day, prayer, current?.isPrayed == true ? null : PrayerStatus.prayed);
    }

    Future<void> toggleFast() async {
      Haptics.tap();
      await ref
          .read(fastRepositoryProvider)
          .set(day, fastType, fast?.status == FastStatus.fasted ? null : FastStatus.fasted);
    }

    return WaqtCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: l.calendarOpenTracker,
            excludeSemantics: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push(Routes.calendar),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l.homeWorshipTitle, style: WaqtType.sans(17, weight: 700, color: c.ink)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(20)),
                        child: Text('$prayerCount/5', style: WaqtType.sans(13, weight: 700, color: c.brassText)),
                      ),
                      const SizedBox(width: 5),
                      WaqtIcon(WaqtIcons.chevronRight, size: 17, color: c.muted),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(l.homeWorshipHint, style: WaqtType.sans(13, color: c.muted)),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final prayer in Prayer.values)
                Expanded(
                  child: _PrayerCheck(
                    label: l.prayer(prayer),
                    checked: marks[prayer]?.isPrayed == true,
                    enabled: now.hasStarted(prayer) || marks[prayer] != null,
                    onTap: () => togglePrayer(prayer),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Divider(height: 1, thickness: 1, color: c.hairline),
          ),
          Semantics(
            label: l.ramadanTodayFast,
            button: true,
            checked: fast?.status == FastStatus.fasted,
            excludeSemantics: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: toggleFast,
                child: SizedBox(
                  height: 58,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: c.mint, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: WaqtIcon(WaqtIcons.moon, size: 18, color: c.onMint),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.ramadanTodayFast, style: WaqtType.sans(15, weight: 600, color: c.ink)),
                            const SizedBox(height: 2),
                            Text(l.fastType(fastType), style: WaqtType.sans(12, color: c.muted)),
                          ],
                        ),
                      ),
                      _CheckCircle(checked: fast?.status == FastStatus.fasted, enabled: true, size: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCheck extends StatelessWidget {
  const _PrayerCheck({required this.label, required this.checked, required this.enabled, required this.onTap});

  final String label;
  final bool checked;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: label,
      button: true,
      checked: checked,
      enabled: enabled,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CheckCircle(checked: checked, enabled: enabled),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: WaqtType.sans(
                  11,
                  weight: checked ? 650 : 500,
                  color: enabled ? c.ink : c.muted.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.checked, required this.enabled, this.size = 34});

  final bool checked;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: Adaptive.motion(context, 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? c.brass : Colors.transparent,
        border: Border.all(
          color: checked ? c.brass : c.controlOutline.withValues(alpha: enabled ? 1 : 0.4),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: checked ? WaqtIcon(WaqtIcons.check, size: size * 0.5, color: c.onBrassText, strokeWidth: 2.7) : null,
    );
  }
}
