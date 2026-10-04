import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../adhkar/application/adhkar_providers.dart';
import '../../adhkar/domain/adhkar.dart';
import '../../calendar/domain/hijri_service.dart';
import '../../expenses/presentation/expense_sheet.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/application/prayer_providers.dart';
import '../application/today_providers.dart';
import '../domain/today_logic.dart';
import 'hero_card.dart';
import 'mark_sheet.dart';

/// Home ("Today" tab).
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key, this.markPrayer, this.markDay});

  /// Set by notification deep links: open the mark sheet for this prayer.
  final String? markPrayer;
  final String? markDay;

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  String? _handledLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleDeepLink());
  }

  @override
  void didUpdateWidget(TodayScreen old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleDeepLink());
  }

  void _handleDeepLink() {
    final p = Prayer.tryParse(widget.markPrayer);
    if (p == null || !mounted) return;
    final link = '${widget.markPrayer}:${widget.markDay}';
    if (_handledLink == link) return;
    _handledLink = link;
    final day = widget.markDay != null ? DayKey(widget.markDay!) : ref.read(todayKeyProvider);
    showMarkSheet(context, p, day);
  }

  void _mark(Prayer p, [DayKey? day]) => showMarkSheet(context, p, day ?? ref.read(todayKeyProvider));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final cupertino = Adaptive.isCupertino(context);

    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: cupertino
          ? null
          : _AddFab(label: l.add, onPressed: () => showExpenseSheet(context)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(cupertino: cupertino)),
          SliverToBoxAdapter(child: HeroCard(onChip: _mark)),
          SliverToBoxAdapter(child: _UnmarkedCard(onPrayer: (p, d) => _mark(p, d))),
          SliverToBoxAdapter(child: SectionTitle(l.homeYourDay)),
          const SliverToBoxAdapter(child: _DoneChips()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList.list(
              children: const [
                _UpNextCard(),
                _TaraweehCard(),
                _Tiles(),
                _QadaBanner(),
                _CalendarRow(),
              ],
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: cupertino ? 32 : 96)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- header

class _Header extends ConsumerWidget {
  const _Header({required this.cupertino});
  final bool cupertino;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final day = ref.watch(todayKeyProvider).date;
    final h = ref.watch(hijriServiceProvider).fromGregorian(day);
    final loc = ref.watch(settingsProvider.select((s) => s.effectiveLocation));
    final place = displayPlaceName(loc.name, l);
    final gDate = l.longDate(day);
    final hDate = l.hijriFull(h.day, h.month, h.year);
    final top = MediaQuery.paddingOf(context).top;

    final chip = _LocationChip(
      name: place,
      cupertino: cupertino,
      onTap: () => context.push(Routes.location),
    );

    if (cupertino) {
      return Padding(
        padding: EdgeInsets.fromLTRB(Gap.title, top + 4, Gap.title, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Flexible(child: chip),
                  const SizedBox(width: 12),
                  const Spacer(),
                  CircleIconButton(
                    icon: WaqtIcons.plus,
                    semanticLabel: l.homeAddExpense,
                    background: c.card,
                    border: true,
                    onPressed: () => showExpenseSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Semantics(header: true, child: Text(gDate, style: WaqtType.title(color: c.ink))),
            const SizedBox(height: 7),
            _HijriLine(text: hDate, size: 15, diamond: 6),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(Gap.title, top, 12, 8),
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      gDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtType.serif(24, tracking: -0.01, height: 1.15, color: c.ink),
                    ),
                  ),
                  const SizedBox(height: 3),
                  _HijriLine(text: hDate, size: 14, diamond: 5),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: chip),
          ],
        ),
      ),
    );
  }
}

class _HijriLine extends StatelessWidget {
  const _HijriLine({required this.text, required this.size, required this.diamond});
  final String text;
  final double size;
  final double diamond;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Transform.rotate(
          angle: 0.785398,
          child: Container(width: diamond, height: diamond, color: c.brass),
        ),
        SizedBox(width: diamond + 3),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WaqtType.sans(size, color: c.muted),
          ),
        ),
      ],
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.name, required this.cupertino, required this.onTap});
  final String name;
  final bool cupertino;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = BorderRadius.circular(cupertino ? Radii.pill : 8);
    return Semantics(
      button: true,
      label: '${context.l10n.location}: $name',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTouch),
        child: Center(
          widthFactor: 1,
          child: Material(
            color: cupertino ? c.card : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: r, side: BorderSide(color: c.hairline)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 14, 0),
                child: SizedBox(
                  height: cupertino ? 36 : 32,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WaqtIcon(WaqtIcons.pin, size: 16, color: c.accent),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WaqtType.sans(14, weight: 600, color: c.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.homeAddExpense,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F4C3A).withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 6)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 3, offset: const Offset(0, 1)),
          ],
        ),
        child: Material(
          color: c.mint,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 22, 0),
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WaqtIcon(WaqtIcons.plus, size: 22, color: c.onMint),
                    const SizedBox(width: 10),
                    Text(label, style: WaqtType.sans(15, weight: 600, color: c.onMint)),
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

