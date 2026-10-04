import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/status_marks.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../prayer/domain/prayer_engine.dart';
import '../application/today_providers.dart';

/// Opens the "mark a prayer" sheet for [prayer] on [day].
Future<void> showMarkSheet(BuildContext context, Prayer prayer, DayKey day) =>
    Adaptive.showSheet<void>(context, builder: (_) => MarkSheet(prayer: prayer, day: day));

class MarkSheet extends ConsumerStatefulWidget {
  const MarkSheet({super.key, required this.prayer, required this.day});

  final Prayer prayer;
  final DayKey day;

  @override
  ConsumerState<MarkSheet> createState() => _MarkSheetState();
}

class _MarkSheetState extends ConsumerState<MarkSheet> {
  PrayerStatus? _picked;
  bool _askConfirm = false;
  bool _added = false;
  String? _reminderAt;
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  void _closeAfter(int ms) {
    _closeTimer?.cancel();
    _closeTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) unawaited(Navigator.of(context).maybePop());
    });
  }

  Future<void> _pick(PrayerStatus s) async {
    if (s == PrayerStatus.missed) {
      setState(() {
        _picked = s;
        _askConfirm = true;
        _added = false;
      });
      Haptics.tap();
      return;
    }
    setState(() {
      _picked = s;
      _askConfirm = false;
    });
    Haptics.success();
    await ref.read(prayerRepositoryProvider).mark(widget.day, widget.prayer, s);
    _closeAfter(750);
  }

  Future<void> _confirmMissed() async {
    await ref.read(prayerRepositoryProvider).mark(widget.day, widget.prayer, PrayerStatus.missed);
    Haptics.light();
    setState(() {
      _askConfirm = false;
      _added = true;
    });
    _closeAfter(900);
  }

  Future<void> _clear() async {
    await ref.read(prayerRepositoryProvider).mark(widget.day, widget.prayer, null);
    if (mounted) unawaited(Navigator.of(context).maybePop());
  }

  Future<void> _remind() async {
    final l = context.l10n;
    final engine = ref.read(prayerEngineProvider);
    final at = await ref.read(notificationServiceProvider).remindIn(
          widget.prayer,
          widget.day,
          l10n: l,
          now: ref.read(clockProvider)(),
        );
    if (!mounted) return;
    setState(() => _reminderAt = hhmm(engine.localTime(at)));
    _closeAfter(700);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final engine = ref.watch(prayerEngineProvider);
    final now = ref.watch(prayerNowProvider).now;
    final marks = ref.watch(dayMarksProvider(widget.day)).value ?? const {};
    final status = marks[widget.prayer];
    final selected = _picked ?? status;
    final periodMode = ref.watch(settingsProvider.select((s) => s.periodMode));
    final isToday = widget.day == ref.watch(todayKeyProvider);

    final window = engine.window(widget.day.date, widget.prayer);
    final started = !window.start.isAfter(now);
    final note = _windowNote(l, window, now);
    final name = l.prayer(widget.prayer);

    final options = <(PrayerStatus, WaqtIconData, String, String)>[
      (PrayerStatus.onTime, WaqtIcons.check, l.markOnTime, l.markOnTimeSub(name)),
      (PrayerStatus.congregation, WaqtIcons.users, l.markCongregation, l.markCongregationSub),
      (PrayerStatus.late, WaqtIcons.clock, l.markLate, l.markLateSub),
      (PrayerStatus.missed, WaqtIcons.qada, l.markMissed, l.markMissedSub),
      if (periodMode || status == PrayerStatus.excused)
        (PrayerStatus.excused, WaqtIcons.moon, l.markExcused, l.markExcusedSub),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(name, style: WaqtType.serif(34, tracking: -0.015, height: 1.05, color: c.ink)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${l.winRange(hhmm(window.start), hhmm(window.end))} · $note',
                      style: WaqtType.sans(15, color: c.muted),
                    ),
                  ],
                ),
              ),
              CircleIconButton(
                icon: WaqtIcons.close,
                size: 36,
                iconSize: 16,
                background: c.fill,
                foreground: c.muted,
                semanticLabel: l.close,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (!started) ...[
            Text(l.markNotStarted, style: WaqtType.sans(14, color: c.muted)),
            const SizedBox(height: 12),
          ],
          for (final (s, icon, title, sub) in options) ...[
            _OptionTile(
              icon: icon,
              title: title,
              subtitle: sub,
              brass: s == PrayerStatus.missed,
              selected: _askConfirm ? s == PrayerStatus.missed : selected == s,
              enabled: started,
              onTap: () => _pick(s),
            ),
            const SizedBox(height: 10),
          ],
          MotionSize(
            ms: 250,
            child: _askConfirm
                ? _ConfirmPanel(
                    prayerName: name,
                    onCancel: () => setState(() {
                      _askConfirm = false;
                      _picked = null;
                    }),
                    onConfirm: _confirmMissed,
                  )
                : _added
                    ? _BrassNote(text: l.markAdded)
                    : const SizedBox(width: double.infinity),
          ),
          if (status != null && !_askConfirm && !_added)
            TextButton(
              onPressed: _clear,
              child: Text(l.markClear, style: WaqtType.sans(15, weight: 600, color: c.muted)),
            )
          else if (isToday && status == null && !_added)
            SizedBox(
              height: 48,
              child: TextButton.icon(
                onPressed: _reminderAt == null ? _remind : null,
                icon: WaqtIcon(WaqtIcons.bell, size: 18, color: c.accent),
                label: Text(
                  _reminderAt == null ? l.markRemind : l.markReminderSet(_reminderAt!),
                  style: WaqtType.sans(15, weight: 600, color: c.accent),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _windowNote(AppLocalizations l, PrayerWindow w, DateTime now) {
    if (w.start.isAfter(now)) return l.markOpensAt(hhmm(w.start));
    if (w.contains(now)) return l.markLeft(l.duration(w.end.difference(now)));
    if (w.prayer == Prayer.fajr) return l.markClosedAtSunrise;
    return l.markClosedAt(hhmm(w.end));
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.brass,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final WaqtIconData icon;
  final String title;
  final String subtitle;
  final bool brass;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = BorderRadius.circular(20);
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: AnimatedContainer(
          duration: Adaptive.motion(context, 200),
          constraints: const BoxConstraints(minHeight: 68),
          decoration: BoxDecoration(
            borderRadius: r,
            color: selected ? (brass ? c.brassSoft : c.mint) : c.card,
            border: Border.all(
              width: 1.5,
              color: selected ? (brass ? c.brass : c.accent) : c.hairline,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: r,
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: brass ? c.brassSoft : c.mint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: WaqtIcon(icon, size: 20, color: brass ? c.brassText : c.onMint),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: WaqtType.sans(16, weight: 600, color: c.ink)),
                          const SizedBox(height: 2),
                          Text(subtitle, style: WaqtType.sans(13, color: c.muted)),
                        ],
                      ),
                    ),
                    if (selected)
                      DoneMark(
                        size: 26,
                        color: brass ? c.brassText : c.brass,
                        checkColor: brass ? c.onBrassText : c.hero,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmPanel extends StatelessWidget {
  const _ConfirmPanel({required this.prayerName, required this.onCancel, required this.onConfirm});
  final String prayerName;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final panel = Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.markConfirmTitle(prayerName), style: WaqtType.sans(15, weight: 600, color: c.brassText)),
          const SizedBox(height: 4),
          Text(l.markConfirmBody, style: WaqtType.sans(13, color: c.muted, height: 1.45)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: c.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: c.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onCancel,
                    child: SizedBox(
                      height: 46,
                      child: Center(child: Text(l.notNow, style: WaqtType.sans(15, weight: 600, color: c.ink))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PillButton(
                  label: l.markAddToQada,
                  onPressed: onConfirm,
                  style: PillStyle.brass,
                  height: 46,
                  radius: 14,
                  expand: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (Adaptive.reduceMotion(context)) return panel;
    return panel.animate().slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut).fadeIn(duration: 300.ms);
  }
}

class _BrassNote extends StatelessWidget {
  const _BrassNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: WaqtType.sans(14, weight: 600, color: c.brassText)),
    );
  }
}
