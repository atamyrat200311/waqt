import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app.dart';
import 'package:waqt/data/settings/app_settings.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() {
    // Home has looping animations (sun glow); reduce motion lets it settle.
    TestWidgetsFlutterBinding.instance.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearAccessibilityFeaturesTestValue());

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('first launch goes to onboarding, then the 3-tab shell', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: settingsOverrides(const AppSettings()),
      child: const WaqtApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Where do you pray?'), findsOneWidget);
    expect(find.text('Muslim World League · Hanafi Asr'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Never miss a prayer'), findsOneWidget);
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications are on'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    // Android (test default platform) adds the battery step.
    expect(find.text('Keep alerts on time'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Tools'), findsWidgets);
    expect(find.text('Me'), findsWidgets);
    await dispose(tester);
  });

  testWidgets('Turkmen locale falls back to English Material strings', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: settingsOverrides(const AppSettings(onboardingDone: true, language: 'tk')),
      child: const WaqtApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Şu gün'), findsWidgets);
    final ctx = tester.element(find.byType(Scaffold).first);
    expect(MaterialLocalizations.of(ctx).okButtonLabel, 'OK');
    await dispose(tester);
  });
}
