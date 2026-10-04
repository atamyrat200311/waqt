import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/settings/settings_controller.dart';
import 'data/settings/settings_repository.dart';
import 'features/notifications/application/notification_service.dart';
import 'features/notifications/background.dart';
import 'features/prayer/application/prayer_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ensureTimeZones();
  final settingsRepo = SettingsRepository(SharedPrefsStore());
  final settings = await settingsRepo.load();

  final notifications = NotificationService();
  try {
    await notifications.init(l10n: l10nForSettings(settings));
  } on Object catch (e) {
    debugPrint('Notifications unavailable: $e');
  }
  await initBackgroundWork();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        initialSettingsProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const WaqtApp(),
    ),
  );
}
