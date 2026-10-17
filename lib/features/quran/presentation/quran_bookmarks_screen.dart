import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/quran_providers.dart';
import '../domain/quran.dart';
import 'quran_reader.dart';

class QuranBookmarksScreen extends ConsumerWidget {
  const QuranBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final marks = ref.watch(ayahBookmarksProvider).value ?? const <Bookmark>[];
    final texts = ref.watch(quranTextsProvider).value;

    return SubScreen(
      title: l.quranBookmarks,
      backLabel: l.quranTitle,
      slivers: [
        if (marks.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(icon: WaqtIcons.bookmark, text: l.quranNoBookmarks),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
            sliver: SliverList.separated(
              itemCount: marks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final b = marks[i];
                final r = AyahRef.tryParse(b.ref);
                if (r == null) return const SizedBox.shrink();
                return Dismissible(
                  key: ValueKey('bm-${b.ref}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: c.brassSoft,
                      borderRadius: BorderRadius.circular(Radii.card(context)),
                    ),
                    child: WaqtIcon(WaqtIcons.trash, color: c.danger),
                  ),
                  confirmDismiss: (_) async {
                    if (b.note == null) return true;
                    return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog.adaptive(
                            content: Text(l.quranRemoveNoteConfirm),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.quranRemoveBookmark)),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) => ref.read(bookmarkRepositoryProvider).remove(BookmarkKind.ayah, b.ref),
                  child: WaqtCard(
                    onTap: () => openReader(context, r.index),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            WaqtIcon(WaqtIcons.bookmarkFilled, size: 16, color: c.brass),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${SurahInfo(r.surah).translit} · ${r.surah}:${r.ayah}',
                                style: WaqtType.sans(14, weight: 700, color: c.accent),
                              ),
                            ),
                          ],
                        ),
                        if (texts != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            texts.arabic[r.index],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: WaqtType.quran(21, height: 1.8, color: c.ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            texts.translation[r.index],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtType.sans(14.5, color: c.muted, height: 1.45),
                          ),
                        ],
                        if (b.note != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: c.dangerSoft, borderRadius: BorderRadius.circular(12)),
                            child: Text(b.note!, style: WaqtType.sans(14, color: c.brassText, height: 1.4)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
