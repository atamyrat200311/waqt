import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../notifications/application/notification_service.dart';
import '../application/tools_providers.dart';
import '../domain/qibla.dart';
import 'qibla_compass.dart';

/// Full-screen compass.
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _wasFacing = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final q = ref.watch(qiblaProvider);
    final compass = ref.watch(compassProvider).value;
    final heading = compass?.heading;
    final facing = heading != null && isFacingQibla(q.bearing, heading);
    if (facing && !_wasFacing) Haptics.success();
    _wasFacing = facing;
    final place = displayPlaceName(ref.watch(settingsProvider.select((s) => s.effectiveLocation.name)), l);
    final deg = q.bearing.round();
    final width = MediaQuery.sizeOf(context).width;

    final hint = compass != null && !compass.hasSensor
        ? l.qiblaNoSensor('$deg')
        : compass?.needsCalibration ?? false
            ? l.qiblaCalibrate
            : facing
                ? l.qiblaFacing
                : l.qiblaTurn;

    return SubScreen(
      title: l.qibla,
      backLabel: l.tabTools,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: [
                Center(
                  child: AnimatedContainer(
                    duration: Adaptive.motion(context, 250),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: facing ? c.mint : Colors.transparent,
                    ),
                    child: QiblaCompass(
                      bearing: q.bearing,
                      heading: heading,
                      size: (width - 80).clamp(200, 320),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: WaqtType.sans(17, weight: 600, color: facing ? c.accent : c.ink),
                  ),
                ),
                const SizedBox(height: 18),
                Text('$deg°', style: WaqtType.serif(48, tracking: -0.03, height: 1, color: c.ink)),
                const SizedBox(height: 6),
                Text(l.qiblaFromNorth('$deg'), style: WaqtType.sans(14, color: c.muted)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WaqtIcon(WaqtIcons.pin, size: 16, color: c.accent),
                    const SizedBox(width: 6),
                    Flexible(child: Text(place, style: WaqtType.sans(14, weight: 600, color: c.ink))),
                    const SizedBox(width: 8),
                    Text('· ${l.qiblaDistance(q.km.round().toString())}', style: WaqtType.sans(14, color: c.muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
