import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/library_providers.dart';
import '../domain/library_content.dart';

const _all = '__all';
const _favorites = '__fav';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key, this.initialCategory});
  final String? initialCategory;

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  late String _cat = widget.initialCategory ?? _all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final catalog = ref.watch(duaCatalogProvider).value ?? DuaCatalog.empty;
    final favs = ref.watch(duaBookmarksProvider).value ?? const <String>{};
    final list = catalog.duas.where((d) {
      if (_cat == _favorites && !favs.contains(d.id)) return false;
      if (_cat != _all && _cat != _favorites && d.category != _cat) return false;
      return d.matches(_query, lang);
    }).toList();

    Widget chip(String id, String label, {WaqtIconData? icon}) {
      final selected = _cat == id;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          avatar: icon == null ? null : WaqtIcon(icon, size: 16, color: selected ? c.onMint : c.muted),
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) {
            Haptics.tap();
            setState(() => _cat = id);
          },
        ),
      );
    }

    return SubScreen(
      title: l.libraryDuas,
      backLabel: l.tabLibrary,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 10),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l.duaSearchHint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: WaqtIcon(WaqtIcons.search, size: 20, color: c.muted),
                ),
                filled: true,
                fillColor: c.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: c.hairline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: c.accent),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
              children: [
                chip(_all, l.duaAll),
                chip(_favorites, l.duaFavorites, icon: WaqtIcons.bookmark),
                for (final cat in catalog.categories) chip(cat.id, cat.title.of(lang), icon: WaqtIcons.byKey(cat.icon)),
              ],
            ),
          ),
        ),
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: WaqtIcons.handHeart,
              text: _cat == _favorites ? l.librarySavedEmpty : l.hadithNoResults,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 10, Gap.screen, 0),
            sliver: SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => DuaCard(dua: list[i], saved: favs.contains(list[i].id)),
            ),
          ),
      ],
    );
  }
}

/// A dua: title, Arabic, transliteration, meaning, source and actions.
class DuaCard extends ConsumerWidget {
  const DuaCard({super.key, required this.dua, required this.saved});
  final Dua dua;
  final bool saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final prefs = ref.watch(settingsProvider.select((s) => s.reader));
    final share = ShareCardData(
      kicker: dua.title.of(lang),
      arabic: dua.arabic,
      text: dua.text.of(lang),
      reference: dua.source,
    );
    final long = dua.arabic.length > 90;

    return WaqtCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(dua.title.of(lang), style: WaqtType.sans(16, weight: 600, color: c.ink)),
              ),
              _Action(
                icon: saved ? WaqtIcons.bookmarkFilled : WaqtIcons.bookmark,
                color: saved ? c.brass : c.muted,
                label: saved ? l.quranRemoveBookmark : l.quranBookmark,
                onTap: () {
                  Haptics.light();
                  ref.read(bookmarkRepositoryProvider).toggle(BookmarkKind.dua, dua.id);
                },
              ),
              _Action(
                icon: WaqtIcons.share,
                color: c.muted,
                label: l.share,
                onTap: () => showShareCardSheet(context, share),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              dua.arabic,
              textAlign: long ? TextAlign.right : TextAlign.center,
              textDirection: TextDirection.rtl,
              style: WaqtType.arabic(
                long ? prefs.arabicSize * 0.82 : prefs.arabicSize,
                height: long ? 1.9 : 1.6,
                color: c.ink,
              ),
            ),
          ),
          if (dua.translit.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                dua.translit,
                style: WaqtType.sans(prefs.textSize - 2.5, color: c.muted, height: 1.5, style: FontStyle.italic),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(dua.text.of(lang), style: WaqtType.serif(prefs.textSize - 1, height: 1.55, color: c.ink)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(dua.source, style: WaqtType.sans(12.5, weight: 600, color: c.accent)),
              ),
              if (dua.count > 1)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(99)),
                  child: Text(l.duaRepeat('${dua.count}'), style: WaqtType.sans(12, weight: 600, color: c.brassText)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.color, required this.label, required this.onTap});
  final WaqtIconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox.square(
        dimension: 44,
        child: Center(child: WaqtIcon(icon, size: 19, color: color)),
      ),
    ),
  );
}
