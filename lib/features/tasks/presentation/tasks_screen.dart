import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/status_marks.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';
import '../../today/domain/today_logic.dart';

final overdueTasksProvider = StreamProvider<List<Task>>(
  (ref) => ref.watch(taskRepositoryProvider).watchOverdue(ref.watch(todayKeyProvider)),
);

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final tasks = ref.watch(todayTasksProvider).value ?? const <Task>[];
    final overdue = ref.watch(overdueTasksProvider).value ?? const <Task>[];
    final done = tasks.where((t) => t.done).length;
    final day = ref.watch(prayerNowProvider).today;

    final groups = <TaskWindow, List<Task>>{};
    for (final t in tasks) {
      (groups[t.window] ??= []).add(t);
    }

    String span(TaskWindow w) {
      final (from, until) = taskWindowSpan(w, day);
      if (from != null && until != null) return l.winRange(hhmm(from), hhmm(until));
      if (until != null) return l.winUntil(hhmm(until));
      if (from != null) return l.winFrom(hhmm(from));
      return '';
    }

    return SubScreen(
      title: l.tasksTitle,
      backLabel: l.tabToday,
      titleTrailing: tasks.isEmpty
          ? null
          : Text(l.tasksDoneOf('$done', '${tasks.length}'), style: WaqtType.sans(14, color: c.muted)),
      bottom: const _AddBar(),
      slivers: [
        if (overdue.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
              child: WaqtCard(
                color: c.brassSoft,
                border: false,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.tasksOverdue(overdue.length),
                        style: WaqtType.sans(14, weight: 600, color: c.brassText),
                      ),
                    ),
                    PillButton(
                      label: l.tasksMoveToday,
                      style: PillStyle.brass,
                      height: 36,
                      fontSize: 13,
                      icon: WaqtIcons.moveToday,
                      onPressed: () => ref
                          .read(taskRepositoryProvider)
                          .moveTo(overdue.map((t) => t.id), ref.read(todayKeyProvider)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (tasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
              child: Text(
                l.tasksEmpty,
                textAlign: TextAlign.center,
                style: WaqtType.sans(15, color: c.muted, height: 1.5),
              ),
            ),
          ),
        for (final w in TaskWindow.values)
          if (groups[w] != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Gap.screen, 22, Gap.screen, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
                      child: Semantics(
                        header: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              l.window(w).toUpperCase(),
                              style: WaqtType.kicker(color: c.accent, size: 13, tracking: 0.06),
                            ),
                            const SizedBox(width: 8),
                            Text(span(w), style: WaqtType.sans(13, color: c.muted)),
                          ],
                        ),
                      ),
                    ),
                    WaqtGroup(children: [for (final t in groups[w]!) _TaskRow(task: t)]),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final repo = ref.read(taskRepositoryProvider);

    void delete() {
      repo.delete(task.id);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(l.tasksDeleted),
        action: SnackBarAction(label: l.undo, onPressed: () => repo.restore(task)),
      ));
    }

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: c.brassSoft,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        child: WaqtIcon(WaqtIcons.trash, color: c.brassText),
      ),
      onDismissed: (_) => delete(),
      child: Semantics(
        checked: task.done,
        label: task.title,
        excludeSemantics: true,
        onTap: () => _toggle(ref),
        customSemanticsActions: {CustomSemanticsAction(label: l.delete): delete},
        child: InkWell(
          onTap: () => _toggle(ref),
          onLongPress: delete,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 16, 6),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 44,
                    child: Center(
                      child: task.done
                          ? DoneMark(key: ValueKey('d${task.id}'), size: 24, checkColor: c.isDark ? c.bg : Colors.white)
                          : Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: c.hairline, width: 2),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: WaqtType.sans(
                        16,
                        weight: 500,
                        height: 1.35,
                        color: task.done ? c.muted : c.ink,
                        decoration: task.done ? TextDecoration.lineThrough : null,
                        decorationColor: c.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggle(WidgetRef ref) {
    if (!task.done) Haptics.light();
    ref.read(taskRepositoryProvider).setDone(task.id, !task.done);
  }
}

/// Docked "Add a task…" field with a prayer-window picker.
class _AddBar extends ConsumerStatefulWidget {
  const _AddBar();

  @override
  ConsumerState<_AddBar> createState() => _AddBarState();
}

class _AddBarState extends ConsumerState<_AddBar> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  TaskWindow? _window;
  bool _menu = false;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _text.text.trim();
    if (title.isEmpty) return;
    final w = _window ?? defaultTaskWindow(ref.read(prayerNowProvider));
    await ref.read(taskRepositoryProvider).add(title, ref.read(todayKeyProvider), w);
    _text.clear();
    setState(() => _menu = false);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final window = _window ?? defaultTaskWindow(ref.watch(prayerNowProvider));
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + inset),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.hairline),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14201B).withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: -10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MotionSize(
              ms: 200,
              child: !_menu
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final w in TaskWindow.values)
                            PillButton(
                              label: l.window(w),
                              style: w == window ? PillStyle.primary : PillStyle.fill,
                              height: 36,
                              fontSize: 13,
                              onPressed: () => setState(() {
                                _window = w;
                                _menu = false;
                              }),
                            ),
                        ],
                      ),
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    maxLength: 500,
                    style: WaqtType.sans(16, weight: 500, color: c.ink),
                    decoration: InputDecoration(
                      hintText: l.tasksAddHint,
                      hintStyle: WaqtType.sans(16, weight: 500, color: c.muted),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: l.window(window),
                  excludeSemantics: true,
                  child: Material(
                    color: c.mint,
                    shape: const StadiumBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => setState(() => _menu = !_menu),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 10, 0),
                        child: SizedBox(
                          height: 36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 120),
                                child: Text(
                                  l.window(window),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: WaqtType.sans(13, weight: 600, color: c.onMint),
                                ),
                              ),
                              const SizedBox(width: 4),
                              WaqtIcon(WaqtIcons.chevronDown, size: 14, color: c.onMint),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: WaqtIcons.plus,
                  semanticLabel: l.tasksAddA11y,
                  background: c.primary,
                  foreground: c.onPrimary,
                  onPressed: _add,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
