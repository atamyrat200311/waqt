import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../watch/application/watch_sync.dart';

class WidgetsHelpScreen extends ConsumerWidget {
  const WidgetsHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final watch = ref.watch(watchStatusProvider).value;
    return SubScreen(
      title: l.widgetsHelpTitle,
      backLabel: l.settingsTitle,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
          sliver: SliverList.list(
            children: [
              WaqtCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconTile(icon: WaqtIcons.widgets, background: c.mint, color: c.onMint),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        Adaptive.isCupertino(context) ? l.widgetsHelpIos : l.widgetsHelpAndroid,
                        style: WaqtType.sans(15, color: c.ink, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.widgetsHelpData,
                textAlign: TextAlign.center,
                style: WaqtType.sans(13, color: c.muted, height: 1.5),
              ),
              if (Adaptive.isCupertino(context)) ...[
                const SizedBox(height: 20),
                WaqtCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTile(icon: WaqtIcons.watch, background: c.brassSoft, color: c.brassText),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.watchTitle, style: WaqtType.sans(17, weight: 600, color: c.ink)),
                            if (watch != null && watch.paired) ...[
                              const SizedBox(height: 2),
                              Text(
                                watch.installed ? l.watchStatusReady : l.watchStatusNotInstalled,
                                style: WaqtType.sans(13, weight: 600, color: watch.installed ? c.accent : c.brassText),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(l.watchHelp, style: WaqtType.sans(15, color: c.ink, height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
