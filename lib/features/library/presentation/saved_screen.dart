import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/dimens.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../hadith/application/hadith_providers.dart';
import '../../hadith/domain/hadith.dart';
import '../../hadith/presentation/hadith_widgets.dart';
import '../application/library_providers.dart';
import '../domain/library_content.dart';
import 'duas_screen.dart';

enum _Kind { hadith, duas }

/// Bookmarked hadith and duas in one place.
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  _Kind _kind = _Kind.hadith;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = switch (_kind) {
      _Kind.hadith => _hadith(),
      _Kind.duas => _duas(),
    };
    return SubScreen(
      title: l.librarySaved,
      backLabel: l.tabLibrary,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 12),
          sliver: SliverToBoxAdapter(
            child: Segmented<_Kind>(
              value: _kind,
              options: [(_Kind.hadith, l.hadithTitle), (_Kind.duas, l.libraryDuas)],
              onChanged: (k) => setState(() => _kind = k),
            ),
          ),
        ),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(icon: WaqtIcons.bookmark, text: l.librarySavedEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => items[i],
            ),
          ),
      ],
    );
  }

  List<Widget> _hadith() {
    final marks = ref.watch(hadithBookmarksProvider).value ?? const [];
    final out = <Widget>[];
    for (final b in marks) {
      final parts = b.ref.split(':');
      final book = parts.length == 2 ? HadithBooks.byId(parts[0]) : null;
      final number = parts.length == 2 ? num.tryParse(parts[1]) : null;
      if (book == null || number == null) continue;
      final lang = ref.watch(hadithBookLanguageProvider(book.id));
      final e = ref.watch(hadithEditionProvider((book.id, lang))).value;
      final ar = ref.watch(hadithEditionProvider((book.id, 'ara'))).value;
      final h = e?.byNumber(number);
      if (h == null) continue;
      out.add(HadithCard(bookId: book.id, hadith: h, arabic: ar?.byNumber(number)));
    }
    return out;
  }

  List<Widget> _duas() {
    final ids = ref.watch(duaBookmarksProvider).value ?? const <String>{};
    final catalog = ref.watch(duaCatalogProvider).value ?? DuaCatalog.empty;
    return [
      for (final d in catalog.duas)
        if (ids.contains(d.id)) DuaCard(dua: d, saved: true),
    ];
  }
}
