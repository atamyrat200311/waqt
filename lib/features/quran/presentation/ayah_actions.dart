import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/quran_providers.dart';
import '../domain/quran.dart';

/// "Al-Baqarah · 2:255".
String ayahReference(int index) {
  final r = AyahRef.fromIndex(index);
  return '${SurahInfo(r.surah).translit} · ${r.surah}:${r.ayah}';
}

/// Share card for an ayah.
ShareCardData ayahShareData(BuildContext context, int index, QuranTexts texts, {String? kicker}) {
  return ShareCardData(
    kicker: kicker ?? context.l10n.quranTitle,
    arabic: texts.arabic[index],
    text: texts.translation[index],
    reference: ayahReference(index),
    credit: texts.translationCredit,
    arabicQuran: true,
  );
}

/// Bottom sheet with everything you can do with one ayah.
Future<void> showAyahActions(BuildContext context, int index) =>
    Adaptive.showSheet<void>(context, builder: (ctx) => _AyahActions(index: index));

class _AyahActions extends ConsumerWidget {
  const _AyahActions({required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final texts = ref.watch(quranTextsProvider).value;
    final key = AyahRef.fromIndex(index).toString();
    final bookmarks = ref.watch(ayahBookmarksProvider).value ?? const [];
    final mark = bookmarks.where((b) => b.ref == key).firstOrNull;
    final repo = ref.read(bookmarkRepositoryProvider);

    Widget action(WaqtIconData icon, String label, VoidCallback onTap, {Color? color}) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              WaqtIcon(icon, size: 21, color: color ?? c.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: WaqtType.sans(16, weight: 500, color: c.ink)),
              ),
            ],
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(ayahReference(index), style: WaqtType.serif(22, weight: 500, color: c.ink)),
          ),
          if (texts != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                texts.arabic[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: WaqtType.quran(22, height: 1.8, color: c.muted),
              ),
            ),
          if (mark?.note != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(14)),
              child: Text(mark!.note!, style: WaqtType.sans(14, color: c.brassText, height: 1.4)),
            ),
          action(
            mark != null ? WaqtIcons.bookmarkFilled : WaqtIcons.bookmark,
            mark != null ? l.quranRemoveBookmark : l.quranBookmark,
            () async {
              Haptics.light();
              // Removing a bookmark also drops its note: confirm first.
              if (mark?.note != null) {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog.adaptive(
                    content: Text(l.quranRemoveNoteConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.quranRemoveBookmark)),
                    ],
                  ),
                );
                if (ok != true) return;
              }
              await repo.toggle(BookmarkKind.ayah, key);
              if (context.mounted) Navigator.pop(context);
            },
            color: c.brass,
          ),
          action(WaqtIcons.pen, l.quranAddNote, () async {
            final note = await _editNote(context, mark?.note);
            if (note == null) return;
            await repo.add(BookmarkKind.ayah, key);
            await repo.setNote(BookmarkKind.ayah, key, note);
          }),
          if (texts != null) ...[
            action(WaqtIcons.share, l.shareImage, () {
              Navigator.pop(context);
              showShareCardSheet(context, ayahShareData(context, index, texts));
            }),
            action(WaqtIcons.copy, l.copy, () {
              copyText(context, ayahShareData(context, index, texts).plain());
              Navigator.pop(context);
            }),
          ],
          action(WaqtIcons.check, l.quranSetLastRead, () {
            ref.read(settingsProvider.notifier).setQuranLastRead(index);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }
}

Future<String?> _editNote(BuildContext context, String? initial) =>
    Adaptive.showSheet<String>(context, builder: (ctx) => _NoteSheet(initial: initial));

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({this.initial});
  final String? initial;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.quranAddNote, style: WaqtType.serif(24, weight: 500, color: c.ink)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: l.quranNoteHint,
              filled: true,
              fillColor: c.fill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8),
          BigButton(label: l.save, onPressed: () => Navigator.pop(context, _controller.text)),
        ],
      ),
    );
  }
}
