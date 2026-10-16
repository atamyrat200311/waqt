import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/assets.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../data/settings/app_settings.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../application/quran_providers.dart';
import '../application/read_tracker.dart';
import '../domain/quran.dart';
import '../domain/quran_index_data.dart';
import 'ayah_actions.dart';
import 'reader_settings_sheet.dart';
import 'reader_widgets.dart';

/// Opens the full-screen reader at a global ayah index.
void openReader(BuildContext context, int index, {bool page = false, int? hifzSurah}) {
  context.push(_route(index, page: page, hifzSurah: hifzSurah));
}

String _route(int index, {bool page = false, int? hifzSurah}) =>
    '/read?i=$index${page ? '&mode=page' : ''}${hifzSurah != null ? '&hifz=$hifzSurah' : ''}';

/// Item layout of the continuous list: each surah contributes a header item
/// followed by its ayahs, so ayah `i` of surah `s` sits at item `i + s`.
int itemOfAyah(int index) => index + surahOfIndex(index);
int headerItemOfSurah(int surah) => surahStarts[surah - 1] + surah - 1;

/// (surah, ayah index or null for the header) of a list item.
(int, int?) itemInfo(int item) {
  var lo = 1, hi = totalSurahs;
  while (lo < hi) {
    final mid = (lo + hi + 1) >> 1;
    if (headerItemOfSurah(mid) <= item) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  final header = headerItemOfSurah(lo);
  return item == header ? (lo, null) : (lo, item - lo);
}

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({super.key, required this.start, this.pageMode = false, this.hifzSurah});

  /// Global ayah index to open at.
  final int start;
  final bool pageMode;

  /// Reviewing this surah from the memorization ladder.
  final int? hifzSurah;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  late bool _page = widget.pageMode;
  late bool _memorize = widget.hifzSurah != null;
  final _revealed = <int>{};
  final _positions = ItemPositionsListener.create();
  final _items = ItemScrollController();
  late int _current = widget.start.clamp(0, totalAyahs - 1);
  late int _shownPage = pageOfIndex(_current);
  int? _highlight;
  int _pageDwell = 0;
  int _tickCount = 0;
  int? _savedLastRead;
  Timer? _ticker;
  Timer? _unhighlight;
  late DayKey _today;
  late final ReadTracker _tracker;
  late final SettingsController _settings;
  late final QuranRepository _repo;

  @override
  void initState() {
    super.initState();
    _today = ref.read(todayKeyProvider);
    _settings = ref.read(settingsProvider.notifier);
    _repo = ref.read(quranRepositoryProvider);
    _savedLastRead = ref.read(settingsProvider).quranLastRead;
    _tracker = ReadTracker(repository: _repo, today: () => _today);
    _positions.itemPositions.addListener(_onPositions);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    if (widget.start > 0 && widget.hifzSurah == null) {
      _highlight = widget.start;
      _unhighlight = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _highlight = null);
      });
    }
    if (ref.read(settingsProvider).reader.keepAwake) {
      WakelockPlus.enable().catchError((Object _) {});
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _unhighlight?.cancel();
    _positions.itemPositions.removeListener(_onPositions);
    unawaited(_tracker.flush());
    if (_savedLastRead != _current && widget.hifzSurah == null) unawaited(_settings.setQuranLastRead(_current));
    WakelockPlus.disable().catchError((Object _) {});
    super.dispose();
  }

  /// Ayahs that are meaningfully on screen (fully, or filling most of it).
  Iterable<int> _visibleAyahs() sync* {
    for (final p in _positions.itemPositions.value) {
      final (_, ayah) = itemInfo(p.index);
      if (ayah == null) continue;
      final shown = (p.itemTrailingEdge.clamp(0.0, 1.0) - p.itemLeadingEdge.clamp(0.0, 1.0));
      final full = p.itemLeadingEdge >= -0.02 && p.itemTrailingEdge <= 1.02;
      if (full || shown >= 0.5) yield ayah;
    }
  }

  void _onPositions() {
    final visible = _positions.itemPositions.value.where((p) => p.itemTrailingEdge > 0.12).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    if (visible.isEmpty) return;
    final (surah, ayah) = itemInfo(visible.first.index);
    final top = ayah ?? surahStarts[surah - 1];
    if (top != _current) setState(() => _current = top);
  }

  void _onTick() {
    if (!mounted) return;
    if (_page) {
      _pageDwell++;
      if (_pageDwell == 4) {
        final (a, b) = pageRange(_shownPage);
        _tracker.markAll([for (var i = a; i <= b; i++) i]);
      }
      _tracker.tick(const []);
    } else {
      _tracker.tick(_visibleAyahs());
    }
    if (++_tickCount % 10 == 0 && _savedLastRead != _current && widget.hifzSurah == null) {
      _savedLastRead = _current;
      unawaited(_settings.setQuranLastRead(_current));
    }
  }

  void _toggleMode() {
    Haptics.tap();
    setState(() {
      _page = !_page;
      _shownPage = pageOfIndex(_current);
      _pageDwell = 0;
    });
  }

  void _onAyahTap(int index) {
    if (_memorize && !_revealed.contains(index)) {
      Haptics.light();
      setState(() => _revealed.add(index));
      return;
    }
    showAyahActions(context, index);
  }

  Future<void> _rateHifz(bool strong) async {
    final surah = widget.hifzSurah!;
    final rows = ref.read(hifzProvider).value ?? const <HifzRow>[];
    final row = rows.where((r) => r.surah == surah).firstOrNull;
    final (step, days) = hifzNext(row?.step ?? 0, strong: strong);
    await _repo.upsertHifz(surah, step >= 3 ? HifzStatus.memorized : HifzStatus.learning, step, _today.addDays(days));
    if (strong) Haptics.success();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    _today = ref.watch(todayKeyProvider);
    final prefs = ref.watch(settingsProvider.select((s) => s.reader));
    final palette = ReaderPalette.of(context, sepia: prefs.sepia);
    final texts = ref.watch(quranTextsProvider);
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    const barHeight = 56.0;

    final body = texts.when(
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(palette.accent)),
            const SizedBox(height: 14),
            Text(l.quranLoading, style: WaqtType.sans(14, color: palette.muted)),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Text(l.errorGeneric, style: WaqtType.body(color: palette.muted)),
      ),
      data: (t) => _page
          ? _MushafPager(
              key: const ValueKey('page'),
              initialPage: _shownPage,
              texts: t,
              prefs: prefs,
              palette: palette,
              topPadding: top + barHeight + 12,
              bottomPadding: bottom + (widget.hifzSurah != null ? 120 : 24),
              onPage: (p) {
                setState(() {
                  _shownPage = p;
                  _pageDwell = 0;
                  _current = pageStarts[p - 1];
                });
              },
              onAyah: _onAyahTap,
            )
          : _buildList(t, prefs, palette, top + barHeight + 4, bottom),
    );

    final surah = SurahInfo(surahOfIndex(_current));
    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _ReaderBar(
              title: surah.translit,
              subtitle:
                  '${l.quranJuzN('${juzOfIndex(_current)}')} · ${l.quranPageN('${_page ? _shownPage : pageOfIndex(_current)}')}',
              pageMode: _page,
              onBack: () => context.canPop() ? context.pop() : context.go('/quran'),
              onToggleMode: _toggleMode,
              onSettings: () => showReaderSettings(
                context,
                memorize: _memorize,
                onMemorize: (v) => setState(() {
                  _memorize = v;
                  _revealed.clear();
                }),
              ),
            ),
          ),
          if (widget.hifzSurah != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: bottom + 12,
              child: _HifzPanel(onRate: _rateHifz),
            ),
        ],
      ),
    );
  }

  Widget _buildList(QuranTexts t, ReaderPrefs prefs, ReaderPalette palette, double topPad, double bottom) {
    final bookmarks = ref.watch(ayahBookmarkRefsProvider);
    final translation = ref.watch(activeTranslationProvider);
    final readSinceKhatm = ref.watch(khatmReadAyahsProvider).value ?? const <int>{};
    final startAtHeader = AyahRef.fromIndex(_current).ayah == 1;
    final initial = startAtHeader ? headerItemOfSurah(surahOfIndex(_current)) : itemOfAyah(_current);
    final count = widget.hifzSurah != null ? null : totalAyahs + totalSurahs;

    if (widget.hifzSurah != null) {
      // Review mode: just this surah.
      final s = SurahInfo(widget.hifzSurah!);
      return ListView.builder(
        padding: EdgeInsets.only(top: topPad, bottom: bottom + 140),
        itemCount: s.ayahCount + 1,
        itemBuilder: (context, i) => i == 0
            ? SurahHeader(surah: s, palette: palette, basmala: t.arabic.first, prefs: prefs)
            : _tile(s.startIndex + i - 1, t, prefs, palette, bookmarks, translation.rtl, readSinceKhatm),
      );
    }

    return LayoutBuilder(
      builder: (context, box) => ScrollablePositionedList.builder(
        key: const ValueKey('list'),
        itemCount: count!,
        initialScrollIndex: initial,
        // Land the first item just below the floating bar, not under it.
        initialAlignment: initial == 0 ? 0 : (topPad / box.maxHeight).clamp(0.0, 0.5),
        itemScrollController: _items,
        itemPositionsListener: _positions,
        padding: EdgeInsets.only(top: topPad, bottom: bottom + 40),
        itemBuilder: (context, item) {
          final (surah, ayah) = itemInfo(item);
          if (ayah == null) {
            return SurahHeader(surah: SurahInfo(surah), palette: palette, basmala: t.arabic.first, prefs: prefs);
          }
          return _tile(ayah, t, prefs, palette, bookmarks, translation.rtl, readSinceKhatm);
        },
      ),
    );
  }

  Widget _tile(
    int index,
    QuranTexts t,
    ReaderPrefs prefs,
    ReaderPalette palette,
    Set<String> bookmarks,
    bool rtl,
    Set<int> readSet,
  ) {
    final ref0 = AyahRef.fromIndex(index);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AyahTile(
          index: index,
          arabic: t.arabic[index],
          translit: prefs.showTranslit ? t.translit[index] : null,
          translation: prefs.showTranslation ? t.translation[index] : null,
          prefs: prefs,
          palette: palette,
          bookmarked: bookmarks.contains(ref0.toString()),
          hidden: _memorize && !_revealed.contains(index),
          highlighted: _highlight == index,
          read: readSet.contains(index) || _tracker.recorded.contains(index),
          translationRtl: rtl,
          onTap: () => _onAyahTap(index),
          onMore: () => showAyahActions(context, index),
        ),
        Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: palette.hairline),
      ],
    );
  }
}

