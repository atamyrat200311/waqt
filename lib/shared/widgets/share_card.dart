import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/platform/adaptive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'buttons.dart';
import 'ornaments.dart';
import 'waqt_icon.dart';

enum ShareTheme { emerald, paper, night }

/// Content of a shareable card (ayah, hadith, dua, Name, milestone).
@immutable
class ShareCardData {
  const ShareCardData({
    required this.kicker,
    this.arabic,
    this.text,
    required this.reference,
    this.arabicQuran = false,
    this.big,
    this.credit,
  });

  /// Small caps line at the top ("AYAH OF THE DAY").
  final String kicker;
  final String? arabic;
  final String? text;

  /// Source line ("Al-Baqarah · 2:255").
  final String reference;

  /// Translator / source credit shown small under the reference.
  final String? credit;

  /// Use the Quran face for [arabic].
  final bool arabicQuran;

  /// Optional huge number/word (streak "30", khatm "✓").
  final String? big;

  /// Plain-text version for "Share text" / copy.
  String plain() => [
        ?arabic,
        ?text,
        '— $reference',
      ].join('\n\n');
}

/// Copies plain text and confirms with a snackbar.
Future<void> copyText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  Haptics.light();
  if (context.mounted) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.copied), duration: const Duration(seconds: 2)));
  }
}

/// Opens the system share sheet with text.
Future<void> shareText(BuildContext context, String text) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(ShareParams(
    text: text,
    sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
  ));
}

/// Preview sheet: pick a theme, then share the card as a PNG.
Future<void> showShareCardSheet(BuildContext context, ShareCardData data) =>
    Adaptive.showSheet<void>(context, builder: (ctx) => _ShareSheet(data: data));

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.data});
  final ShareCardData data;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _key = GlobalKey();
  ShareTheme _theme = ShareTheme.emerald;
  bool _arabic = true;
  bool _text = true;
  bool _busy = false;

  ShareCardData get _shown => ShareCardData(
        kicker: widget.data.kicker,
        arabic: _arabic ? widget.data.arabic : null,
        text: _text ? widget.data.text : null,
        reference: widget.data.reference,
        arabicQuran: widget.data.arabicQuran,
        big: widget.data.big,
        credit: _text ? widget.data.credit : null,
      );

  Future<void> _shareImage() async {
    setState(() => _busy = true);
    try {
      final boundary = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1080 / boundary.size.width);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/waqt_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(png!.buffer.asUint8List());
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final hasBoth = widget.data.arabic != null && widget.data.text != null;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.share, style: WaqtType.serif(26, weight: 500, tracking: -0.015, color: c.ink)),
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: RepaintBoundary(key: _key, child: ShareCard(data: _shown, theme: _theme)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final (t, label) in [
                (ShareTheme.emerald, l.shareThemeEmerald),
                (ShareTheme.paper, l.shareThemePaper),
                (ShareTheme.night, l.shareThemeNight),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _theme == t,
                  onSelected: (_) => setState(() => _theme = t),
                ),
              if (hasBoth) ...[
                FilterChip(
                  label: Text(l.shareWithArabic),
                  selected: _arabic,
                  onSelected: (v) => setState(() => _arabic = v || !_text),
                ),
                FilterChip(
                  label: Text(l.shareWithTranslation),
                  selected: _text,
                  onSelected: (v) => setState(() => _text = v || !_arabic),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          BigButton(label: l.shareImage, onPressed: _busy ? null : _shareImage),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: l.shareText,
                  icon: WaqtIcons.share,
                  style: PillStyle.fill,
                  expand: true,
                  onPressed: () => shareText(context, '${_shown.plain()}\n\n— Waqt'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PillButton(
                  label: l.copy,
                  icon: WaqtIcons.copy,
                  style: PillStyle.fill,
                  expand: true,
                  onPressed: () => copyText(context, _shown.plain()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The card itself (4:5, Instagram/WhatsApp-status friendly).
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.data, required this.theme});

  final ShareCardData data;
  final ShareTheme theme;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (bg, ink, muted, accent) = switch (theme) {
      ShareTheme.emerald => (const Color(0xFF0F4C3A), const Color(0xFFF7F4EE), const Color(0xBDF7F4EE), const Color(0xFFE0BD78)),
      ShareTheme.paper => (const Color(0xFFF6EEDC), const Color(0xFF2E2416), const Color(0xFF6B5B45), const Color(0xFF8A6324)),
      ShareTheme.night => (const Color(0xFF0A1310), const Color(0xFFF0ECE3), const Color(0xFFA3AFA8), const Color(0xFFE0BD78)),
    };
    final arabic = data.arabic;
    final text = data.text;
    final longArabic = (arabic?.length ?? 0) > 160;
    final longText = (text?.length ?? 0) > 260;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: bg,
          child: Stack(
            children: [
              Positioned(right: -90, top: -90, child: StarPattern(size: 300, opacity: 0.12, color: accent)),
              Positioned(left: -110, bottom: -110, child: StarPattern(size: 300, opacity: 0.07, color: accent)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      data.kicker.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtType.kicker(color: accent, size: 11),
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 300,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (data.big != null)
                                  Text(data.big!, style: WaqtType.serif(96, weight: 400, height: 1, color: ink)),
                                if (arabic != null)
                                  Text(
                                    arabic,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: data.arabicQuran
                                        ? WaqtType.quran(longArabic ? 20 : 27, height: 1.9, color: ink)
                                        : WaqtType.arabic(longArabic ? 20 : 26, height: 1.8, color: ink),
                                  ),
                                if (arabic != null && text != null) ...[
                                  const SizedBox(height: 14),
                                  Container(width: 36, height: 1.5, color: accent.withValues(alpha: 0.7)),
                                  const SizedBox(height: 14),
                                ],
                                if (text != null)
                                  Text(
                                    text,
                                    textAlign: TextAlign.center,
                                    style: WaqtType.serif(longText ? 13.5 : 16.5, height: 1.5, color: ink),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      data.reference,
                      textAlign: TextAlign.center,
                      style: WaqtType.sans(13, weight: 600, color: accent),
                    ),
                    if (data.credit != null)
                      Text(data.credit!, textAlign: TextAlign.center, style: WaqtType.sans(10.5, color: muted)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StarBadge(label: '', color: accent, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l.shareFooter,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtType.sans(11, weight: 500, color: muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
