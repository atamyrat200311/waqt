import 'package:flutter/material.dart';

/// Design tokens from `design/Waqt Style.dc.html` ("Emerald & brass").
///
/// Names mirror the CSS variables used in the design artboards so the two can be
/// compared side by side (see CLAUDE.md for the full table).
@immutable
class WaqtColors extends ThemeExtension<WaqtColors> {
  const WaqtColors({
    required this.bg,
    required this.card,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
    required this.mint,
    required this.onMint,
    required this.brass,
    required this.brassText,
    required this.brassSoft,
    required this.onBrassText,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.fill,
    required this.scrim,
    required this.isDark,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color muted;
  final Color hairline;
  final Color hero;
  final Color onHero;
  final Color onHeroMuted;
  final Color mint;
  final Color onMint;

  /// Brass is reserved for checks, the sun, streaks and progress rings.
  final Color brass;
  final Color brassText;
  final Color brassSoft;
  final Color onBrassText;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color fill;
  final Color scrim;
  final bool isDark;

  static const light = WaqtColors(
    bg: Color(0xFFF7F4EE),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF14201B),
    muted: Color(0xFF56635C),
    hairline: Color(0xFFE7E1D5),
    hero: Color(0xFF0F4C3A),
    onHero: Color(0xFFF7F4EE),
    onHeroMuted: Color(0xBDF7F4EE), // 74 %
    mint: Color(0xFFDFECE4),
    onMint: Color(0xFF0F4C3A),
    brass: Color(0xFFB88A3E),
    brassText: Color(0xFF8A6324),
    brassSoft: Color(0xFFF4EAD6),
    onBrassText: Color(0xFFFFFFFF),
    primary: Color(0xFF0F4C3A),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF0F4C3A),
    fill: Color(0xFFF0ECE4),
    scrim: Color(0x7014201B), // rgba(20,32,27,.44)
    isDark: false,
  );

  /// Android artboard uses a slightly cooler fill for the nav bar and keys.
  static final lightAndroid = light.copyWith(fill: const Color(0xFFEEEAE2));

  static const dark = WaqtColors(
    bg: Color(0xFF0A1310),
    card: Color(0xFF121D18),
    ink: Color(0xFFF0ECE3),
    muted: Color(0xFFA3AFA8),
    hairline: Color(0xFF22302A),
    hero: Color(0xFF143F32),
    onHero: Color(0xFFF0ECE3),
    onHeroMuted: Color(0xBDF0ECE3),
    mint: Color(0xFF173328),
    onMint: Color(0xFF6CC9A1),
    brass: Color(0xFFE0BD78),
    brassText: Color(0xFFE0BD78),
    brassSoft: Color(0xFF2A2418),
    onBrassText: Color(0xFF0A1310),
    primary: Color(0xFF6CC9A1),
    onPrimary: Color(0xFF0A1310),
    accent: Color(0xFF6CC9A1),
    fill: Color(0xFF17231E),
    scrim: Color(0x99000000),
    isDark: true,
  );

  /// Translucent white layers used on top of [hero] (prayer chips, tasbih).
  Color get heroLayer => Colors.white.withValues(alpha: 0.06);
  Color get heroLayerStrong => Colors.white.withValues(alpha: 0.14);

  /// Category colours for the spending breakdown on Me.
  Color spendFood() => const Color(0xFF4F8A71);
  Color spendBills() => const Color(0xFF8FB8A2);
  Color spendTransport() => const Color(0xFFC4D8CC);

  @override
  WaqtColors copyWith({
    Color? bg,
    Color? card,
    Color? ink,
    Color? muted,
    Color? hairline,
    Color? hero,
    Color? onHero,
    Color? onHeroMuted,
    Color? mint,
    Color? onMint,
    Color? brass,
    Color? brassText,
    Color? brassSoft,
    Color? onBrassText,
    Color? primary,
    Color? onPrimary,
    Color? accent,
    Color? fill,
    Color? scrim,
    bool? isDark,
  }) {
    return WaqtColors(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      hero: hero ?? this.hero,
      onHero: onHero ?? this.onHero,
      onHeroMuted: onHeroMuted ?? this.onHeroMuted,
      mint: mint ?? this.mint,
      onMint: onMint ?? this.onMint,
      brass: brass ?? this.brass,
      brassText: brassText ?? this.brassText,
      brassSoft: brassSoft ?? this.brassSoft,
      onBrassText: onBrassText ?? this.onBrassText,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      fill: fill ?? this.fill,
      scrim: scrim ?? this.scrim,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  WaqtColors lerp(WaqtColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return WaqtColors(
      bg: l(bg, other.bg),
      card: l(card, other.card),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      hairline: l(hairline, other.hairline),
      hero: l(hero, other.hero),
      onHero: l(onHero, other.onHero),
      onHeroMuted: l(onHeroMuted, other.onHeroMuted),
      mint: l(mint, other.mint),
      onMint: l(onMint, other.onMint),
      brass: l(brass, other.brass),
      brassText: l(brassText, other.brassText),
      brassSoft: l(brassSoft, other.brassSoft),
      onBrassText: l(onBrassText, other.onBrassText),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      accent: l(accent, other.accent),
      fill: l(fill, other.fill),
      scrim: l(scrim, other.scrim),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension WaqtColorsContext on BuildContext {
  WaqtColors get colors => Theme.of(this).extension<WaqtColors>()!;
}
