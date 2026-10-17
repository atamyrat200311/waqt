import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app.dart';
import 'package:waqt/core/router/app_router.dart';
import 'package:waqt/data/db/app_database.dart';
import 'package:waqt/data/db/database_provider.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/data/settings/settings_controller.dart';
import 'package:waqt/features/hadith/application/hadith_providers.dart';
import 'package:waqt/features/quran/application/quran_providers.dart';
import 'package:waqt/shared/widgets/status_marks.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearAccessibilityFeaturesTestValue());

  Future<ProviderContainer> pump(WidgetTester tester, {AppSettings settings = const AppSettings(onboardingDone: true)}) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: settingsOverrides(settings));
    addTearDown(c.dispose);
    await tester.runAsync(() async {
      await c.read(quranTextsProvider.future);
      await c.read(hadithOfDayProvider.future);
    });
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const WaqtApp()));
    await tester.pumpAndSettle();
    return c;
  }

  Future<void> done(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Past the 2-minute grace period that keeps hadith books in memory.
    await tester.pump(const Duration(minutes: 3));
  }

  testWidgets('Quran tab → reader → bookmark an ayah → back saves last read', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Quran').last);
    await tester.pumpAndSettle();
    expect(find.text('Al-Fatihah'), findsWidgets);

    unawaited(c.read(appRouterProvider).push('/read?i=6221'));
    await tester.pumpAndSettle();
    expect(find.text('Al-Ikhlas'), findsWidgets);

    // Ayah actions → bookmark.
    await tester.longPress(find.textContaining('He is Allah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bookmark'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    final db = c.read(databaseProvider);
    final marks = await tester.runAsync(() => db.select(db.bookmarks).get());
    expect(marks!.single.ref, '112:1');
    expect(marks.single.kind, BookmarkKind.ayah);

    // Leaving the reader stores where we were.
    c.read(appRouterProvider).pop();
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).quranLastRead, isNotNull);
    await done(tester);
  });

  testWidgets('a quick lookup does not move the continue-reading position', (tester) async {
    final c = await pump(tester, settings: const AppSettings(onboardingDone: true, quranLastRead: 100));
    unawaited(c.read(appRouterProvider).push('/read?i=6221'));
    await tester.pumpAndSettle();
    c.read(appRouterProvider).pop();
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).quranLastRead, 100);
    await done(tester);
  });

  testWidgets('reader settings change the Arabic size', (tester) async {
    final c = await pump(tester);
    c.read(appRouterProvider).go('/read?i=0');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aa'));
    await tester.pumpAndSettle();
    expect(find.text('Reading settings'), findsOneWidget);
    // The sheet scrolls; the toggles sit below the fold on a 390×844 screen.
    await tester.ensureVisible(find.text('Show transliteration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show transliteration'));
    await tester.pumpAndSettle();
    expect(c.read(settingsProvider).reader.showTranslit, isTrue);

    await tester.ensureVisible(find.text('Tajweed colors'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tajweed colors'));
    await tester.pump(); // the tajweed text loads off-thread; no need to wait
    expect(c.read(settingsProvider).reader.tajweed, isTrue);
    await done(tester);
  });

  testWidgets('habits: add one, then tick it', (tester) async {
    final c = await pump(tester);
    c.read(appRouterProvider).go('/today/habits');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('New habit').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Morning walk');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(find.text('Morning walk'), findsOneWidget);

    await tester.tap(find.byType(UpcomingMark));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    final db = c.read(databaseProvider);
    final logs = await tester.runAsync(() => db.select(db.habitLogs).get());
    expect(logs, hasLength(1));
    await done(tester);
  });

  testWidgets('library shows the hadith of the day and opens a collection', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Library').last);
    await tester.pumpAndSettle();
    expect(find.text('HADITH OF THE DAY'), findsOneWidget);
    await tester.runAsync(() async {
      await c.read(hadithEditionProvider(('nawawi', 'eng')).future);
      await c.read(hadithEditionProvider(('nawawi', 'ara')).future);
    });
    c.read(appRouterProvider).go('/library/hadith/nawawi');
    await tester.pumpAndSettle();
    expect(find.textContaining('Actions are (judged) by motives'), findsOneWidget);
    await done(tester);
  });
}
