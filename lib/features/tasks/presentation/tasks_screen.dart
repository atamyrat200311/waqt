import 'dart:math' as math;

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
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/status_marks.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';
import '../../today/domain/today_logic.dart';

final overdueTasksProvider = StreamProvider<List<Task>>(
  (ref) => ref
      .watch(taskRepositoryProvider)
      .watchOverdue(ref.watch(todayKeyProvider)),
);

enum _TaskFilter { all, dunya, akhirah }

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  DayKey? _selectedDay;
  _TaskFilter _filter = _TaskFilter.all;

  Future<void> _pickDay(DayKey initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.date,
      firstDate: DateTime(initial.date.year - 3),
      lastDate: DateTime(initial.date.year + 5, 12, 31),
    );
    if (picked != null) setState(() => _selectedDay = DayKey.fromDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final today = ref.watch(todayKeyProvider);
    final selected = _selectedDay ?? today;
    final tasks = ref.watch(dayTasksProvider(selected)).value ?? const <Task>[];
    final overdue = selected == today
        ? ref.watch(overdueTasksProvider).value ?? const <Task>[]
        : const <Task>[];
    final done = tasks.where((task) => task.done).length;
    final prayerDay = ref.watch(prayerEngineProvider).day(selected.date);
    final visible = tasks.where((task) {
      return switch (_filter) {
        _TaskFilter.all => true,
        _TaskFilter.dunya => task.area == TaskArea.dunya,
        _TaskFilter.akhirah => task.area == TaskArea.akhirah,
      };
    }).toList();

    final groups = <TaskWindow, List<Task>>{};
    for (final task in visible) {
      (groups[task.window] ??= []).add(task);
    }
    for (final group in groups.values) {
      group.sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        if (a.priority != b.priority) {
          return a.priority == TaskPriority.high ? -1 : 1;
        }
        final byTime = (a.plannedMinute ?? 24 * 60).compareTo(
          b.plannedMinute ?? 24 * 60,
        );
        return byTime != 0 ? byTime : a.sortOrder.compareTo(b.sortOrder);
      });
    }

    String span(TaskWindow window) {
      final (from, until) = taskWindowSpan(window, prayerDay);
      if (from != null && until != null) {
        return l.winRange(hhmm(from), hhmm(until));
      }
      if (until != null) return l.winUntil(hhmm(until));
      if (from != null) return l.winFrom(hhmm(from));
      return '';
    }

    return SubScreen(
      title: l.tasksTitle,
      backLabel: l.tabToday,
      titleTrailing: tasks.isEmpty
          ? null
          : Text(
              l.tasksDoneOf('$done', '${tasks.length}'),
              style: WaqtType.sans(14, color: c.muted),
            ),
      bottom: _AddBar(day: selected),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
            child: _DayPicker(
              day: selected,
              today: today,
              onPrevious: () =>
                  setState(() => _selectedDay = selected.addDays(-1)),
              onNext: () => setState(() => _selectedDay = selected.addDays(1)),
              onPick: () => _pickDay(selected),
              onToday: selected == today
                  ? null
                  : () => setState(() => _selectedDay = null),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
            child: _BalanceCard(tasks: tasks),
          ),
        ),
        if (overdue.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
              child: WaqtCard(
                color: c.brassSoft,
                border: false,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.tasksOverdue(overdue.length),
                        style: WaqtType.sans(
                          14,
                          weight: 600,
                          color: c.brassText,
                        ),
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
                          .moveTo(overdue.map((task) => task.id), today),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 16, Gap.screen, 0),
            child: Segmented<_TaskFilter>(
              value: _filter,
              options: [
                (_TaskFilter.all, l.tasksAll),
                (_TaskFilter.dunya, l.tasksDunya),
                (_TaskFilter.akhirah, l.tasksAkhirah),
              ],
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
        ),
        if (tasks.isEmpty || visible.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
              child: Text(
                tasks.isEmpty ? l.tasksEmpty : l.tasksFilteredEmpty,
                textAlign: TextAlign.center,
                style: WaqtType.sans(15, color: c.muted, height: 1.5),
              ),
            ),
          ),
        for (final window in TaskWindow.values)
          if (groups[window] != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.screen,
                  22,
                  Gap.screen,
                  0,
                ),
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
                              l.window(window).toUpperCase(),
                              style: WaqtType.kicker(
                                color: c.accent,
                                size: 13,
                                tracking: 0.06,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              span(window),
                              style: WaqtType.sans(13, color: c.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    WaqtGroup(
                      children: [
                        for (final task in groups[window]!)
                          _TaskRow(task: task),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.day,
    required this.today,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
    required this.onToday,
  });

  final DayKey day;
  final DayKey today;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPick;
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final relative = day == today
        ? l.today
        : day == today.addDays(1)
        ? l.tomorrow
        : day == today.addDays(-1)
        ? l.yesterday
        : l.shortWeekdayDate(day.date);
    return Row(
      children: [
        CircleIconButton(
          icon: WaqtIcons.chevronLeft,
          semanticLabel: l.tasksPreviousDay,
          size: 38,
          background: c.fill,
          foreground: c.ink,
          onPressed: onPrevious,
        ),
        Expanded(
          child: Semantics(
            button: true,
            label: l.tasksChooseDay,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onPick,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    Text(
                      relative,
                      style: WaqtType.sans(16, weight: 700, color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.dayMonth(day.date),
                      style: WaqtType.sans(13, color: c.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        CircleIconButton(
          icon: WaqtIcons.chevronRight,
          semanticLabel: l.tasksNextDay,
          size: 38,
          background: c.fill,
          foreground: c.ink,
          onPressed: onNext,
        ),
        if (onToday != null) ...[
          const SizedBox(width: 6),
          PillButton(
            label: l.today,
            height: 38,
            fontSize: 13,
            style: PillStyle.mint,
            onPressed: onToday,
          ),
        ],
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final done = tasks.where((task) => task.done).length;
    final dunya = tasks.where((task) => task.area == TaskArea.dunya).length;
    final akhirah = tasks.length - dunya;
    final progress = tasks.isEmpty ? 0.0 : done / tasks.length;
    return WaqtCard(
      color: c.hero,
      border: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.tasksBalanceTitle,
                  style: WaqtType.serif(20, color: c.onHero),
                ),
              ),
              Text(
                l.tasksProgress('$done', '${tasks.length}'),
                style: WaqtType.sans(12.5, color: c.onHeroMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.tasksBalanceBody,
            style: WaqtType.sans(13, color: c.onHeroMuted, height: 1.35),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              backgroundColor: c.heroLayerStrong,
              valueColor: AlwaysStoppedAnimation(c.onHeroAccent),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AreaCount(
                  icon: WaqtIcons.globe,
                  label: l.tasksDunya,
                  count: dunya,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AreaCount(
                  icon: WaqtIcons.book,
                  label: l.tasksAkhirah,
                  count: akhirah,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaCount extends StatelessWidget {
  const _AreaCount({
    required this.icon,
    required this.label,
    required this.count,
  });

  final WaqtIconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: c.heroLayer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          WaqtIcon(icon, size: 17, color: c.onHeroMuted),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: WaqtType.sans(13, weight: 600, color: c.onHero),
            ),
          ),
          Text(
            '$count',
            style: WaqtType.sans(14, weight: 700, color: c.onHeroAccent),
          ),
        ],
      ),
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
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(l.tasksDeleted),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () => repo.restore(task),
          ),
        ),
      );
    }

    final meta = <String>[
      if (task.plannedMinute != null) _minuteLabel(task.plannedMinute!),
      l.taskArea(task.area),
      if (task.priority == TaskPriority.high) l.tasksHighPriority,
    ].join('  •  ');

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: c.dangerSoft,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        child: WaqtIcon(WaqtIcons.trash, color: c.danger),
      ),
      onDismissed: (_) => delete(),
      child: Semantics(
        checked: task.done,
        label: task.title,
        customSemanticsActions: {
          CustomSemanticsAction(label: l.delete): delete,
        },
        child: InkWell(
          onTap: () {
            if (!task.done) Haptics.light();
            repo.setDone(task.id, !task.done);
          },
          onLongPress: () =>
              showTaskEditor(context, day: task.day, existing: task),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 68),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 10, 7),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    checked: task.done,
                    label: task.title,
                    excludeSemantics: true,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (!task.done) Haptics.light();
                        repo.setDone(task.id, !task.done);
                      },
                      child: SizedBox.square(
                        dimension: 44,
                        child: Center(
                          child: task.done
                              ? DoneMark(
                                  key: ValueKey('d${task.id}'),
                                  size: 24,
                                  checkColor: c.isDark ? c.bg : Colors.white,
                                )
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: c.hairline,
                                      width: 2,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: task.area == TaskArea.dunya ? c.mint : c.brassSoft,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: WaqtIcon(
                      task.area == TaskArea.dunya
                          ? WaqtIcons.globe
                          : WaqtIcons.book,
                      size: 17,
                      color: task.area == TaskArea.dunya
                          ? c.onMint
                          : c.brassText,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.title,
                          style: WaqtType.sans(
                            16,
                            weight: task.priority == TaskPriority.high
                                ? 650
                                : 500,
                            height: 1.25,
                            color: task.done ? c.muted : c.ink,
                            decoration: task.done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: c.muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          meta,
                          style: WaqtType.sans(
                            12.5,
                            color: task.done ? c.muted : c.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.priority == TaskPriority.high)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 6),
                      child: WaqtIcon(WaqtIcons.star, size: 17, color: c.brass),
                    ),
                  const SizedBox(width: 2),
                  Semantics(
                    button: true,
                    label: l.edit,
                    excludeSemantics: true,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => showTaskEditor(
                        context,
                        day: task.day,
                        existing: task,
                      ),
                      child: SizedBox.square(
                        dimension: 40,
                        child: Center(
                          child: WaqtIcon(
                            WaqtIcons.edit,
                            size: 17,
                            color: c.muted,
                          ),
                        ),
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
}

String _minuteLabel(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

Future<bool?> showTaskEditor(
  BuildContext context, {
  required DayKey day,
  Task? existing,
  String initialTitle = '',
  TaskArea initialArea = TaskArea.dunya,
  TaskWindow? initialWindow,
}) => Adaptive.showSheet<bool>(
  context,
  expand: true,
  builder: (_) => _TaskEditor(
    day: day,
    existing: existing,
    initialTitle: initialTitle,
    initialArea: initialArea,
    initialWindow: initialWindow,
  ),
);

class _TaskEditor extends ConsumerStatefulWidget {
  const _TaskEditor({
    required this.day,
    required this.initialTitle,
    required this.initialArea,
    this.initialWindow,
    this.existing,
  });

  final DayKey day;
  final Task? existing;
  final String initialTitle;
  final TaskArea initialArea;
  final TaskWindow? initialWindow;

  @override
  ConsumerState<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<_TaskEditor> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late DayKey _day;
  late TaskArea _area;
  late TaskPriority _priority;
  late TaskWindow _window;
  late int? _plannedMinute;

  @override
  void initState() {
    super.initState();
    final task = widget.existing;
    _title = TextEditingController(text: task?.title ?? widget.initialTitle);
    _note = TextEditingController(text: task?.note ?? '');
    _day = task?.day ?? widget.day;
    _area = task?.area ?? widget.initialArea;
    _priority = task?.priority ?? TaskPriority.normal;
    _window = task?.window ?? widget.initialWindow ?? TaskWindow.anytime;
    _plannedMinute = task?.plannedMinute;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day.date,
      firstDate: DateTime(_day.date.year - 3),
      lastDate: DateTime(_day.date.year + 5, 12, 31),
    );
    if (picked != null) setState(() => _day = DayKey.fromDate(picked));
  }

  Future<void> _pickTime() async {
    final initial = _plannedMinute == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: _plannedMinute! ~/ 60, minute: _plannedMinute! % 60);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => _plannedMinute = picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    if (widget.existing == null) {
      await repo.add(
        title,
        _day,
        _window,
        area: _area,
        priority: _priority,
        plannedMinute: _plannedMinute,
        note: _note.text,
      );
    } else {
      await repo.update(
        widget.existing!.id,
        title: title,
        day: _day,
        window: _window,
        area: _area,
        priority: _priority,
        plannedMinute: _plannedMinute,
        note: _note.text,
      );
    }
    Haptics.success();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 +
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? l.tasksNewTitle : l.tasksEditTitle,
            style: WaqtType.serif(27, tracking: -0.015, color: c.ink),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _title,
            autofocus: widget.existing == null && widget.initialTitle.isEmpty,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            style: WaqtType.sans(17, weight: 600, color: c.ink),
            decoration: _fieldDecoration(context, l.tasksTitleHint),
          ),
          const SizedBox(height: 16),
          _FieldLabel(l.tasksAreaLabel),
          const SizedBox(height: 7),
          Segmented<TaskArea>(
            value: _area,
            options: [
              (TaskArea.dunya, l.tasksDunya),
              (TaskArea.akhirah, l.tasksAkhirah),
            ],
            onChanged: (value) => setState(() => _area = value),
          ),
          const SizedBox(height: 16),
          _FieldLabel(l.tasksPriorityLabel),
          const SizedBox(height: 7),
          Segmented<TaskPriority>(
            value: _priority,
            options: [
              (TaskPriority.normal, l.tasksNormalPriority),
              (TaskPriority.high, l.tasksHighPriority),
            ],
            onChanged: (value) => setState(() => _priority = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EditorTile(
                  icon: WaqtIcons.calendar,
                  label: l.tasksDateLabel,
                  value: l.shortWeekdayDate(_day.date),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EditorTile(
                  icon: WaqtIcons.clock,
                  label: l.tasksTimeLabel,
                  value: _plannedMinute == null
                      ? l.tasksNoTime
                      : _minuteLabel(_plannedMinute!),
                  onTap: _pickTime,
                  onClear: _plannedMinute == null
                      ? null
                      : () => setState(() => _plannedMinute = null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FieldLabel(l.tasksWindowLabel),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final window in TaskWindow.values)
                ChoiceChip(
                  label: Text(l.window(window)),
                  selected: _window == window,
                  onSelected: (_) => setState(() => _window = window),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: _fieldDecoration(context, l.tasksNoteHint),
          ),
          const SizedBox(height: 18),
          BigButton(label: l.save, onPressed: _save),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: WaqtType.kicker(
      color: context.colors.muted,
      size: 12,
      tracking: 0.06,
    ),
  );
}

class _EditorTile extends StatelessWidget {
  const _EditorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final WaqtIconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.fill,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 11, 8, 11),
          child: Row(
            children: [
              WaqtIcon(icon, size: 19, color: c.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtType.sans(11, color: c.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtType.sans(13, weight: 600, color: c.ink),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: context.l10n.tasksClearTime,
                  onPressed: onClear,
                  icon: WaqtIcon(WaqtIcons.close, size: 15, color: c.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(BuildContext context, String hint) {
  final c = context.colors;
  return InputDecoration(
    hintText: hint,
    counterText: '',
    filled: true,
    fillColor: c.fill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}

/// Quick capture stays docked while the expanded controls expose intention and
/// prayer-window planning without forcing a full form for every task.
class _AddBar extends ConsumerStatefulWidget {
  const _AddBar({required this.day});

  final DayKey day;

  @override
  ConsumerState<_AddBar> createState() => _AddBarState();
}

class _AddBarState extends ConsumerState<_AddBar> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  TaskWindow? _window;
  TaskArea _area = TaskArea.dunya;
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
    final window = _window ?? _defaultWindow();
    await ref
        .read(taskRepositoryProvider)
        .add(title, widget.day, window, area: _area);
    _text.clear();
    setState(() => _menu = false);
    _focus.requestFocus();
  }

  TaskWindow _defaultWindow() => widget.day == ref.read(todayKeyProvider)
      ? defaultTaskWindow(ref.read(prayerNowProvider))
      : TaskWindow.anytime;

  Future<void> _details(TaskWindow window) async {
    final saved = await showTaskEditor(
      context,
      day: widget.day,
      initialTitle: _text.text.trim(),
      initialArea: _area,
      initialWindow: window,
    );
    if (saved == true) {
      _text.clear();
      if (mounted) setState(() => _menu = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final prayerNow = ref.watch(prayerNowProvider);
    final today = ref.watch(todayKeyProvider);
    final window =
        _window ??
        (widget.day == today
            ? defaultTaskWindow(prayerNow)
            : TaskWindow.anytime);
    final inset = math.max(
      MediaQuery.viewInsetsOf(context).bottom,
      MediaQuery.paddingOf(context).bottom,
    );
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Segmented<TaskArea>(
                            value: _area,
                            options: [
                              (TaskArea.dunya, l.tasksDunya),
                              (TaskArea.akhirah, l.tasksAkhirah),
                            ],
                            onChanged: (value) => setState(() => _area = value),
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final value in TaskWindow.values)
                                PillButton(
                                  label: l.window(value),
                                  style: value == window
                                      ? PillStyle.primary
                                      : PillStyle.fill,
                                  height: 36,
                                  fontSize: 13,
                                  onPressed: () =>
                                      setState(() => _window = value),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          PillButton(
                            label: l.tasksPlanDetails,
                            style: PillStyle.ghost,
                            height: 38,
                            icon: WaqtIcons.edit,
                            onPressed: () => _details(window),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                Semantics(
                  button: true,
                  label: l.taskArea(_area),
                  excludeSemantics: true,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() {
                      _area = _area == TaskArea.dunya
                          ? TaskArea.akhirah
                          : TaskArea.dunya;
                    }),
                    child: SizedBox.square(
                      dimension: 40,
                      child: Center(
                        child: WaqtIcon(
                          _area == TaskArea.dunya
                              ? WaqtIcons.globe
                              : WaqtIcons.book,
                          size: 19,
                          color: _area == TaskArea.dunya
                              ? c.accent
                              : c.brassText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
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
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          10,
                          0,
                          8,
                          0,
                        ),
                        child: SizedBox(
                          height: 36,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 92),
                                child: Text(
                                  l.window(window),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: WaqtType.sans(
                                    12.5,
                                    weight: 600,
                                    color: c.onMint,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              WaqtIcon(
                                WaqtIcons.chevronDown,
                                size: 13,
                                color: c.onMint,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
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
