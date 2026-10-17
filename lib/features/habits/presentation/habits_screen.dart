import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/status_marks.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../application/habit_providers.dart';

const habitIcons = [
  'quran',
  'book',
  'beads',
  'heart',
  'droplet',
  'dumbbell',
  'leaf',
  'pen',
  'smile',
  'family',
  'sun',
  'moon',
  'wallet',
  'clock',
];

/// Daily habits with a check per day, 7-day dots and a streak.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final views = ref.watch(habitViewsProvider);
    final today = ref.watch(todayKeyProvider);
    final (done, total) = ref.watch(habitsTodayProvider);

    return SubScreen(
      title: l.habitsTitle,
      backLabel: l.tabToday,
      titleTrailing: total == 0
          ? null
          : Text(l.habitsDoneToday('$done', '$total'), style: WaqtType.sans(14, color: c.muted)),
      trailing: CircleIconButton(
        icon: WaqtIcons.plus,
        semanticLabel: l.habitsAdd,
        background: c.card,
        border: true,
        onPressed: () => showHabitEditor(context),
      ),
      slivers: [
        if (views.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: WaqtIcons.sparkles,
              text: l.habitsEmpty,
              action: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final (text, icon) in [
                        (l.habitSugQuran, 'quran'),
                        (l.habitSugWater, 'droplet'),
                        (l.habitSugWalk, 'dumbbell'),
                        (l.habitSugParents, 'family'),
                        (l.habitSugGratitude, 'pen'),
                        (l.habitSugRead, 'book'),
                      ])
                        ActionChip(
                          avatar: WaqtIcon(WaqtIcons.byKey(icon), size: 16, color: c.onMint),
                          label: Text(text),
                          onPressed: () {
                            Haptics.success();
                            ref.read(habitRepositoryProvider).add(text, icon);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PillButton(
                    label: l.habitsAdd,
                    icon: WaqtIcons.plus,
                    style: PillStyle.fill,
                    onPressed: () => showHabitEditor(context),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 14, Gap.screen, 0),
            sliver: SliverList.separated(
              itemCount: views.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final v = views[i];
                final week = lastDays(today, 7);
                return WaqtCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  onTap: () => showHabitEditor(context, existing: v),
                  child: Row(
                    children: [
                      IconTile(
                        icon: WaqtIcons.byKey(v.habit.icon),
                        small: true,
                        background: v.doneToday ? c.brassSoft : c.mint,
                        color: v.doneToday ? c.brassText : c.onMint,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.habit.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: WaqtType.sans(16, weight: 600, color: c.ink),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                for (final d in week)
                                  Container(
                                    width: 9,
                                    height: 9,
                                    margin: const EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: v.days.contains(d.value) ? c.brass : c.fill,
                                      border: d == today ? Border.all(color: c.muted.withValues(alpha: 0.5)) : null,
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                if (v.streak > 0) ...[
                                  WaqtIcon(WaqtIcons.flame, size: 13, color: c.brass),
                                  const SizedBox(width: 2),
                                  Text('${v.streak}', style: WaqtType.sans(12.5, weight: 700, color: c.brassText)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        button: true,
                        checked: v.doneToday,
                        label: v.habit.title,
                        excludeSemantics: true,
                        child: InkResponse(
                          radius: 28,
                          onTap: () {
                            v.doneToday ? Haptics.light() : Haptics.success();
                            ref.read(habitRepositoryProvider).setDone(v.habit.id, today, !v.doneToday);
                          },
                          child: SizedBox.square(
                            dimension: 52,
                            child: Center(
                              child: v.doneToday
                                  ? const DoneMark(size: 34)
                                  : UpcomingMark(size: 34, color: c.muted, strokeWidth: 1.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Add or edit a habit (title, icon, suggestions; delete when editing).
Future<void> showHabitEditor(BuildContext context, {HabitView? existing}) =>
    Adaptive.showSheet<void>(context, builder: (ctx) => _Editor(existing: existing));

class _Editor extends ConsumerStatefulWidget {
  const _Editor({this.existing});
  final HabitView? existing;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final _title = TextEditingController(text: widget.existing?.habit.title ?? '');
  late String _icon = widget.existing?.habit.icon ?? 'quran';

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    final repo = ref.read(habitRepositoryProvider);
    if (widget.existing == null) {
      await repo.add(t, _icon);
    } else {
      await repo.rename(widget.existing!.habit.id, t, _icon);
    }
    Haptics.success();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final suggestions = <(String, String)>[
      (l.habitSugQuran, 'quran'),
      (l.habitSugDhikr, 'beads'),
      (l.habitSugWater, 'droplet'),
      (l.habitSugWalk, 'dumbbell'),
      (l.habitSugSadaqa, 'heart'),
      (l.habitSugParents, 'family'),
      (l.habitSugGratitude, 'pen'),
      (l.habitSugRead, 'book'),
      (l.habitSugSleep, 'moon'),
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.existing == null ? l.habitsAdd : l.edit, style: WaqtType.serif(24, weight: 500, color: c.ink)),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            autofocus: widget.existing == null,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              hintText: l.habitsNameHint,
              filled: true,
              fillColor: c.fill,
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in habitIcons)
                Semantics(
                  button: true,
                  selected: key == _icon,
                  label: key,
                  child: InkResponse(
                    onTap: () => setState(() => _icon = key),
                    radius: 24,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: key == _icon ? c.mint : c.fill,
                        borderRadius: BorderRadius.circular(14),
                        border: key == _icon ? Border.all(color: c.primary, width: 1.5) : null,
                      ),
                      child: Center(
                        child: WaqtIcon(WaqtIcons.byKey(key), size: 20, color: key == _icon ? c.onMint : c.muted),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (widget.existing == null) ...[
            const SizedBox(height: 16),
            Kicker(l.habitsSuggestions),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (text, icon) in suggestions)
                  ActionChip(
                    label: Text(text),
                    onPressed: () => setState(() {
                      _title.text = text;
                      _icon = icon;
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          BigButton(label: l.save, onPressed: _save),
          if (widget.existing != null) ...[
            const SizedBox(height: 8),
            PillButton(
              label: l.delete,
              style: PillStyle.ghost,
              onPressed: () async {
                await ref.read(habitRepositoryProvider).delete(widget.existing!.habit.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
