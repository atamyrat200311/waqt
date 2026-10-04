import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app.dart';
import 'package:waqt/core/router/app_router.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/data/repositories/expense_repository.dart';
import 'package:waqt/data/repositories/prayer_repository.dart';
import 'package:waqt/data/repositories/task_repository.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/features/today/application/today_providers.dart';

import 'helpers/test_app.dart';

/// 4 Oct 2026 17:30 in Ashgabat — inside the Asr window.
final asrTime = DateTime.utc(2026, 10, 4, 12, 30);

Future<ProviderContainer> pumpApp(WidgetTester t, {DateTime? now, String? location}) async {
  t.view.physicalSize = const Size(390 * 3, 844 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final c = ProviderContainer(
    overrides: settingsOverrides(const AppSettings(onboardingDone: true), now: now ?? asrTime),
  );
  addTearDown(c.dispose);
  await t.pumpWidget(UncontrolledProviderScope(container: c, child: const WaqtApp()));
  await t.pumpAndSettle();
  if (location != null) {
    c.read(appRouterProvider).go(location);
    await t.pumpAndSettle();
  }
  return c;
}

/// Lets drift's stream queries deliver (they complete on real timers).
Future<void> settle(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await t.pumpAndSettle();
}

Future<void> disposeApp(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('Home shows the next prayer and marking Asr on time records it', (t) async {
    final c = await pumpApp(t);
    expect(find.text('NEXT PRAYER'), findsOneWidget);
    expect(find.text('Maghrib'), findsWidgets);

    await t.tap(find.bySemanticsLabel(RegExp(r'^Asr \d')));
    await t.pumpAndSettle();
    expect(find.text('Prayed on time'), findsOneWidget);
    await t.tap(find.text('Prayed on time'));
    await settle(t);
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();

    final marks = await t.runAsync(() => c.read(prayerRepositoryProvider).getDay(const DayKey('2026-10-04')));
    expect(marks![Prayer.asr], PrayerStatus.onTime);
    await disposeApp(t);
  });

  testWidgets('Missed asks for confirmation before adding to qada', (t) async {
    final c = await pumpApp(t);
    await t.tap(find.bySemanticsLabel(RegExp(r'^Asr \d')));
    await t.pumpAndSettle();
    await t.tap(find.text('Missed, add to qada'));
    await t.pumpAndSettle();
    expect(find.text('Add 1 Asr to your qada?'), findsOneWidget);

    var counts = await t.runAsync(() => c.read(prayerRepositoryProvider).getQadaCounts());
    expect(counts![Prayer.asr], 0, reason: 'nothing is added before confirming');

    await t.tap(find.text('Add to qada'));
    await settle(t);
    counts = await t.runAsync(() => c.read(prayerRepositoryProvider).getQadaCounts());
    expect(counts![Prayer.asr], 1);
    await t.pump(const Duration(seconds: 1));
    await settle(t);
    await t.scrollUntilVisible(find.text('1 qada remaining'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('1 qada remaining'), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('Add expense with the keypad', (t) async {
    final c = await pumpApp(t);
    await t.tap(find.bySemanticsLabel('Add expense').first);
    await t.pumpAndSettle();
    for (final k in ['4', '5', '.', '5']) {
      await t.tap(find.text(k).last);
      await t.pump();
    }
    await t.tap(find.text('Sadaqa'));
    await t.pump();
    expect(find.text('Save 45.5 TMT as sadaqa'), findsOneWidget);
    await t.tap(find.text('Save 45.5 TMT as sadaqa'));
    await settle(t);

    final list = await t.runAsync(() => c.read(todayExpensesProvider.future));
    expect(list!.single.amountMinor, 4550);
    expect(list.single.category, ExpenseCategory.sadaqa);
    await disposeApp(t);
  });

  testWidgets('Tasks: add one to the current window and tick it off', (t) async {
    final c = await pumpApp(t, location: '/today/tasks');
    expect(find.text('Nothing planned yet. Add a task to a prayer window.'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Buy bread');
    await t.tap(find.bySemanticsLabel('Add task'));
    await settle(t);
    expect(find.text('AFTER ASR'), findsOneWidget);
    expect(find.text('Buy bread'), findsOneWidget);

    await t.tap(find.text('Buy bread'));
    await settle(t);
    final tasks = await t.runAsync(() => c.read(taskRepositoryProvider).watchDay(const DayKey('2026-10-04')).first);
    expect(tasks!.single.done, isTrue);
    expect(tasks.single.window, TaskWindow.afterAsr);
    await disposeApp(t);
  });

  testWidgets('Qada: made up decrements the count', (t) async {
    final c = await pumpApp(t);
    await t.runAsync(() => c.read(prayerRepositoryProvider).addOlder({Prayer.fajr: 2}));
    c.read(appRouterProvider).go('/today/qada');
    await settle(t);
    expect(find.text('2'), findsWidgets);
    await t.tap(find.bySemanticsLabel('Made up: Fajr'));
    await settle(t);
    final counts = await t.runAsync(() => c.read(prayerRepositoryProvider).getQadaCounts());
    expect(counts![Prayer.fajr], 1);
    expect(find.text("You've made up 1 since you started"), findsOneWidget);
    await disposeApp(t);
  });

  testWidgets('Expense repository is used through the provider', (t) async {
    final c = await pumpApp(t);
    await t.runAsync(() => c.read(expenseRepositoryProvider).add(
          amountMinor: 1200,
          currency: 'TMT',
          category: ExpenseCategory.food,
          occurredAt: asrTime,
        ));
    await settle(t);
    expect(find.text('12'), findsOneWidget);
    await disposeApp(t);
  });
}
