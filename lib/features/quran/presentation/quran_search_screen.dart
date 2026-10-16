import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/quran_providers.dart';
import '../domain/quran.dart';
import 'quran_home_screen.dart';
import 'quran_reader.dart';

class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final translation = ref.watch(activeTranslationProvider);
    final index = ref.watch(quranSearchIndexProvider);
    final texts = ref.watch(quranTextsProvider).value;
    final jump = AyahRef.tryParse(_query);
    final surahs = _query.isEmpty ? const <SurahInfo>[] : searchSurahs(_query, lang).take(8).toList();
    final hits = index.value == null || jump != null
        ? const <int>[]
        : searchAyahs(
            query: _query,
            arabicNormalized: index.value!.arabic,
            translationNormalized: index.value!.translation,
          );

    return SubScreen(
      title: l.quranSearch,
      backLabel: l.quranTitle,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 6),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              style: WaqtType.sans(17, color: c.ink),
              decoration: InputDecoration(
                hintText: l.quranSearchHint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: WaqtIcon(WaqtIcons.search, size: 20, color: c.muted),
                ),
                filled: true,
                fillColor: c.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.hairline)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.accent)),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.title, 0, Gap.title, 10),
            child: Text(l.quranSearchIn('${translation.label} · ${translation.author}'), style: WaqtType.sans(12.5, color: c.muted)),
          ),
        ),
        if (jump != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
              child: WaqtCard(
                onTap: () => openReader(context, jump.index),
                child: Row(
                  children: [
                    IconTile(icon: WaqtIcons.arrowRight, small: true, background: c.mint, color: c.onMint),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.quranGoTo('${SurahInfo(jump.surah).translit} ${jump.surah}:${jump.ayah}'),
                        style: WaqtType.sans(16, weight: 600, color: c.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (surahs.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 10, Gap.screen, 0),
              child: WaqtGroup(
                children: [
                  for (final s in surahs) SurahRow(surah: s, language: lang, onTap: () => openReader(context, s.startIndex)),
                ],
              ),
            ),
          ),
        if (_query.length >= 2 && jump == null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.title, 18, Gap.title, 8),
              child: index.isLoading
                  ? const LinearProgressIndicator()
                  : Text(
                      hits.isEmpty && surahs.isEmpty ? l.quranNoResults : l.quranResults(hits.length),
                      style: WaqtType.kicker(color: c.muted, size: 12),
                    ),
            ),
          ),
          if (texts != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
              sliver: SliverList.separated(
                itemCount: hits.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final idx = hits[i];
                  final r = AyahRef.fromIndex(idx);
                  return WaqtCard(
                    onTap: () => openReader(context, idx),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${SurahInfo(r.surah).translit} · ${r.surah}:${r.ayah}',
                            style: WaqtType.sans(13, weight: 700, color: c.accent)),
                        const SizedBox(height: 6),
                        Text(
                          texts.arabic[idx],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                          style: WaqtType.quran(20, height: 1.8, color: c.ink),
                        ),
                        const SizedBox(height: 4),
                        _Highlighted(text: texts.translation[idx], query: _query),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }
}

/// Translation text with the (accent-folded) query highlighted.
class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query});
  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = WaqtType.sans(14.5, color: c.ink, height: 1.5);
    final q = query.toLowerCase();
    final lower = text.toLowerCase();
    final at = q.isEmpty ? -1 : lower.indexOf(q);
    if (at < 0) return Text(text, maxLines: 4, overflow: TextOverflow.ellipsis, style: base);
    // Show a window around the first hit for long ayahs.
    final from = at > 80 ? lower.lastIndexOf(' ', at - 60).clamp(0, at) : 0;
    final prefix = from > 0 ? '… ' : '';
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: prefix + text.substring(from, at)),
        TextSpan(
          text: text.substring(at, at + q.length),
          style: base.copyWith(backgroundColor: c.brassSoft, color: c.brassText, fontWeight: FontWeight.w700),
        ),
        TextSpan(text: text.substring(at + q.length)),
      ]),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: base,
    );
  }
}
