import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/settings/settings_controller.dart';
import 'data/settings/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsRepo = SettingsRepository(SharedPrefsStore());
  final settings = await settingsRepo.load();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const WaqtApp(),
    ),
  );
}
