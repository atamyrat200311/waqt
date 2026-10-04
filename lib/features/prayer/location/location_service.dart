import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/settings/app_settings.dart';
import 'city_catalog.dart';

enum LocationFailure { serviceOff, denied, deniedForever, timeout, unknown }

class LocationResult {
  const LocationResult.ok(SavedLocation this.location) : failure = null;
  const LocationResult.failed(LocationFailure this.failure) : location = null;
  final SavedLocation? location;
  final LocationFailure? failure;
}

/// GPS (coarse) + bundled city catalogue. Never calls a geocoding API: the
/// display name is the nearest bundled city ("Near Mary") or coordinates.
class LocationService {
  LocationService(this._catalog);

  final Future<CityCatalog> Function() _catalog;

  static const nearKm = 30.0;
  static const nearbyKm = 120.0;

  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.failed(LocationFailure.serviceOff);
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        return const LocationResult.failed(LocationFailure.denied);
      }
      if (perm == LocationPermission.deniedForever) {
        return const LocationResult.failed(LocationFailure.deniedForever);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final tz = await deviceTimezone();
      final catalog = await _catalog();
      return LocationResult.ok(SavedLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        name: displayName(catalog, pos.latitude, pos.longitude),
        timezone: tz,
      ));
    } on Exception catch (e) {
      final timeout = e.toString().contains('Timeout');
      return LocationResult.failed(timeout ? LocationFailure.timeout : LocationFailure.unknown);
    }
  }

  /// "Ashgabat" if within 30 km of a bundled city, "~Mary" within 120 km
  /// (UI renders it as "Near Mary"), otherwise rounded coordinates.
  static String displayName(CityCatalog catalog, double lat, double lng) {
    final hit = catalog.nearest(lat, lng);
    if (hit != null && hit.$2 <= nearKm) return hit.$1.name;
    if (hit != null && hit.$2 <= nearbyKm) return '~${hit.$1.name}';
    String f(double v, String pos, String neg) =>
        '${v.abs().toStringAsFixed(2)}°${v >= 0 ? pos : neg}';
    return '${f(lat, 'N', 'S')} ${f(lng, 'E', 'W')}';
  }

  static Future<String> deviceTimezone() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } on Exception {
      return 'UTC';
    }
  }

  static Future<void> openSettings() => Geolocator.openAppSettings();
}

final cityCatalogProvider = FutureProvider<CityCatalog>((ref) async {
  final json = await rootBundle.loadString('assets/data/cities.json');
  return CityCatalog.fromJsonString(json);
});

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(() => ref.read(cityCatalogProvider.future)),
);
