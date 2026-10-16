import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../application/quran_providers.dart';
import '../domain/quran.dart';
import 'quran_home_screen.dart';
import 'quran_reader.dart';

/// Short surahs most people memorize first.
const _suggested = [
  1,
  112,
  113,
  114,
  103,
  108,
  110,
  111,
  109,
  107,
  106,
  105,
  104,
  102,
  101,
  100,
  99,
  97,
  95,
  94,
  93,
  87,
  78,
  67,
  36,
  18,
];

class HifzScreen extends ConsumerWidget {
  const HifzScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final rows = ref.watch(hifzProvider).value ?? const <HifzRow>[];
    final today = ref.watch(todayKeyProvider);
    final due = rows.where((r) => !DayKey(r.nextReview).isAfter(today)).toList();
    final upcoming = rows.where((r) => DayKey(r.nextReview).isAfter(today)).toList();
    final repo = ref.read(quranRepositoryProvider);

    Widget row(HifzRow h, {required bool isDue}) {
      final s = SurahInfo(h.surah);
      return Dismissible(
        key: ValueKey('hifz-${h.surah}'),
        direction: DismissDirection.endToStart,
        background: Container(
          color: c.brassSoft,
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.only(right: 20),
          child: WaqtIcon(WaqtIcons.trash, color: c.brassText),
        ),
        onDismissed: (_) => repo.removeHifz(h.surah),
        child: SurahRow(
          surah: s,
          language: lang,
          done: h.status == HifzStatus.memorized,
          onTap: () => openReader(context, s.startIndex, hifzSurah: s.number),
          trailing: isDue
              ? PillButton(
                  label: l.hifzReview,
                  height: 36,
                  fontSize: 14,
                  onPressed: () => openReader(context, s.startIndex, hifzSurah: s.number),
                )
              : Text(l.hifzNext(l.dayMonth(DayKey(h.nextReview).date)), style: WaqtType.sans(12.5, color: c.muted)),
        ),
      );
    }

    return SubScreen(
      title: l.hifzTitle,
      backLabel: l.quranTitle,
      trailing: CircleIconButton(
        icon: WaqtIcons.plus,
        semanticLabel: l.hifzAdd,
        background: c.card,
        border: true,
        onPressed: () => _addSurah(context, ref, rows),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
          sliver: SliverList.list(
            children: [
              WaqtCard(
                color: c.mint,
                border: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WaqtIcon(WaqtIcons.repeat, color: c.onMint),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l.hifzIntro, style: WaqtType.sans(14.5, color: c.onMint, height: 1.45)),
                    ),
                  ],
                ),
              ),
              if (rows.isEmpty)
                EmptyState(
                  icon: WaqtIcons.repeat,
                  text: l.hifzEmpty,
                  action: PillButton(
                    label: l.hifzAdd,
                    icon: WaqtIcons.plus,
                    onPressed: () => _addSurah(context, ref, rows),
                  ),
                ),
              if (due.isNotEmpty) ...[
                SectionTitle(l.hifzDue, padding: const EdgeInsets.fromLTRB(6, 22, 6, 10)),
                WaqtGroup(children: [for (final h in due) row(h, isDue: true)]),
              ],
              if (upcoming.isNotEmpty) ...[
                SectionTitle(l.hifzUpcoming, padding: const EdgeInsets.fromLTRB(6, 22, 6, 10)),
                WaqtGroup(children: [for (final h in upcoming) row(h, isDue: false)]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addSurah(BuildContext context, WidgetRef ref, List<HifzRow> existing) async {
    final have = {for (final r in existing) r.surah};
    final picked = await Adaptive.showSheet<int>(
      context,
      expand: true,
      builder: (ctx) {
        final c = ctx.colors;
        final l = ctx.l10n;
        final lang = l.localeName;
        final suggested = [
          for (final n in _suggested)
            if (!have.contains(n)) n,
        ];
        final rest = [
          for (var n = 1; n <= totalSurahs; n++)
            if (!have.contains(n) && !_suggested.contains(n)) n,
        ];
        return ListView(
          padding: EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, 20 + MediaQuery.paddingOf(ctx).bottom),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(l.hifzAdd, style: WaqtType.serif(24, weight: 500, color: c.ink)),
            ),
            if (suggested.isNotEmpty) ...[
              Kicker(l.hifzSuggested),
              const SizedBox(height: 8),
              WaqtGroup(
                children: [
                  for (final n in suggested)
                    SurahRow(surah: SurahInfo(n), language: lang, onTap: () => Navigator.pop(ctx, n)),
                ],
              ),
              const SizedBox(height: 18),
            ],
            Kicker(l.hifzAllSurahs),
            const SizedBox(height: 8),
            WaqtGroup(
              children: [
                for (final n in rest) SurahRow(surah: SurahInfo(n), language: lang, onTap: () => Navigator.pop(ctx, n)),
              ],
            ),
          ],
        );
      },
    );
    if (picked == null) return;
    Haptics.light();
    await ref.read(quranRepositoryProvider).upsertHifz(picked, HifzStatus.learning, 0, ref.read(todayKeyProvider));
  }
}
