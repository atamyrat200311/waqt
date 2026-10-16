import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/ornaments.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/library_providers.dart';
import '../domain/library_content.dart';

class NamesScreen extends ConsumerWidget {
  const NamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final names = ref.watch(allahNamesProvider).value ?? const <AllahName>[];
    final saved = ref.watch(nameBookmarksProvider).value ?? const <String>{};

    return SubScreen(
      title: l.libraryNames,
      backLabel: l.tabLibrary,
      trailing: PillButton(
        label: l.namesQuiz,
        icon: WaqtIcons.sparkles,
        style: PillStyle.mint,
        height: 36,
        fontSize: 13.5,
        onPressed: names.length < 4 ? null : () => showNamesQuiz(context, names),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 12),
          sliver: SliverToBoxAdapter(
            child: WaqtCard(
              color: c.brassSoft,
              border: false,
              child: Text(l.namesHadith, style: WaqtType.serif(15, height: 1.5, color: c.brassText)),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: names.length,
            itemBuilder: (context, i) {
              final n = names[i];
              final isSaved = saved.contains('${n.number}');
              return WaqtCard(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                onTap: () => _showName(context, ref, n),
                semanticLabel: '${n.number}. ${n.translit}: ${n.meaning.of(lang)}',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('${n.number}', style: WaqtType.sans(12, weight: 700, color: c.muted)),
                        const Spacer(),
                        if (isSaved) WaqtIcon(WaqtIcons.bookmarkFilled, size: 14, color: c.brass),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(n.arabic, textDirection: TextDirection.rtl, style: WaqtType.arabic(32, height: 1.4, color: c.accent)),
                        ),
                      ),
                    ),
                    Text(n.translit, maxLines: 1, overflow: TextOverflow.ellipsis, style: WaqtType.sans(14, weight: 600, color: c.ink)),
                    const SizedBox(height: 2),
                    Text(
                      n.meaning.of(lang),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtType.sans(12.5, color: c.muted, height: 1.3),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showName(BuildContext context, WidgetRef ref, AllahName n) {
    Adaptive.showSheet<void>(
      context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final c = ctx.colors;
          final l = ctx.l10n;
          final lang = l.localeName;
          final saved = (ref.watch(nameBookmarksProvider).value ?? const <String>{}).contains('${n.number}');
          final share = ShareCardData(
            kicker: l.libraryNames,
            arabic: n.arabic,
            text: '${n.translit} — ${n.meaning.of(lang)}\n\n${n.note.of(lang)}',
            reference: '${l.libraryNamesSub} · ${n.number}',
          );
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + MediaQuery.paddingOf(ctx).bottom),
            child: Column(
              children: [
                StarBadge(label: '${n.number}', color: c.brass, textColor: c.brassText, size: 44),
                const SizedBox(height: 8),
                Text(n.arabic, textDirection: TextDirection.rtl, style: WaqtType.arabic(54, height: 1.4, color: c.accent)),
                Text(n.translit, style: WaqtType.serif(26, weight: 500, color: c.ink)),
                const SizedBox(height: 4),
                Text(n.meaning.of(lang), textAlign: TextAlign.center, style: WaqtType.sans(17, weight: 600, color: c.muted)),
                if (!n.note.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text(n.note.of(lang), textAlign: TextAlign.center, style: WaqtType.serif(16, height: 1.55, color: c.ink)),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: saved ? l.quranRemoveBookmark : l.quranBookmark,
                        icon: saved ? WaqtIcons.bookmarkFilled : WaqtIcons.bookmark,
                        style: PillStyle.fill,
                        expand: true,
                        onPressed: () {
                          Haptics.light();
                          ref.read(bookmarkRepositoryProvider).toggle(BookmarkKind.name, '${n.number}');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PillButton(
                        label: l.share,
                        icon: WaqtIcons.share,
                        expand: true,
                        onPressed: () => showShareCardSheet(ctx, share),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Ten-question multiple-choice practice of the Names' meanings.
Future<void> showNamesQuiz(BuildContext context, List<AllahName> names) =>
    Adaptive.showSheet<void>(context, expand: true, builder: (ctx) => _Quiz(names: names));

class _Quiz extends StatefulWidget {
  const _Quiz({required this.names});
  final List<AllahName> names;

  @override
  State<_Quiz> createState() => _QuizState();
}

class _QuizState extends State<_Quiz> {
  late List<NameQuestion> _questions = buildNameQuiz(widget.names);
  int _i = 0;
  int _right = 0;
  int? _picked;

  void _pick(int option) {
    if (_picked != null) return;
    final correct = option == _questions[_i].answer;
    correct ? Haptics.success() : Haptics.light();
    setState(() {
      _picked = option;
      if (correct) _right++;
    });
  }

  void _next() => setState(() {
        _i++;
        _picked = null;
      });

  void _restart() => setState(() {
        _questions = buildNameQuiz(widget.names);
        _i = 0;
        _right = 0;
        _picked = null;
      });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final bottom = MediaQuery.paddingOf(context).bottom;

    if (_i >= _questions.length) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_right / ${_questions.length}', style: WaqtType.serif(72, weight: 400, color: c.ink)),
            const SizedBox(height: 8),
            Text(l.namesQuizScore('$_right', '${_questions.length}'), style: WaqtType.sans(17, color: c.muted)),
            const SizedBox(height: 28),
            BigButton(label: l.namesQuizAgain, onPressed: _restart),
            const SizedBox(height: 8),
            PillButton(label: l.close, style: PillStyle.ghost, onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    }

    final q = _questions[_i];
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (_i + (_picked == null ? 0 : 1)) / _questions.length,
              minHeight: 6,
              backgroundColor: c.fill,
              valueColor: AlwaysStoppedAnimation(c.brass),
            ),
          ),
          const SizedBox(height: 18),
          Text(l.namesQuizQuestion, textAlign: TextAlign.center, style: WaqtType.sans(15, color: c.muted)),
          const SizedBox(height: 8),
          Text(q.name.arabic, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: WaqtType.arabic(52, height: 1.4, color: c.accent)),
          Text(q.name.translit, textAlign: TextAlign.center, style: WaqtType.serif(24, weight: 500, color: c.ink)),
          const SizedBox(height: 20),
          for (var o = 0; o < q.options.length; o++) ...[
            _Option(
              text: q.options[o].meaning.of(lang),
              state: _picked == null
                  ? _OptionState.idle
                  : o == q.answer
                      ? _OptionState.right
                      : o == _picked
                          ? _OptionState.wrong
                          : _OptionState.dim,
              onTap: () => _pick(o),
            ),
            const SizedBox(height: 8),
          ],
          const Spacer(),
          if (_picked != null) BigButton(label: l.namesQuizNext, onPressed: _next),
        ],
      ),
    );
  }
}

enum _OptionState { idle, right, wrong, dim }

class _Option extends StatelessWidget {
  const _Option({required this.text, required this.state, required this.onTap});
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, border) = switch (state) {
      _OptionState.idle => (c.card, c.ink, c.hairline),
      _OptionState.right => (c.mint, c.onMint, c.primary),
      _OptionState.wrong => (c.brassSoft, c.brassText, c.brass),
      _OptionState.dim => (c.card, c.muted, c.hairline),
    };
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border, width: state == _OptionState.idle ? 1 : 1.5)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text(text, style: WaqtType.sans(15.5, weight: 600, color: fg))),
                if (state == _OptionState.right) WaqtIcon(WaqtIcons.check, size: 20, color: c.onMint),
                if (state == _OptionState.wrong) WaqtIcon(WaqtIcons.close, size: 18, color: c.brassText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
