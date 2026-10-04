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
    expect(find.text('Start'), findsOneWidget);

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
