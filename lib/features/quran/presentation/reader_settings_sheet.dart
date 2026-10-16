import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/settings/app_settings.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/choice_sheet.dart';
import '../../../shared/widgets/rows.dart';
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../application/quran_providers.dart';
import '../domain/translations.dart';
import 'reader_widgets.dart';

/// "Aa" sheet: sizes, script, translation and comfort options. When
/// [memorize] is given, also shows the memorize-mode switch.
Future<void> showReaderSettings(BuildContext context, {bool? memorize, ValueChanged<bool>? onMemorize}) =>
    Adaptive.showSheet<void>(
      context,
      builder: (ctx) => _ReaderSettings(memorize: memorize, onMemorize: onMemorize),
    );

class _ReaderSettings extends ConsumerStatefulWidget {
  const _ReaderSettings({this.memorize, this.onMemorize});
  final bool? memorize;
  final ValueChanged<bool>? onMemorize;

  @override
  ConsumerState<_ReaderSettings> createState() => _ReaderSettingsState();
}

class _ReaderSettingsState extends ConsumerState<_ReaderSettings> {
  late bool? _memorize = widget.memorize;

  void _set(ReaderPrefs Function(ReaderPrefs r) f) => ref.read(settingsProvider.notifier).setReader(f);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final prefs = ref.watch(settingsProvider.select((s) => s.reader));
    final translation = ref.watch(activeTranslationProvider);
    final basmala = ref.watch(quranArabicProvider).value?.first ?? 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

    Widget slider(String label, double value, double min, double max, ValueChanged<double> onChanged) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: WaqtType.sans(15, weight: 600, color: c.ink)),
              ),
              Text(value.round().toString(), style: WaqtType.sans(14, color: c.muted)),
            ],
          ),
          Slider.adaptive(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            activeColor: c.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(l.quranReadingSettings, style: WaqtType.serif(24, weight: 500, color: c.ink)),
          ),
          // Live preview of the current Arabic size / script.
          WaqtCard(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Text(
              basmala,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: WaqtType.quran(prefs.arabicSize, family: quranFamily(prefs), height: 1.9, color: c.ink),
            ),
          ),
          const SizedBox(height: 12),
          WaqtCard(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                slider(
                  l.quranArabicSize,
                  prefs.arabicSize,
                  ReaderPrefs.minArabic,
                  ReaderPrefs.maxArabic,
                  (v) => _set((r) => r.copyWith(arabicSize: v)),
                ),
                slider(
                  l.quranTextSize,
                  prefs.textSize,
                  ReaderPrefs.minText,
                  ReaderPrefs.maxText,
                  (v) => _set((r) => r.copyWith(textSize: v)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.quranArabicFont, style: WaqtType.sans(15, weight: 600, color: c.ink)),
                      const SizedBox(height: 8),
                      Segmented<String>(
                        value: prefs.quranFont,
                        options: [('amiri', l.quranFontUthmani), ('scheherazade', l.quranFontNaskh)],
                        onChanged: (v) => _set((r) => r.copyWith(quranFont: v)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WaqtGroup(
            children: [
              WaqtRow(
                title: l.quranTranslation,
                value: '${translation.label} · ${translation.author}',
                onTap: () async {
                  final picked = await showChoiceSheet<String>(
                    context,
                    title: l.quranTranslation,
                    selected: translation.id,
                    options: [for (final t in QuranTranslations.all) (t.id, t.label, t.author)],
                  );
                  if (picked != null) _set((r) => r.copyWith(translation: () => picked));
                },
              ),
              ToggleRow(
                title: l.quranShowTranslation,
                value: prefs.showTranslation,
                onChanged: (v) => _set((r) => r.copyWith(showTranslation: v)),
              ),
              ToggleRow(
                title: l.quranShowTranslit,
                value: prefs.showTranslit,
                onChanged: (v) => _set((r) => r.copyWith(showTranslit: v)),
              ),
              if (_memorize != null)
                ToggleRow(
                  title: l.quranMemorize,
                  subtitle: l.quranMemorizeHint,
                  value: _memorize!,
                  onChanged: (v) {
                    setState(() => _memorize = v);
                    widget.onMemorize?.call(v);
                  },
                ),
              ToggleRow(
                title: l.quranSepia,
                value: prefs.sepia,
                onChanged: (v) => _set((r) => r.copyWith(sepia: v)),
              ),
              ToggleRow(
                title: l.quranKeepAwake,
                value: prefs.keepAwake,
                onChanged: (v) => _set((r) => r.copyWith(keepAwake: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
