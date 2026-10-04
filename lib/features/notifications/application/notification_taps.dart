import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/routes.dart';
import '../domain/notification_plan.dart';
import 'notification_service.dart';

String routeForPayload(NotificationPayload p) => switch (p) {
      MarkPayload(:final prayer, :final day) => Routes.markPrayer(prayer.name, day.value),
      AdhkarPayload(:final set) => Routes.adhkar(set.name),
      TodayPayload() => Routes.today,
    };

/// Routes notification taps (including the one that launched the app).
final notificationTapRouterProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  void go(NotificationPayload p) => ref.read(appRouterProvider).go(routeForPayload(p));

  final launch = service.takeLaunchPayload();
  if (launch != null) scheduleMicrotask(() => go(launch));
  final sub = service.taps.listen(go);
  ref.onDispose(sub.cancel);
});
