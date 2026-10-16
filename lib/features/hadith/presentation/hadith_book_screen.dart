import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/choice_sheet.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/ornaments.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/hadith_providers.dart';
import '../domain/hadith.dart';
import 'hadith_widgets.dart';

/// A collection: chapters (or the full list for 40-hadith books) + search.
class HadithBookScreen extends ConsumerStatefulWidget {
  const HadithBookScreen({super.key, required this.bookId});
  final String bookId;

  @override
  ConsumerState<HadithBookScreen> createState() => _HadithBookScreenState();
}

class _HadithBookScreenState extends ConsumerState<HadithBookScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final book = HadithBooks.byId(widget.bookId)!;
    final lang = ref.watch(hadithBookLanguageProvider(book.id));
    final preferred = ref.watch(hadithLanguageProvider);
    final edition = ref.watch(hadithEditionProvider((book.id, lang)));
    final arabic = ref.watch(hadithEditionProvider((book.id, 'ara'))).value;
    final pref = edition.value;
    // English is the complete edition; other translations miss some hadith,
    // which are shown in English (with an "EN" chip) rather than skipped.
    final english = lang == 'eng' ? pref : ref.watch(hadithEditionProvider((book.id, 'eng'))).value;
    final e = pref == null ? null : english;

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 10, Gap.screen, 6),
          child: Row(
            children: [
              Text(book.arabicName, textDirection: TextDirection.rtl, style: WaqtType.arabic(16, height: 1.3, color: c.muted)),
              if (e != null)
                Expanded(child: Text('  ·  ${l.hadithCount(e.hadiths.length)}', style: WaqtType.sans(14, color: c.muted))),
            ],
          ),
        ),
      ),
      if (preferred != lang)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, 8),
            child: Text(l.hadithFallback, style: WaqtType.sans(13, color: c.brassText)),
          ),
        ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 4, Gap.screen, 12),
          child: TextField(
            controller: _search,
            onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (mounted) setState(() => _query = v.trim());
              });
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.hadithSearchHint,
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

    if (e == null) {
      slivers.add(const SliverToBoxAdapter(child: HadithLoading()));
    } else if (_query.isNotEmpty) {
      final isArabic = RegExp('[\u0600-\u06FF]').hasMatch(_query);
      final searchEdition = isArabic ? arabic : pref;
      final index = ref.watch(hadithSearchIndexProvider((book.id, isArabic ? 'ara' : lang))).value;
      final found = index == null || searchEdition == null ? null : searchHadith(searchEdition, index, _query);
      final hits = found == null ? null : [for (final h in found) ?e.byNumber(h.number)];
      if (hits == null) {
        slivers.add(const SliverToBoxAdapter(child: HadithLoading()));
      } else if (hits.isEmpty) {
        slivers.add(SliverToBoxAdapter(child: EmptyState(icon: WaqtIcons.search, text: l.hadithNoResults)));
      } else {
        slivers.add(_hadithList(book.id, hits, arabic, pref, highlight: _query));
      }
    } else if (e.flat) {
      slivers.add(_hadithList(book.id, e.hadiths, arabic, pref));
    } else {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(Radii.card(context)),
              border: Border.all(color: c.hairline),
            ),
            sliver: SliverList.separated(
              itemCount: e.sections.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: c.hairline, indent: 64),
              itemBuilder: (context, i) {
                final s = e.sections[i];
                return InkWell(
                  onTap: () => context.push(Routes.hadithSection(book.id, s.id)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                    child: Row(
                      children: [
                        StarBadge(label: '${s.id}', color: c.hairline, textColor: c.ink, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: WaqtType.sans(15.5, weight: 600, color: c.ink)),
                              const SizedBox(height: 2),
                              Text(
                                l.hadithRange(_n(s.first), _n(s.last)),
                                style: WaqtType.sans(13, color: c.muted),
                              ),
                            ],
                          ),
                        ),
                        WaqtIcon(WaqtIcons.chevronRight, size: 16, color: c.muted),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return SubScreen(
      title: hadithBookName(l, book.id),
      backLabel: l.tabLibrary,
      trailing: book.translations.length > 1
          ? PillButton(
              label: hadithLanguageName(l, lang),
              style: PillStyle.fill,
              height: 36,
              fontSize: 13.5,
              onPressed: () async {
                final picked = await showChoiceSheet<String>(
                  context,
                  title: l.hadithTranslation,
                  selected: lang,
                  options: [for (final t in book.translations) (t, hadithLanguageName(l, t), null)],
                );
                if (picked != null) {
                  await ref.read(settingsProvider.notifier).setReader((r) => r.copyWith(hadithLanguage: () => picked));
                }
              },
            )
          : null,
      slivers: slivers,
    );
  }

  String _n(num v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  Widget _hadithList(String bookId, List<Hadith> list, HadithEdition? arabic, HadithEdition? pref, {String? highlight}) =>
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
        sliver: SliverList.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final translated = pref?.byNumber(list[i].number);
            return HadithCard(
              bookId: bookId,
              hadith: translated ?? list[i],
              fallback: translated == null && pref?.language != 'eng',
              arabic: arabic?.byNumber(list[i].number),
              highlight: highlight,
            );
          },
        ),
      );
}

/// One chapter of a large collection.
class HadithSectionScreen extends ConsumerWidget {
  const HadithSectionScreen({super.key, required this.bookId, required this.sectionId});
  final String bookId;
  final int sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = ref.watch(hadithBookLanguageProvider(bookId));
    final pref = ref.watch(hadithEditionProvider((bookId, lang))).value;
    final english = lang == 'eng' ? pref : ref.watch(hadithEditionProvider((bookId, 'eng'))).value;
    final e = pref == null ? null : english;
    final arabic = ref.watch(hadithEditionProvider((bookId, 'ara'))).value;
    final section = pref?.sections.where((s) => s.id == sectionId).firstOrNull ??
        e?.sections.where((s) => s.id == sectionId).firstOrNull;
    final list = e?.inSection(sectionId) ?? const <Hadith>[];

    return SubScreen(
      title: section?.name ?? hadithBookName(l, bookId),
      backLabel: hadithBookName(l, bookId),
      slivers: [
        if (e == null)
          const SliverToBoxAdapter(child: HadithLoading())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final translated = pref?.byNumber(list[i].number);
                return HadithCard(
                  bookId: bookId,
                  hadith: translated ?? list[i],
                  fallback: translated == null && lang != 'eng',
                  arabic: arabic?.byNumber(list[i].number),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Compact card for a collection on the Library hub.
class HadithBookTile extends ConsumerWidget {
  const HadithBookTile({super.key, required this.book});
  final HadithBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    return WaqtCard(
      onTap: () => context.push(Routes.hadithBook(book.id)),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: WaqtIcons.scroll, small: true, background: book.featured ? c.brassSoft : c.mint, color: book.featured ? c.brassText : c.onMint),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(hadithBookName(l, book.id),
              maxLines: 2, overflow: TextOverflow.ellipsis, style: WaqtType.sans(15, weight: 600, color: c.ink, height: 1.25)),
          const SizedBox(height: 4),
          Text(book.arabicName, textDirection: TextDirection.rtl, style: WaqtType.arabic(15, height: 1.4, color: c.muted)),
        ],
      ),
    );
  }
}