// ------------------------------------------------------- yesterday card

class _UnmarkedCard extends ConsumerWidget {
  const _UnmarkedCard({required this.onPrayer});
  final void Function(Prayer, DayKey) onPrayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final prayers = ref.watch(yesterdayUnmarkedProvider).value ?? const [];
    if (prayers.isEmpty) return const SizedBox.shrink();
    final yesterday = ref.watch(todayKeyProvider).addDays(-1);

    Future<void> dismiss() async {
      await ref.read(settingsRepositoryProvider).setFlag('unmarkedDismissed', yesterday.value);
      ref.invalidate(yesterdayUnmarkedProvider);
    }

    Future<void> allPrayed() async {
      await ref.read(prayerRepositoryProvider).markMany(
        [for (final p in prayers) (yesterday, p)],
        PrayerStatus.onTime,
      );
      ref.invalidate(yesterdayUnmarkedProvider);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
      child: WaqtCard(
        color: c.brassSoft,
        border: false,
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l.homeUnmarkedTitle(l.joinList([for (final p in prayers) l.prayer(p)])),
                      style: WaqtType.sans(15, weight: 600, color: c.brassText),
                    ),
                  ),
                ),
                CircleIconButton(
                  icon: WaqtIcons.close,
                  size: 32,
                  iconSize: 15,
                  foreground: c.brassText,
                  semanticLabel: l.close,
                  onPressed: dismiss,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(l.homeUnmarkedBody, style: WaqtType.sans(13, color: c.muted, height: 1.4)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                PillButton(
                  label: l.homeUnmarkedAllPrayed,
                  style: PillStyle.brass,
                  height: 36,
                  fontSize: 13,
                  icon: WaqtIcons.check,
                  onPressed: allPrayed,
                ),
                for (final p in prayers)
                  PillButton(
                    label: l.prayer(p),
                    style: PillStyle.outline,
                    height: 36,
                    fontSize: 13,
                    onPressed: () => onPrayer(p, yesterday),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ your day

class _DoneChips extends ConsumerWidget {
  const _DoneChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final marks = ref.watch(todayMarksProvider).value ?? const {};
    final morning = ref.watch(adhkarTodayProvider(AdhkarSet.morning)).isComplete;
    final evening = ref.watch(adhkarTodayProvider(AdhkarSet.evening)).isComplete;
    final items = <String>[];
    for (final p in Prayer.values) {
      if (marks[p]?.isPrayed ?? false) items.add(l.prayer(p));
      if (p == Prayer.fajr && morning) items.add(l.adhkarMorning);
      if (p == Prayer.asr && evening) items.add(l.adhkarEvening);
    }
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final t in items)
            Container(
              height: 30,
              padding: const EdgeInsetsDirectional.fromSTEB(9, 0, 12, 0),
              decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(Radii.pill)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WaqtIcon(WaqtIcons.check, size: 14, color: c.brass, strokeWidth: 2.6),
                  const SizedBox(width: 6),
                  Text(t, style: WaqtType.sans(13, weight: 500, color: c.muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Spaced extends StatelessWidget {
  const _Spaced({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: child);
}

class _UpNextCard extends ConsumerWidget {
  const _UpNextCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final now = ref.watch(prayerNowProvider);
    final morning = ref.watch(adhkarTodayProvider(AdhkarSet.morning));
    final evening = ref.watch(adhkarTodayProvider(AdhkarSet.evening));
    final set = adhkarUpNext(now, morningDone: morning.isComplete, eveningDone: evening.isComplete);
    if (set == null) return const SizedBox.shrink();
    final progress = set == AdhkarSet.morning ? morning : evening;
    final minutes = AdhkarProgress.estimatedMinutes(progress.items);
    final window = set == AdhkarSet.morning ? l.winAfterFajr : l.winAfterAsr;

    return _Spaced(
      child: WaqtCard(
        color: c.mint,
        border: false,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 14, 14),
        child: Row(
          children: [
            IconTile(icon: WaqtIcons.book, background: c.card, color: c.onMint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(l.homeUpNext, color: c.onMint),
                  const SizedBox(height: 2),
                  Text(l.adhkarSet(set), style: WaqtType.item(color: c.ink)),
                  const SizedBox(height: 1),
                  Text(l.homeAdhkarAfter(window, '$minutes'), style: WaqtType.sans(13, color: c.muted)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            PillButton(
              label: l.homeStart,
              onPressed: () => context.push(Routes.adhkar(set.name)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaraweehCard extends ConsumerWidget {
  const _TaraweehCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(ramadanTodayProvider)) return const SizedBox.shrink();
    final c = context.colors;
    final l = context.l10n;
    final isha = ref.watch(prayerNowProvider).today.isha;
    final on = ref.watch(settingsProvider.select((s) => s.taraweehReminder));
    final remindAt = hhmm(isha.subtract(const Duration(minutes: 15)));
    return _Spaced(
      child: WaqtCard(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 14, 14),
        child: Row(
          children: [
            const IconTile(icon: WaqtIcons.moon, iconSize: 21),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(l.homeAfterIshaKicker(hhmm(isha))),
                  const SizedBox(height: 2),
                  Text(l.homeTaraweeh, style: WaqtType.item(color: c.ink)),
                  const SizedBox(height: 1),
                  Text(l.homeTaraweehSub(remindAt), style: WaqtType.sans(13, color: c.muted)),
                ],
              ),
            ),
            Semantics(
              toggled: on,
              child: CircleIconButton(
                icon: on ? WaqtIcons.bell : WaqtIcons.bellOff,
                iconSize: 20,
                semanticLabel: l.ramadanTaraweehReminder,
                background: on ? c.mint : Colors.transparent,
                foreground: on ? c.onMint : c.muted,
                border: !on,
                onPressed: () => ref.read(settingsProvider.notifier).setTaraweehReminder(!on),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tiles extends ConsumerWidget {
  const _Tiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final expenses = ref.watch(todayExpensesProvider).value ?? const <Expense>[];
    final sum = ExpenseSummary.of(expenses);
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final tasks = ref.watch(todayTasksProvider).value ?? const [];
    final done = tasks.where((t) => t.done).length;

    Widget tile({required VoidCallback onTap, required String label, required WaqtIconData icon, required Widget body}) =>
        Expanded(
          child: WaqtCard(
            onTap: onTap,
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label, style: WaqtType.sans(13, weight: 500, color: c.muted))),
                      WaqtIcon(icon, size: icon == WaqtIcons.plus ? 18 : 16, color: icon == WaqtIcons.plus ? c.accent : c.muted),
                    ],
                  ),
                  const SizedBox(height: 18),
                  body,
                ],
              ),
            ),
          ),
        );

    return _Spaced(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tile(
              onTap: () => showExpenseSheet(context),
              label: l.homeSpentToday,
              icon: WaqtIcons.plus,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            formatMinor(sum.totalMinor),
                            style: WaqtType.serif(34, tracking: -0.02, height: 1, color: c.ink),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(currency, style: WaqtType.sans(13, weight: 600, color: c.muted)),
                    ],
                  ),
                  if (sum.sadaqaMinor > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        WaqtIcon(WaqtIcons.heart, size: 13, color: c.brass),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            l.homeInclSadaqa(formatMinor(sum.sadaqaMinor)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtType.sans(12, color: c.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            tile(
              onTap: () => context.push(Routes.tasks),
              label: l.homeTasks,
              icon: WaqtIcons.chevronRight,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$done', style: WaqtType.serif(34, tracking: -0.02, height: 1, color: c.ink)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l.homeTasksOf('${tasks.length}'),
                          style: WaqtType.sans(14, weight: 500, color: c.muted),
                        ),
                      ),
                    ],
                  ),
                  if (tasks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < tasks.length.clamp(0, 8); i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: i < done ? c.accent : c.hairline,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QadaBanner extends ConsumerWidget {
  const _QadaBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(qadaTotalProvider);
    if (total == 0) return const SizedBox.shrink();
    final c = context.colors;
    final l = context.l10n;
    return _Spaced(
      child: WaqtCard(
        color: c.brassSoft,
        border: false,
        onTap: () => context.push(Routes.qada),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              WaqtIcon(WaqtIcons.qada, size: 20, color: c.brassText),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.homeQadaRemaining(total),
                  style: WaqtType.sans(15, weight: 600, color: c.brassText),
                ),
              ),
              Text(l.homeMakeUp, style: WaqtType.sans(14, weight: 600, color: c.brassText)),
              const SizedBox(width: 2),
              WaqtIcon(WaqtIcons.chevronRight, size: 16, color: c.brassText, strokeWidth: 2.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarRow extends ConsumerWidget {
  const _CalendarRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final day = ref.watch(todayKeyProvider).date;
    final hijri = ref.watch(hijriServiceProvider);
    final events = upcomingEvents(hijri, day, limit: 6);
    if (events.isEmpty) return const SizedBox.shrink();
    final a = events.first;
    final inRamadan = hijri.fromGregorian(day).isRamadan;
    final ramadan = events.where((e) => e.event == IslamicEvent.ramadan && e != a);
    final b = !inRamadan && ramadan.isNotEmpty ? ramadan.first : (events.length > 1 ? events[1] : null);
    String line(UpcomingEvent e) => l.eventCountdown(e.daysAway, l.event(e.event));

    return _Spaced(
      child: WaqtCard(
        onTap: () => context.push(Routes.calendar),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const IconTile(icon: WaqtIcons.moon, small: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line(a), style: WaqtType.sans(15, weight: 600, color: c.ink)),
                  if (b != null) ...[
                    const SizedBox(height: 2),
                    Text(line(b), style: WaqtType.sans(13, color: c.muted)),
                  ],
                ],
              ),
            ),
            WaqtIcon(WaqtIcons.chevronRight, size: 16, color: c.muted),
          ],
        ),
      ),
    );
  }
}
