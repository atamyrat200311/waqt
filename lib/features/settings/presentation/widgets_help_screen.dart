import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';

class WidgetsHelpScreen extends StatelessWidget {
  const WidgetsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return SubScreen(
      title: l.widgetsHelpTitle,
      backLabel: l.settingsTitle,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
          sliver: SliverList.list(children: [
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
            Text(l.widgetsHelpData, textAlign: TextAlign.center, style: WaqtType.sans(13, color: c.muted, height: 1.5)),
          ]),
        ),
      ],
    );
  }
}
