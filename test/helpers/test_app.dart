import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:waqt/core/utils/clock.dart';
import 'package:waqt/data/db/database_provider.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/data/settings/settings_controller.dart';
import 'package:waqt/data/settings/settings_repository.dart';
import 'package:waqt/features/notifications/application/notification_scheduler.dart';
import 'package:waqt/features/notifications/application/notification_service.dart';
import 'package:waqt/features/tools/application/tools_providers.dart';
import 'package:waqt/features/widgets/application/widget_sync.dart';

import 'test_db.dart';

/// Loads the bundled fonts so screenshot tests render real typography.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('assets/fonts/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('Fraunces', ['Fraunces-Variable.ttf']);
  await load('PlusJakartaSans', ['PlusJakartaSans-Variable.ttf']);
  await load('Amiri', ['Amiri-Regular.ttf', 'Amiri-Bold.ttf']);
}

/// Default frozen "now" for widget tests: Sunday 4 Oct 2026, 16:00 in
/// Ashgabat (after Asr, before Maghrib).
final testNow = DateTime.utc(2026, 10, 4, 11);

/// Notification service that never touches the platform.
class FakeNotificationService extends NotificationService {
  bool enabled = true;

  @override
  Future<NotificationPermissions> permissions() async =>
      NotificationPermissions(enabled: enabled, exactAlarms: true);

  @override
  Future<bool> requestPermission() async => enabled = true;
}

/// Overrides for widget tests: in-memory settings + DB, frozen clock, no
/// background schedulers or platform channels.
List<Override> settingsOverrides(AppSettings settings, {DateTime? now}) {
  final t = now ?? testNow;
  return [
    settingsRepositoryProvider.overrideWithValue(SettingsRepository(MemoryStore())),
    initialSettingsProvider.overrideWithValue(settings),
    clockProvider.overrideWithValue(() => t),
    minuteTickProvider.overrideWith((ref) => Stream.value(t)),
    secondTickProvider.overrideWith((ref) => Stream.value(t)),
    databaseProvider.overrideWith((ref) {
      final db = memoryDb();
      ref.onDispose(db.close);
      return db;
    }),
    notificationServiceProvider.overrideWithValue(FakeNotificationService()),
    notificationSchedulerProvider.overrideWith((ref) {}),
    widgetSyncProvider.overrideWith((ref) {}),
    compassProvider.overrideWith((ref) => Stream.value(const CompassReading(heading: 200, accuracy: 10))),
  ];
}

ProviderContainer testContainer(AppSettings settings, [List<Override> extra = const []]) =>
    ProviderContainer(overrides: [...settingsOverrides(settings), ...extra]);
