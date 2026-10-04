import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/tasbih_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../prayer/location/city_catalog.dart';
import '../domain/qibla.dart';
import '../domain/tasbih.dart';

/// Device heading in degrees from north, or null when there is no compass.
class CompassReading {
  const CompassReading({required this.heading, this.accuracy});
  final double? heading;

  /// ± degrees; large values mean the sensor needs calibration.
  final double? accuracy;

  bool get hasSensor => heading != null;
  bool get needsCalibration => (accuracy ?? 0) > 30;
}

/// Live compass while a Qibla view is visible (auto-disposed otherwise so the
/// sensor stops).
final compassProvider = StreamProvider.autoDispose<CompassReading>((ref) {
  final events = FlutterCompass.events;
  if (events == null) return Stream.value(const CompassReading(heading: null));
  return events
      .map((e) => CompassReading(heading: e.heading, accuracy: e.accuracy))
      .timeout(const Duration(seconds: 3), onTimeout: (sink) => sink.add(const CompassReading(heading: null)));
});

/// Qibla bearing (true north) and distance for the configured location.
final qiblaProvider = Provider<({double bearing, double km})>((ref) {
  final loc = ref.watch(settingsProvider.select((s) => s.effectiveLocation));
  return (
    bearing: qiblaBearing(loc.latitude, loc.longitude),
    km: haversineKm(loc.latitude, loc.longitude, kaabaLatitude, kaabaLongitude),
  );
});

final tasbihProvider = NotifierProvider<TasbihController, TasbihState>(TasbihController.new);

class TasbihController extends Notifier<TasbihState> {
  @override
  TasbihState build() => TasbihState.preset();

  TasbihRepository get _repo => ref.read(tasbihRepositoryProvider);

  /// Counts one; returns what happened so the UI can pick a haptic.
  TasbihTap tap() {
    final (next, result) = state.tap();
    state = next;
    if (result == TasbihTap.phaseDone && !state.isComplete) {
      // Small pause on the full ring before moving to the next phrase.
      Timer(const Duration(milliseconds: 350), () {
        if (state.atPhaseEnd) state = state.advance();
      });
    }
    if (result == TasbihTap.complete) unawaited(_save(state));
    return result;
  }

  void reset() {
    if (state.total > 0 && !state.isComplete) unawaited(_save(state));
    state = state.restart();
  }

  void usePreset() => state = TasbihState.preset();

  void useCustom(String phrase, int goal) => state = TasbihState.custom(phrase, goal);

  Future<void> _save(TasbihState s) => _repo.addSession(s.label, s.total, s.goal);
}
