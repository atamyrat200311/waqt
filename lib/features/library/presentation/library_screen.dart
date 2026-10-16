import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/layout.dart';

/// Library tab (hadith, duas, 99 Names, guides).
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(slivers: [SliverToBoxAdapter(child: TabHeader(title: context.l10n.tabLibrary))]),
    );
  }
}
