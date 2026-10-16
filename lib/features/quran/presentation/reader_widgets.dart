import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/settings/app_settings.dart';
import '../../../shared/widgets/ornaments.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../domain/quran.dart';

/// Colours for the reading surfaces (normal or warm "paper").
@immutable
class ReaderPalette {
  const ReaderPalette({
    required this.bg,
    required this.card,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.accent,
    required this.brass,
    required this.highlight,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color muted;
  final Color hairline;
  final Color accent;
  final Color brass;
  final Color highlight;

  factory ReaderPalette.of(BuildContext context, {required bool sepia}) {
    final c = context.colors;
    if (!sepia) {
      return ReaderPalette(
        bg: c.bg,
        card: c.card,
        ink: c.ink,
        muted: c.muted,
        hairline: c.hairline,
        accent: c.accent,
        brass: c.brass,
        highlight: c.mint,
      );
    }
    return c.isDark
        ? ReaderPalette(
            bg: const Color(0xFF17130D),
            card: const Color(0xFF201A12),
            ink: const Color(0xFFEDE3CF),
            muted: const Color(0xFFB3A68D),
            hairline: const Color(0xFF34291B),
            accent: c.brass,
            brass: c.brass,
            highlight: const Color(0xFF2E2416),
          )
        : const ReaderPalette(
            bg: Color(0xFFF5ECDA),
            card: Color(0xFFFBF5E9),
            ink: Color(0xFF33291B),
            muted: Color(0xFF76664F),
            hairline: Color(0xFFE6D9BF),
            accent: Color(0xFF7A5A1E),
            brass: Color(0xFFB88A3E),
            highlight: Color(0xFFEFDFC0),
          );
  }
}

String quranFamily(ReaderPrefs p) => p.quranFont == 'scheherazade' ? WaqtType.quranAltFamily : WaqtType.quranFamily;

/// Ornamental surah opening: Arabic name, transliteration, meaning, facts,
/// then the basmala when the surah has one.
class SurahHeader extends StatelessWidget {
  const SurahHeader({
    super.key,
    required this.surah,
    required this.palette,
    required this.basmala,
    required this.prefs,
    this.compact = false,
  });

  final SurahInfo surah;
  final ReaderPalette palette;
  final String basmala;
  final ReaderPrefs prefs;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = l.localeName;
    final p = palette;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 8 : 18, 16, 6),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: p.brass.withValues(alpha: 0.45)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(right: -60, top: -70, child: StarPattern(size: 200, opacity: 0.14, color: p.brass)),
                Positioned(left: -60, bottom: -80, child: StarPattern(size: 200, opacity: 0.10, color: p.brass)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Row(
                    children: [
                      StarBadge(label: '${surah.number}', color: p.brass, size: 40, textColor: p.ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(surah.translit, style: WaqtType.serif(21, weight: 500, color: p.ink)),
                            const SizedBox(height: 2),
                            Text(
                              '${surah.meaning(lang)} · ${surah.medinan ? l.quranMedinan : l.quranMeccan} · ${l.quranAyahCount(surah.ayahCount)}',
                              style: WaqtType.sans(12.5, color: p.muted, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        surah.arabic,
                        textDirection: TextDirection.rtl,
                        style: WaqtType.arabic(26, height: 1.3, color: p.ink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (surah.hasBasmala && basmala.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Text(
                basmala,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: WaqtType.quran(prefs.arabicSize * 0.85, family: quranFamily(prefs), height: 1.8, color: p.ink),
              ),
            ),
        ],
      ),
    );
  }
}

/// One ayah in the translation view.
class AyahTile extends StatelessWidget {
  const AyahTile({
    super.key,
    required this.index,
    required this.arabic,
    required this.translit,
    required this.translation,
    required this.prefs,
    required this.palette,
    required this.bookmarked,
    required this.onTap,
    required this.onMore,
    this.hidden = false,
    this.highlighted = false,
    this.read = false,
    this.translationRtl = false,
  });

  final int index;
  final String arabic;
  final String? translit;
  final String? translation;
  final ReaderPrefs prefs;
  final ReaderPalette palette;
  final bool bookmarked;
  final VoidCallback onTap;
  final VoidCallback onMore;

  /// Memorize mode: Arabic is blurred until tapped.
  final bool hidden;
  final bool highlighted;
  final bool read;
  final bool translationRtl;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = palette;
    final ref = AyahRef.fromIndex(index);
    final sajda = isSajda(index);
    final arabicText = Text(
      arabic,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: WaqtType.quran(prefs.arabicSize, family: quranFamily(prefs), height: 2.05, color: p.ink),
    );

    return Semantics(
      label: '${l.quranAyahN('${ref.ayah}')}. ${translation ?? ''}',
      button: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onMore,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          color: highlighted ? p.highlight : Colors.transparent,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  StarBadge(
                    label: '${ref.ayah}',
                    color: read ? p.brass : p.muted.withValues(alpha: 0.7),
                    textColor: read ? p.brass : p.muted,
                    size: 34,
                  ),
                  if (sajda) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.brass.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('۩ ${l.quranSajda}', style: WaqtType.sans(11.5, weight: 600, color: p.brass)),
                    ),
                  ],
                  const Spacer(),
                  if (bookmarked) WaqtIcon(WaqtIcons.bookmarkFilled, size: 18, color: p.brass),
                  Semantics(
                    button: true,
                    label: l.share,
                    excludeSemantics: true,
                    child: InkResponse(
                      onTap: onMore,
                      radius: 22,
                      child: SizedBox.square(
                        dimension: 40,
                        child: Center(child: Text('•••', style: WaqtType.sans(13, weight: 700, color: p.muted))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (hidden)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                      child: ExcludeSemantics(child: arabicText),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(99), border: Border.all(color: p.hairline)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WaqtIcon(WaqtIcons.eye, size: 16, color: p.accent),
                          const SizedBox(width: 6),
                          Text(l.quranTapToReveal, style: WaqtType.sans(13, weight: 600, color: p.accent)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                arabicText,
              if (translit != null) ...[
                const SizedBox(height: 8),
                Text(
                  translit!,
                  style: WaqtType.sans(prefs.textSize - 2, color: p.muted, height: 1.5, style: FontStyle.italic),
                ),
              ],
              if (translation != null) ...[
                const SizedBox(height: 8),
                Text(
                  translation!,
                  textDirection: translationRtl ? TextDirection.rtl : null,
                  style: WaqtType.serif(prefs.textSize, height: 1.6, color: p.ink),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
