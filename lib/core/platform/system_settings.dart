import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// Shortcuts into system settings. Android uses the `waqt/system` channel in
/// MainActivity.kt; elsewhere (and on failure) the app's settings page opens.
abstract final class SystemSettings {
  static const _channel = MethodChannel('waqt/system');

  /// Battery optimisation list (so the user can pick "Unrestricted").
  static Future<void> openBattery() => _open('openBatterySettings');

  /// The app's notification settings (after a permanent denial).
  static Future<void> openNotifications() => _open('openNotificationSettings');

  static Future<void> _open(String method) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        if (await _channel.invokeMethod<bool>(method) ?? false) return;
      } on PlatformException catch (_) {
      } on MissingPluginException catch (_) {}
    }
    await Geolocator.openAppSettings();
  }
}