// ---------------------------------------------------------------- top bar

class _ReaderBar extends StatelessWidget {
  const _ReaderBar({
    required this.title,
    required this.subtitle,
    required this.pageMode,
    required this.onBack,
    required this.onToggleMode,
    required this.onSettings,
  });

  final String title;
  final String subtitle;
  final bool pageMode;
  final VoidCallback onBack;
  final VoidCallback onToggleMode;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cupertino = Adaptive.isCupertino(context);
    final ink = Theme.of(context).colorScheme.onSurface;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final accent = Theme.of(context).colorScheme.tertiary;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
        child: Row(
          children: [
            GlassIconButton(
              semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack,
              child: WaqtIcon(cupertino ? WaqtIcons.chevronLeft : WaqtIcons.arrowLeft, color: ink, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: Glass(
                  radius: 22,
                  solid: !cupertino,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WaqtType.sans(14.5, weight: 700, color: ink),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WaqtType.sans(11.5, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              semanticLabel: pageMode ? l.quranModeList : l.quranModePage,
              onPressed: onToggleMode,
              child: WaqtIcon(pageMode ? WaqtIcons.list : WaqtIcons.book, color: accent, size: 21),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              semanticLabel: l.quranReadingSettings,
              onPressed: onSettings,
              child: Text('Aa', style: WaqtType.serif(18, weight: 600, color: accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HifzPanel extends StatelessWidget {
  const _HifzPanel({required this.onRate});
  final ValueChanged<bool> onRate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ink = Theme.of(context).colorScheme.onSurface;
    return Glass(
      radius: 26,
      solid: !Adaptive.isCupertino(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.hifzHowWent, style: WaqtType.sans(15, weight: 600, color: ink)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: l.hifzWeak,
                  style: PillStyle.brassSoft,
                  expand: true,
                  onPressed: () => onRate(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(label: l.hifzStrong, expand: true, onPressed: () => onRate(true)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- mushaf

/// Right-to-left pager over the 604 Madani pages.
class _MushafPager extends StatefulWidget {
  const _MushafPager({
    super.key,
    required this.initialPage,
    required this.texts,
    required this.prefs,
    required this.palette,
    required this.topPadding,
    required this.bottomPadding,
    required this.onPage,
    required this.onAyah,
  });

  final int initialPage;
  final QuranTexts texts;
  final ReaderPrefs prefs;
  final ReaderPalette palette;
  final double topPadding;
  final double bottomPadding;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onAyah;

  @override
  State<_MushafPager> createState() => _MushafPagerState();
}

class _MushafPagerState extends State<_MushafPager> {
  late final _controller = PageController(initialPage: widget.initialPage - 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
    controller: _controller,
    reverse: true,
    itemCount: totalPages,
    onPageChanged: (i) {
      Haptics.tap();
      widget.onPage(i + 1);
    },
    itemBuilder: (context, i) => _MushafPage(
      page: i + 1,
      texts: widget.texts,
      prefs: widget.prefs,
      palette: widget.palette,
      topPadding: widget.topPadding,
      bottomPadding: widget.bottomPadding,
      onAyah: widget.onAyah,
    ),
  );
}

class _MushafPage extends StatefulWidget {
  const _MushafPage({
    required this.page,
    required this.texts,
    required this.prefs,
    required this.palette,
    required this.topPadding,
    required this.bottomPadding,
    required this.onAyah,
  });

  final int page;
  final QuranTexts texts;
  final ReaderPrefs prefs;
  final ReaderPalette palette;
  final double topPadding;
  final double bottomPadding;
  final ValueChanged<int> onAyah;

  @override
  State<_MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<_MushafPage> {
  final _recognizers = <int, LongPressGestureRecognizer>{};

  LongPressGestureRecognizer _recognizer(int index) =>
      _recognizers.putIfAbsent(index, () => LongPressGestureRecognizer()..onLongPress = () => widget.onAyah(index));

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = widget.palette;
    final prefs = widget.prefs;
    final (start, end) = pageRange(widget.page);
    // Slightly smaller than the translation view so lines hold more words
    // and justification leaves smaller gaps.
    final style = WaqtType.quran(prefs.arabicSize * 0.88, family: quranFamily(prefs), height: 2.2, color: p.ink);
    final markStyle = style.copyWith(color: p.brass);

    final children = <Widget>[];
    var spans = <InlineSpan>[];
    void flush() {
      if (spans.isEmpty) return;
      children.add(
        Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: style,
        ),
      );
      spans = [];
    }

    for (var i = start; i <= end; i++) {
      final r = AyahRef.fromIndex(i);
      if (r.ayah == 1) {
        flush();
        children.add(
          SurahHeader(
            surah: SurahInfo(r.surah),
            palette: p,
            basmala: widget.texts.arabic.first,
            prefs: prefs,
            compact: true,
          ),
        );
      }
      spans
        ..add(TextSpan(text: widget.texts.arabic[i], recognizer: _recognizer(i)))
        ..add(TextSpan(text: ' ۝${arabicDigits(r.ayah)} ', style: markStyle));
    }
    flush();

    final first = AyahRef.fromIndex(start);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, widget.topPadding, 18, widget.bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(SurahInfo(first.surah).translit, style: WaqtType.sans(12, weight: 600, color: p.muted)),
              const Spacer(),
              Text(l.quranJuzN('${juzOfIndex(start)}'), style: WaqtType.sans(12, weight: 600, color: p.muted)),
            ],
          ),
          Divider(color: p.hairline, height: 18),
          ...children,
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: p.brass.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text('${widget.page}', style: WaqtType.sans(12.5, weight: 600, color: p.muted)),
            ),
          ),
        ],
      ),
    );
  }
}
