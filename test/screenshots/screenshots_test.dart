// Renders key screens to PNGs for visual review (not a golden comparison).
//
//   WAQT_SCREENSHOTS=1 flutter test test/screenshots
//
// Output: build/screenshots/<name>.png
@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app.dart';
import 'package:waqt/core/router/app_router.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/app_database.dart';
import 'package:waqt/data/db/database_provider.dart';
import 'package:waqt/data/repositories/adhkar_repository.dart';
import 'package:waqt/data/repositories/expense_repository.dart';
import 'package:waqt/data/repositories/prayer_repository.dart';
import 'package:waqt/data/repositories/task_repository.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/features/adhkar/application/adhkar_providers.dart';

import '../helpers/test_app.dart';

final _enabled = Platform.environment.containsKey('WAQT_SCREENSHOTS');

/// Seeds a realistic day (matches the design's sample data).
Future<void> seed(ProviderContainer c) async {
  final db = c.read(databaseProvider);
  const day = DayKey('2026-10-04');
  final prayers = PrayerRepository(db);
  await prayers.mark(day, Prayer.fajr, PrayerStatus.onTime);
  await prayers.mark(day, Prayer.dhuhr, PrayerStatus.congregation);
  await prayers.addOlder({Prayer.fajr: 5, Prayer.dhuhr: 2, Prayer.asr: 3, Prayer.maghrib: 1, Prayer.isha: 3});
  await prayers.makeUp(Prayer.fajr, now: DateTime(2026, 10, 1, 9));
  await prayers.makeUp(Prayer.asr, now: DateTime(2026, 10, 3, 9));
  await prayers.makeUp(Prayer.isha, now: DateTime(2026, 10, 3, 21));
  final at = DateTime.utc(2026, 10, 4, 6);
  final ex = ExpenseRepository(db);
  await ex.add(amountMinor: 22000, currency: 'TMT', category: ExpenseCategory.groceries, occurredAt: at);
  await ex.add(amountMinor: 2000, currency: 'TMT', category: ExpenseCategory.sadaqa, occurredAt: at);
  final tasks = TaskRepository(db);
  final a = await tasks.add('Pay the electricity bill', day, TaskWindow.beforeDhuhr);
  final b = await tasks.add('Call Mekan about the car service', day, TaskWindow.beforeDhuhr);
  await tasks.add('Pick up Aýna from school', day, TaskWindow.afterAsr);
  await tasks.add('Buy bread and ayran at the bazaar', day, TaskWindow.afterAsr);
  await tasks.add('Read 10 pages with the kids', day, TaskWindow.afterIsha);
  await tasks.setDone(a, true);
  await tasks.setDone(b, true);
  final adhkar = AdhkarRepository(db);
  for (final id in ['m01', 'm02', 'm03', 'm04', 'm05', 'm06', 'm07', 'm08', 'm09', 'm10', 'm11']) {
    await adhkar.setCount(day, AdhkarSet.morning, id, 100);
  }
  await adhkar.setCount(day, AdhkarSet.morning, 'm12', 100);
}

Future<void> shoot(
  WidgetTester tester,
  String name, {
  TargetPlatform platform = TargetPlatform.iOS,
  bool dark = false,
  String? location,
  AppSettings settings = const AppSettings(onboardingDone: true),
  DateTime? now,
  Future<void> Function(WidgetTester t)? act,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.platformBrightnessTestValue = dark ? Brightness.dark : Brightness.light;
  debugDefaultTargetPlatformOverride = platform;
  // Reduce motion: stops the looping glow/caret so the tree can settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  final container = ProviderContainer(overrides: settingsOverrides(settings, now: now));
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    await seed(container);
    await container.read(adhkarCatalogProvider.future);
  });
  final key = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(key: key, child: const WaqtApp()),
    ),
  );
  await tester.pumpAndSettle();
  if (location != null) {
    container.read(appRouterProvider).go(location);
    await tester.pumpAndSettle();
  }
  if (act != null) {
    await act(tester);
    await tester.pumpAndSettle();
  }
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final f = File('build/screenshots/$name.png')..createSync(recursive: true);
    f.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
  debugDefaultTargetPlatformOverride = null;
  tester.view.reset();
  tester.platformDispatcher.clearPlatformBrightnessTestValue();
  tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('home', (t) async {
    await shoot(t, 'home_ios_light');
    await shoot(t, 'home_ios_dark', dark: true);
    await shoot(t, 'home_android', platform: TargetPlatform.android);
  }, skip: !_enabled);

  testWidgets('home ramadan', (t) async {
    await shoot(
      t,
      'home_ramadan',
      settings: const AppSettings(onboardingDone: true, ramadanMode: RamadanMode.on),
    );
  }, skip: !_enabled);

  testWidgets('mark sheet', (t) async {
    await shoot(t, 'mark_sheet', act: (t) async {
      await t.tap(find.bySemanticsLabel(RegExp('^Asr \\d')));
    });
    await shoot(t, 'mark_missed', now: DateTime.utc(2026, 10, 4, 12, 30), act: (t) async {
      await t.tap(find.bySemanticsLabel(RegExp('^Asr \\d')));
      await t.pumpAndSettle();
      await t.tap(find.text('Missed, add to qada'));
    });
  }, skip: !_enabled);

  testWidgets('sub screens', (t) async {
    await shoot(t, 'qada_ios', location: '/today/qada');
    await shoot(t, 'qada_android', location: '/today/qada', platform: TargetPlatform.android);
    await shoot(t, 'tasks_ios', location: '/today/tasks');
    await shoot(t, 'tasks_android_dark', location: '/today/tasks', platform: TargetPlatform.android, dark: true);
  }, skip: !_enabled);

  testWidgets('tools', (t) async {
    await shoot(t, 'tools_ios', location: '/tools');
    await shoot(t, 'tools_android_dark', location: '/tools', platform: TargetPlatform.android, dark: true);
    await shoot(t, 'calendar', location: '/tools/calendar');
    await shoot(t, 'qibla', location: '/tools/qibla');
    await shoot(t, 'ramadan', location: '/tools/ramadan');
    await shoot(t, 'adhkar_evening', location: '/adhkar/evening');
    await shoot(t, 'adhkar_morning_dark', location: '/adhkar/morning', dark: true);
  }, skip: !_enabled);

  testWidgets('expense sheet', (t) async {
    await shoot(t, 'expense', act: (t) async {
      final ctx = t.element(find.byType(Scaffold).first);
      GoRouter.of(ctx);
      await t.tap(find.bySemanticsLabel('Add expense').first);
      await t.pumpAndSettle();
      for (final k in ['4', '5']) {
        await t.tap(find.text(k).last);
      }
    });
  }, skip: !_enabled);
}
