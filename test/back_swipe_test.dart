import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app.dart';
import 'package:waqt/core/router/app_router.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/features/hadith/application/hadith_providers.dart';
import 'package:waqt/features/quran/application/quran_providers.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });

  // Pushes [route], swipes from the left edge and expects to land on [back].
  for (final (route, back) in [
    ('/today/qada', '/today'),
    ('/tools/calendar', '/today'),
    ('/me/settings', '/today'),
    ('/library/duas', '/today'),
    ('/read?i=0', '/today'),
    ('/read?i=0&mode=page', '/today'),
    ('/location', '/today'),
  ]) {
    testWidgets('iOS edge swipe goes back from $route', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await loadAppFonts(); // real glyph widths, otherwise the test font overflows
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final c = ProviderContainer(overrides: settingsOverrides(const AppSettings(onboardingDone: true)));
      addTearDown(c.dispose);
      await tester.runAsync(() async {
        await c.read(quranTextsProvider.future);
        await c.read(hadithOfDayProvider.future);
      });
      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const WaqtApp()));
      await tester.pumpAndSettle();

      final router = c.read(appRouterProvider);
      unawaited(router.push(route));
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), route);

      // A finger: down at the edge, a few moves, release.
      final g = await tester.startGesture(const Offset(3, 400));
      for (var i = 0; i < 12; i++) {
        await g.moveBy(const Offset(25, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await g.up();
      await tester.pumpAndSettle();
      expect(router.state.uri.path, back, reason: 'swipe from the left edge should pop $route');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 3));
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
