import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Phase 1 placeholder.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, this.markPrayer, this.markDay});

  /// Set by notification deep links: open the mark sheet for this prayer.
  final String? markPrayer;
  final String? markDay;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
          child: Text(context.l10n.tabToday, style: WaqtType.title(color: c.ink)),
        ),
      ),
    );
  }
}
