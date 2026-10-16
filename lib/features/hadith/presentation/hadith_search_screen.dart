import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/hadith_providers.dart';
import '../domain/hadith.dart';
import 'hadith_widgets.dart';

/// Search every bundled collection at once (translation, or Arabic when the
/// query is Arabic).
class HadithSearchScreen extends ConsumerStatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  ConsumerState<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends ConsumerState<HadithSearchScreen> {
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final arabic = RegExp('[؀-ۿ]').hasMatch(_query);
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 10),
          child: TextField(
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 350), () {
                if (mounted) setState(() => _query = v.trim());
              });
            },
            decoration: InputDecoration(
              hintText: l.hadithSearchAllHint,
              prefixIcon: Padding(padding: const EdgeInsets.all(12), child: WaqtIcon(WaqtIcons.search, size: 20, color: c.muted)),
              filled: true,
              fillColor: c.card,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.hairline)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.accent)),
            ),
          ),
        ),
      ),
    ];

    if (_query.length >= 3) {
      var any = false;
      var loading = false;
      for (final book in HadithBooks.all) {
        final lang = arabic ? 'ara' : ref.watch(hadithBookLanguageProvider(book.id));
        final e = ref.watch(hadithEditionProvider((book.id, lang))).value;
        final index = ref.watch(hadithSearchIndexProvider((book.id, lang))).value;
        final ar = ref.watch(hadithEditionProvider((book.id, 'ara'))).value;
        final tr = arabic ? ref.watch(hadithEditionProvider((book.id, ref.watch(hadithBookLanguageProvider(book.id))))).value : e;
        if (e == null || index == null) {
          loading = true;
          continue;
        }
        final hits = searchHadith(e, index, _query, limit: 30);
        if (hits.isEmpty) continue;
        any = true;
        slivers
          ..add(SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.title, 16, Gap.title, 8),
              child: Text(
                '${hadithBookName(l, book.id)} · ${hits.length >= 30 ? '30+' : hits.length}',
                style: WaqtType.kicker(color: c.muted, size: 12),
              ),
            ),
          ))
          ..add(SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList.separated(
              itemCount: hits.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final h = hits[i];
                final shown = arabic ? (tr?.byNumber(h.number) ?? h) : h;
                return HadithCard(
                  bookId: book.id,
                  hadith: shown,
                  arabic: ar?.byNumber(h.number),
                  highlight: arabic ? null : _query,
                );
              },
            ),
          ));
      }
      if (loading) slivers.insert(1, const SliverToBoxAdapter(child: HadithLoading()));
      if (!any && !loading) {
        slivers.add(SliverToBoxAdapter(child: EmptyState(icon: WaqtIcons.search, text: l.hadithNoResults)));
      }
    }

    return SubScreen(title: l.hadithSearchAll, backLabel: l.tabLibrary, slivers: slivers);
  }
}
