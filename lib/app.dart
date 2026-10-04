import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/l10n_ext.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/db/enums.dart';
import 'data/settings/settings_controller.dart';
import 'features/notifications/application/notification_scheduler.dart';
import 'features/notifications/application/notification_taps.dart';
import 'features/prayer/application/period_mode_sync.dart';

class WaqtApp extends ConsumerWidget {
  const WaqtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // App-wide background sync (no UI): notification schedule, period mode.
    ref.watch(notificationSchedulerProvider);
    ref.watch(periodModeSyncProvider);
    ref.watch(notificationTapRouterProvider);
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    final language = ref.watch(settingsProvider.select((s) => s.language));

    return MaterialApp.router(
      title: 'Waqt',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(platform: defaultTargetPlatform),
      darkTheme: AppTheme.dark(platform: defaultTargetPlatform),
      themeMode: switch (theme) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      locale: language == null ? null : Locale(language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // Flutter ships no Material/Cupertino strings for Turkmen; fall back to English.
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      builder: (context, child) {
        // Cap text scaling at 1.3× (accessibility bar) so layouts never break.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
    );
  }
}

const _fallbackLocale = Locale('en');

bool _needsFallback(Locale locale) => locale.languageCode == 'tk';

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _needsFallback(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_fallbackLocale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _needsFallback(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(_fallbackLocale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}
