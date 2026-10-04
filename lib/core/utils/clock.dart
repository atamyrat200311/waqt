import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable "now" so tests can freeze time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Ticks at the start of every minute. Used everywhere except the hero
/// countdown. Riverpod pauses it while no visible widget listens.
final minuteTickProvider = StreamProvider<DateTime>((ref) {
  final now = ref.watch(clockProvider);
  return _ticks(now, const Duration(minutes: 1));
});

/// Ticks every second — only the Home hero countdown watches this, and only
/// while Home is visible and the app is in the foreground.
final secondTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final now = ref.watch(clockProvider);
  return _ticks(now, const Duration(seconds: 1));
});

/// App lifecycle as a provider (resume triggers recomputation, e.g. after a
/// time-zone change or a long sleep).
final appLifecycleProvider = NotifierProvider<AppLifecycleNotifier, AppLifecycleState>(
  AppLifecycleNotifier.new,
);

class AppLifecycleNotifier extends Notifier<AppLifecycleState> {
  @override
  AppLifecycleState build() {
    final listener = AppLifecycleListener(onStateChange: (s) => state = s);
    ref.onDispose(listener.dispose);
    return WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  }
}

Stream<DateTime> _ticks(DateTime Function() now, Duration every) async* {
  yield now();
  while (true) {
    final n = now();
    final ms = every.inMilliseconds;
    final wait = ms - (n.millisecondsSinceEpoch % ms);
    await Future<void>.delayed(Duration(milliseconds: wait + 5));
    yield now();
  }
}
