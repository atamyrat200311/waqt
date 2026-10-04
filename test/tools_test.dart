import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app.dart';
import 'package:waqt/core/router/app_router.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/data/repositories/adhkar_repository.dart';
import 'package:waqt/data/repositories/fast_repository.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/features/adhkar/application/adhkar_providers.dart';
import 'package:waqt/features/calendar/domain/hijri_service.dart';
import 'package:waqt/features/calendar/presentation/calendar_screen.dart';
import 'package:waqt/features/tools/domain/tasbih.dart';

import 'helpers/test_app.dart';

void main() {
  group('Tasbih (pure)', () {
    test('33 · 33 · 34 sequence completes at 100', () {
      var s = TasbihState.preset();
      final results = <TasbihTap>[];
      for (var i = 0; i < 33; i++) {
        final (n, r) = s.tap();
        s = n;
        results.add(r);
      }
      expect(results.last, TasbihTap.phaseDone);
      expect(s.atPhaseEnd, isTrue);
      s = s.advance();
      expect(s.phase, 1);
      expect(s.count, 0);
      expect(s.total, 33);

      // A tap during the pause at a phase end advances and counts.
      for (var i = 0; i < 33; i++) {
        s = s.tap().$1;
      }
      final (afterPause, _) = s.tap();
      expect(afterPause.phase, 2);
      expect(afterPause.count, 1);
      s = afterPause;
      TasbihTap last = TasbihTap.counted;
      for (var i = 0; i < 33; i++) {
        final (n, r) = s.tap();
        s = n;
        last = r;
      }
      expect(last, TasbihTap.complete);
      expect(s.isComplete, isTrue);
      expect(s.total, 100);
      expect(s.tap().$2, TasbihTap.restarted);
    });

    test('custom phrase with a goal', () {
      var s = TasbihState.custom('Astaghfirullāh', 3);
      for (var i = 0; i < 3; i++) {
        s = s.tap().$1;
      }
      expect(s.isComplete, isTrue);
      expect(s.label, 'Astaghfirullāh');
      expect(TasbihState.custom('', 0).current.target, 1);
    });
  });

  test('fast type for a day: Ramadan > white days > Mon/Thu > other', () {
    const h = HijriService();
    final ramadanDay = h.toGregorian(1448, 9, 5);
    expect(fastTypeFor(h, ramadanDay, ramadan: false), FastType.ramadan);
    final white = h.toGregorian(1448, 4, 14);
    expect(fastTypeFor(h, white, ramadan: false), FastType.whiteDays);
    // 5 Oct 2026 is a Monday (24 Rabīʿ II).
    expect(fastTypeFor(h, DateTime(2026, 10, 5), ramadan: false), FastType.monThu);
    expect(fastTypeFor(h, DateTime(2026, 10, 6), ramadan: false), FastType.other);
  });

  group('screens', () {
    setUp(() {
      TestWidgetsFlutterBinding.instance.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
    });
    tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearAccessibilityFeaturesTestValue());

    Future<ProviderContainer> open(WidgetTester t, String location) async {
      t.view.physicalSize = const Size(390 * 3, 844 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      final c = ProviderContainer(overrides: settingsOverrides(const AppSettings(onboardingDone: true)));
      addTearDown(c.dispose);
      await t.runAsync(() => c.read(adhkarCatalogProvider.future));
      await t.pumpWidget(UncontrolledProviderScope(container: c, child: const WaqtApp()));
      await t.pumpAndSettle();
      c.read(appRouterProvider).go(location);
      await t.pumpAndSettle();
      return c;
    }

    Future<void> settle(WidgetTester t) async {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await t.pumpAndSettle();
    }

    Future<void> close(WidgetTester t) async {
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 2));
    }

    testWidgets('adhkar reader counts taps and saves progress', (t) async {
      final c = await open(t, '/adhkar/evening');
      expect(find.text('Evening adhkar'), findsOneWidget);
      expect(find.text('1 of 12'), findsOneWidget);
      final counter = find.bySemanticsLabel(RegExp('^Tap to count'));
      await t.scrollUntilVisible(counter, 300, scrollable: find.byType(Scrollable).first);
      await t.tap(counter);
      await settle(t);
      final counts = await t.runAsync(
        () => c.read(adhkarRepositoryProvider).watchDay(const DayKey('2026-10-04'), AdhkarSet.evening).first,
      );
      expect(counts!['e01'], 1);
      expect(find.text('Complete'), findsOneWidget);
      await t.tap(find.text('Next dhikr'));
      await t.pumpAndSettle();
      expect(find.text('2 of 12'), findsOneWidget);
      expect(find.text('Recite 3×'), findsOneWidget);
      await close(t);
    });

    testWidgets('tasbih counts on Tools', (t) async {
      await open(t, '/tools');
      for (var i = 0; i < 3; i++) {
        await t.tap(find.bySemanticsLabel(RegExp('^Count one')));
        await t.pump();
      }
      await t.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
      expect(find.text('of 33'), findsOneWidget);
      await t.tap(find.text('Reset'));
      await t.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      await close(t);
    });

    testWidgets('calendar: tapping a day logs a fast', (t) async {
      final c = await open(t, '/tools/calendar');
      expect(find.text('Rabīʿ al-Thānī'), findsOneWidget);
      await t.tap(find.bySemanticsLabel(RegExp(r'^23 .* Sunday, 4 October')));
      await t.pumpAndSettle();
      await t.tap(find.text('Fasted'));
      await settle(t);
      final fasts = await t.runAsync(
        () => c.read(fastRepositoryProvider).watchRange(const DayKey('2026-10-04'), const DayKey('2026-10-04')).first,
      );
      expect(fasts![const DayKey('2026-10-04')]!.status, FastStatus.fasted);
      expect(fasts[const DayKey('2026-10-04')]!.type, FastType.other);
      await close(t);
    });
  });
}
