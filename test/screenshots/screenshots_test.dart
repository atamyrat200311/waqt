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
import 'package:waqt/features/hadith/application/hadith_providers.dart';
import 'package:waqt/features/library/application/library_providers.dart';
import 'package:waqt/features/quran/application/quran_providers.dart';
import 'package:waqt/features/quran/domain/quran.dart';

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
  Future<void> Function(ProviderContainer c)? preload,
  double height = 844,
  double textScale = 1,
}) async {
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.view.physicalSize = Size(390 * 3, height * 3);
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
    await container.read(quranTextsProvider.future);
    await preload?.call(container);
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
  tester.platformDispatcher.clearTextScaleFactorTestValue();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('home', (t) async {
    await shoot(t, 'home_ios_light');
    await shoot(t, 'home_ios_dark', dark: true);
    await shoot(t, 'home_android', platform: TargetPlatform.android);
  }, skip: !_enabled);

  testWidgets('full pages', (t) async {
    await shoot(t, 'full_home', height: 2300);
    await shoot(t, 'full_me', location: '/me', height: 1900);
    await shoot(t, 'full_library', location: '/library', height: 1700);
    await shoot(t, 'full_quran', location: '/quran', height: 1500);
  }, skip: !_enabled);

  testWidgets('large text', (t) async {
    for (final (name, loc) in [
      ('home', '/today'),
      ('quran', '/quran'),
      ('library', '/library'),
      ('tools', '/tools'),
      ('me', '/me'),
      ('qada', '/today/qada'),
      ('tasks', '/today/tasks'),
      ('settings', '/me/settings'),
      ('zakat', '/tools/zakat'),
      ('timetable', '/tools/timetable'),
      ('reader', '/read?i=261'),
    ]) {
      await shoot(t, 'big_$name', location: loc, textScale: 1.6, height: 1400);
    }
    await shoot(t, 'big_android_home', textScale: 1.6, platform: TargetPlatform.android, height: 1400);
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

  testWidgets('me & settings', (t) async {
    await shoot(t, 'me', location: '/me');
    await shoot(t, 'me_dark_android', location: '/me', platform: TargetPlatform.android, dark: true);
    await shoot(t, 'settings', location: '/me/settings');
    await shoot(t, 'settings_android', location: '/me/settings', platform: TargetPlatform.android);
    await shoot(t, 'location', location: '/location');
    await shoot(t, 'onboarding_welcome', settings: const AppSettings());
    await shoot(t, 'onboarding_language', settings: const AppSettings(), act: (t) async {
      await t.tap(find.text('Get started'));
    });
    await shoot(t, 'onboarding_location', settings: const AppSettings(), act: (t) async {
      await t.tap(find.text('Get started'));
      await t.pumpAndSettle();
      await t.tap(find.text('English'));
    });
  }, skip: !_enabled);

  testWidgets('quran', (t) async {
    const reading = AppSettings(onboardingDone: true, quranLastRead: 261);
    await shoot(t, 'quran_home', settings: reading, location: '/quran');
    await shoot(t, 'quran_home_android_dark', settings: reading, location: '/quran', platform: TargetPlatform.android, dark: true);
    await shoot(t, 'quran_reader', location: '/read?i=261');
    await shoot(t, 'quran_reader_fatiha_dark', location: '/read?i=0', dark: true);
    await shoot(t, 'quran_reader_page', location: '/read?i=261&mode=page');
    await shoot(t, 'quran_reader_hifz', location: '/read?i=6221&hifz=112');
    await shoot(t, 'quran_khatm_setup', location: '/quran/khatm');
    await shoot(t, 'quran_hifz', location: '/quran/memorize');
    await shoot(t, 'quran_search', location: '/quran/search', act: (t) async {
      await t.enterText(find.byType(TextField), 'mercy');
      await t.pump(const Duration(milliseconds: 400));
      await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
      await t.pump();
    });
  }, skip: !_enabled);

  testWidgets('library', (t) async {
    Future<void> hadith(ProviderContainer c) async {
      await c.read(hadithOfDayProvider.future);
      for (final b in ['bukhari', 'nawawi']) {
        await c.read(hadithEditionProvider((b, 'eng')).future);
        await c.read(hadithEditionProvider((b, 'ara')).future);
      }
    }

    await shoot(t, 'library', location: '/library', preload: hadith);
    await shoot(t, 'library_android_dark', location: '/library', preload: hadith, platform: TargetPlatform.android, dark: true);
    await shoot(t, 'hadith_bukhari', location: '/library/hadith/bukhari', preload: hadith);
    await shoot(t, 'hadith_bukhari_section', location: '/library/hadith/bukhari/2', preload: hadith);
    await shoot(t, 'hadith_nawawi', location: '/library/hadith/nawawi', preload: hadith);
    Future<void> content(ProviderContainer c) async {
      await c.read(duaCatalogProvider.future);
      await c.read(allahNamesProvider.future);
      await c.read(guidesProvider.future);
    }

    await shoot(t, 'duas', location: '/library/duas', preload: content, height: 1500);
    await shoot(t, 'names', location: '/library/names', preload: content);
    await shoot(t, 'learn', location: '/library/learn', preload: content);
    await shoot(t, 'guide_salah', location: '/library/learn/salah', preload: content, height: 2400);
    await shoot(t, 'guide_islam_ru', location: '/library/learn/islam', preload: content, height: 1600,
        settings: const AppSettings(onboardingDone: true, language: 'ru'));
  }, skip: !_enabled);

  testWidgets('new tools', (t) async {
    await shoot(t, 'tools_ios_v2', location: '/tools');
    await shoot(
      t,
      'zakat',
      location: '/tools/zakat',
      settings: const AppSettings(
        onboardingDone: true,
        zakat: {'cash': 2500000, 'goldGrams': 20, 'silverPrice': 1650, 'goldPrice': 140000},
      ),
    );
    await shoot(t, 'timetable', location: '/tools/timetable');
    await shoot(t, 'habits_empty', location: '/today/habits');
  }, skip: !_enabled);

  testWidgets('review set', (t) async {
    const tk = AppSettings(onboardingDone: true, language: 'tk', quranLastRead: 261);
    const ru = AppSettings(onboardingDone: true, language: 'ru', quranLastRead: 261);
    await shoot(t, 'review_home_tk', settings: tk, height: 1800);
    await shoot(t, 'review_quran_ru', settings: ru, location: '/quran', height: 1300);
    await shoot(t, 'review_reader_ru', settings: ru, location: '/read?i=261');
    await shoot(t, 'review_tools_tk', settings: tk, location: '/tools', height: 1300);
    await shoot(t, 'review_reader_settings', location: '/read?i=261', act: (t) async {
      await t.tap(find.text('Aa'));
    });
    await shoot(t, 'review_ayah_actions', location: '/read?i=261', act: (t) async {
      await t.longPress(find.textContaining('Allah - there is no deity'));
    });
    await shoot(
      t,
      'review_khatm_active',
      location: '/quran/khatm',
      settings: const AppSettings(onboardingDone: true, khatmPlan: KhatmPlan(start: '2026-09-28', days: 30)),
      height: 1300,
    );
    await shoot(t, 'review_share_sheet', location: '/read?i=261', act: (t) async {
      await t.longPress(find.textContaining('Allah - there is no deity'));
      await t.pumpAndSettle();
      await t.tap(find.text('Share as image'));
    });
    await shoot(t, 'review_habit_editor', location: '/today/habits', act: (t) async {
      await t.tap(find.bySemanticsLabel('New habit').first);
    });
    await shoot(t, 'review_settings_full', location: '/me/settings', height: 2600);
    await shoot(t, 'review_backup', location: '/me/settings/backup');
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
