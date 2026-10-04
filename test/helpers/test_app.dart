import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/data/settings/settings_controller.dart';
import 'package:waqt/data/settings/settings_repository.dart';

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

List<Override> settingsOverrides(AppSettings settings) => [
      settingsRepositoryProvider.overrideWithValue(SettingsRepository(MemoryStore())),
      initialSettingsProvider.overrideWithValue(settings),
    ];

ProviderContainer testContainer(AppSettings settings, [List<Override> extra = const []]) =>
    ProviderContainer(overrides: [...settingsOverrides(settings), ...extra]);
