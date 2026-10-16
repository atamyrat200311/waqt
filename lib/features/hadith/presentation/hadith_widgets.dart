import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/ornaments.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/hadith_providers.dart';
import '../domain/hadith.dart';

String hadithBookName(AppLocalizations l, String id) => switch (id) {
      'nawawi' => l.hadithBookNawawi,
      'qudsi' => l.hadithBookQudsi,
      'bukhari' => l.hadithBookBukhari,
      'muslim' => l.hadithBookMuslim,
      _ => id,
    };

String hadithLanguageName(AppLocalizations l, String code) => switch (code) {
      'rus' => l.langRussian,
      'tur' => l.langTurkish,
      _ => l.langEnglish,
    };

ShareCardData hadithShareData(AppLocalizations l, String bookId, Hadith h, {Hadith? arabic, String? kicker}) =>
    ShareCardData(
      kicker: kicker ?? l.hadithTitle,
      arabic: arabic?.text,
      text: h.text,
      reference: '${hadithBookName(l, bookId)} · ${h.label}',
    );

/// One hadith: number, translation, optional Arabic, grade, actions.
class HadithCard extends ConsumerWidget {
  const HadithCard({
    super.key,
    required this.bookId,
    required this.hadith,
    this.arabic,
    this.highlight,
    this.fallback = false,
  });

  final String bookId;
  final Hadith hadith;
  final Hadith? arabic;

  /// Search term to emphasise.
  final String? highlight;

  /// Shown in English because the chosen translation lacks this hadith.
  final bool fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final prefs = ref.watch(settingsProvider.select((s) => s.reader));
    final key = '$bookId:${hadith.label}';
    final saved = ref.watch(hadithBookmarkRefsProvider).contains(key);
    final share = hadithShareData(l, bookId, hadith, arabic: arabic);

    return WaqtCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StarBadge(label: hadith.label, color: c.hairline, textColor: c.ink, size: 36),
              const SizedBox(width: 8),
              if (fallback) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(border: Border.all(color: c.hairline), borderRadius: BorderRadius.circular(6)),
                  child: Text('EN', style: WaqtType.sans(11, weight: 700, color: c.muted)),
                ),
                const SizedBox(width: 6),
              ],
              if (hadith.grade.isNotEmpty)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.mint, borderRadius: BorderRadius.circular(99)),
                    child: Text(
                      hadith.grade,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtType.sans(11.5, weight: 600, color: c.onMint),
                    ),
                  ),
                )
              else
                const Spacer(),
              if (hadith.grade.isNotEmpty) const Spacer(),
              _IconAction(
                icon: saved ? WaqtIcons.bookmarkFilled : WaqtIcons.bookmark,
                color: saved ? c.brass : c.muted,
                label: saved ? l.quranRemoveBookmark : l.quranBookmark,
                onTap: () {
                  Haptics.light();
                  ref.read(bookmarkRepositoryProvider).toggle(BookmarkKind.hadith, key);
                },
              ),
              _IconAction(
                icon: WaqtIcons.copy,
                color: c.muted,
                label: l.copy,
                onTap: () => copyText(context, share.plain()),
              ),
              _IconAction(
                icon: WaqtIcons.share,
                color: c.muted,
                label: l.share,
                onTap: () => showShareCardSheet(context, share),
              ),
            ],
          ),
          if (prefs.hadithArabic && arabic != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                arabic!.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: WaqtType.arabic(prefs.textSize + 5, height: 1.85, color: c.ink),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Body(text: hadith.text, highlight: highlight, size: prefs.textSize),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.text, required this.size, this.highlight});
  final String text;
  final String? highlight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = WaqtType.serif(size, height: 1.6, color: c.ink);
    final q = highlight?.trim().toLowerCase() ?? '';
    final at = q.length < 3 ? -1 : text.toLowerCase().indexOf(q);
    if (at < 0) return SelectableText(text, style: base);
    return SelectableText.rich(
      TextSpan(children: [
        TextSpan(text: text.substring(0, at)),
        TextSpan(
          text: text.substring(at, at + q.length),
          style: base.copyWith(backgroundColor: c.brassSoft, color: c.brassText, fontWeight: FontWeight.w700),
        ),
        TextSpan(text: text.substring(at + q.length)),
      ]),
      style: base,
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.color, required this.label, required this.onTap});
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
          child: SizedBox.square(dimension: 40, child: Center(child: WaqtIcon(icon, size: 19, color: color))),
        ),
      );
}

/// Loading placeholder for large books (Bukhari takes a moment to unpack).
class HadithLoading extends StatelessWidget {
  const HadithLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(c.accent))),
    );
  }
}
