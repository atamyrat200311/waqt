import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Material 3 themes built from the design tokens. Most widgets read
/// [WaqtColors] directly; the [ColorScheme] is mapped so stock Material
/// widgets (dialogs, pickers, switches) also match.
abstract final class AppTheme {
  static ThemeData light({TargetPlatform? platform}) {
    final android = (platform ?? defaultTargetPlatform) == TargetPlatform.android;
    return _build(android ? WaqtColors.lightAndroid : WaqtColors.light, platform);
  }

  static ThemeData dark({TargetPlatform? platform}) =>
      _build(WaqtColors.dark, platform);

  static ThemeData _build(WaqtColors c, TargetPlatform? platform) {
    final brightness = c.isDark ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.mint,
      onPrimaryContainer: c.onMint,
      secondary: c.brass,
      onSecondary: c.onBrassText,
      secondaryContainer: c.brassSoft,
      onSecondaryContainer: c.brassText,
      tertiary: c.accent,
      onTertiary: c.onPrimary,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      surface: c.bg,
      onSurface: c.ink,
      onSurfaceVariant: c.muted,
      surfaceContainerLowest: c.card,
      surfaceContainerLow: c.card,
      surfaceContainer: c.fill,
      surfaceContainerHigh: c.card,
      surfaceContainerHighest: c.fill,
      outline: c.hairline,
      outlineVariant: c.hairline,
      scrim: c.scrim,
    );

    final baseText = TextTheme(
      displayLarge: WaqtType.hero(color: c.ink),
      displayMedium: WaqtType.serif(48, tracking: -0.03, color: c.ink),
      headlineLarge: WaqtType.title(color: c.ink),
      headlineMedium: WaqtType.serif(28, tracking: -0.015, color: c.ink),
      headlineSmall: WaqtType.section(color: c.ink),
      titleLarge: WaqtType.sans(17, weight: 600, color: c.ink),
      titleMedium: WaqtType.sans(16, weight: 600, color: c.ink),
      titleSmall: WaqtType.sans(15, weight: 600, color: c.ink),
      bodyLarge: WaqtType.sans(16, color: c.ink),
      bodyMedium: WaqtType.sans(15, color: c.ink),
      bodySmall: WaqtType.sans(13, color: c.muted),
      labelLarge: WaqtType.sans(15, weight: 600, color: c.ink),
      labelMedium: WaqtType.sans(13, weight: 600, color: c.ink),
      labelSmall: WaqtType.sans(12, weight: 600, color: c.muted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      platform: platform,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      fontFamily: WaqtType.sansFamily,
      textTheme: baseText,
      extensions: [c],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: c.ink, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: WaqtType.serif(22, tracking: -0.01, color: c.ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.card,
        modalBarrierColor: c.scrim,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: WaqtType.serif(24, color: c.ink),
        contentTextStyle: WaqtType.sans(15, color: c.muted, height: 1.45),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.hairline,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.brass : Colors.transparent,
        ),
        side: BorderSide(color: c.hairline, width: 2),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.mint,
        selectionHandleColor: c.accent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink,
        contentTextStyle: WaqtType.sans(14, weight: 600, color: c.bg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: c.fill,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.mint,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => WaqtType.sans(
            12,
            weight: s.contains(WidgetState.selected) ? 700 : 500,
            color: s.contains(WidgetState.selected) ? c.ink : c.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected) ? c.onMint : c.muted,
          ),
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: c.accent,
        scaffoldBackgroundColor: c.bg,
        barBackgroundColor: c.bg,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
