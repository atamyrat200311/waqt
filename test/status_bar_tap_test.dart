import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearAccessibilityFeaturesTestValue());

  // iOS: tapping the status bar (the clock) scrolls the screen to the top.
  for (final route in ['/today', '/today/qada', '/library', '/tools', '/me', '/me/settings', '/quran']) {
    testWidgets('iOS status bar tap scrolls $route to the top', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await loadAppFonts();
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
      tester.view.viewPadding = const FakeViewPadding(top: 47 * 3, bottom: 34 * 3);
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
      if (route != '/today') {
        if (route.split('/').length > 2) {
          unawaited(router.push(route));
        } else {
          router.go(route);
        }
        await tester.pumpAndSettle();
      }

      // The primary scroll view of the visible screen is what the OS status
      // bar tap drives.
      final primary = PrimaryScrollController.of(tester.element(find.byType(Scaffold).last));
      ScrollPosition pos() => primary.position;
      expect(primary.hasClients, isTrue, reason: '$route has no primary scroll view');
      expect(pos().maxScrollExtent, greaterThan(100), reason: 'screen should be scrollable');
      pos().jumpTo(pos().maxScrollExtent / 2);
      await tester.pump();
      expect(pos().pixels, greaterThan(0));

      // What iOS sends when the status bar is tapped.
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/status_bar',
        const JSONMethodCodec().encodeMethodCall(const MethodCall('handleScrollToTop')),
        (_) {},
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
      expect(pos().pixels, 0, reason: 'status bar tap should scroll $route to the top');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 3));
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
