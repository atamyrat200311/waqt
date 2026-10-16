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
import '../../../shared/widgets/segmented.dart';
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

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> with WidgetsBindingObserver {
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

  /// The user picked "mark as where I stopped": stop auto-saving.
  bool _pinned = false;

  /// Lookups (search, bookmarks, ayah of the day) don't move the bookmark
  /// unless the user actually reads a few ayahs there.
  late bool _resumed;

  /// Ayahs read in this khatm when the reader opened (snapshot, so the list
  /// doesn't rebuild on every save).
  late final Set<int> _readAtOpen;

  /// Bumped to rebuild the list/pager at [_current] after a jump.
  int _jump = 0;
  List<String> _arabic = const [];

  /// Fraction of the viewport hidden by the floating top bar.
  double _barFraction = 0.1;
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
    _resumed = _savedLastRead == null || widget.start == _savedLastRead;
    _readAtOpen = ref.read(khatmReadAyahsProvider).value ?? const <int>{};
    _tracker = ReadTracker(repository: _repo, today: () => _today, dwellFor: _dwellFor);
    _positions.itemPositions.addListener(_onPositions);
    WidgetsBinding.instance.addObserver(this);
    _startTicker();
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

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  /// Seconds an ayah must stay on screen to count as read: about 0.3 s per
  /// word, at least 2 s, at most 25 s.
  int _dwellFor(int ayah) {
    if (_arabic.isEmpty) return 2;
    final words = ' '.allMatches(_arabic[ayah]).length + 1;
    return (words * 0.3).ceil().clamp(2, 25);
  }

  /// Whether the session should move the "continue reading" position.
  bool get _shouldSaveLastRead => widget.hifzSurah == null && !_pinned && (_resumed || _tracker.recorded.length >= 3);

  void _saveLastRead({bool deferred = false}) {
    if (!_shouldSaveLastRead || _savedLastRead == _current) return;
    _savedLastRead = _current;
    final settings = _settings;
    final index = _current;
    // Providers can't change while the tree is unmounting; save right after.
    if (deferred) {
      Future.microtask(() => settings.setQuranLastRead(index));
    } else {
      unawaited(settings.setQuranLastRead(index));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTicker();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _ticker?.cancel();
      unawaited(_tracker.flush());
      _saveLastRead();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _unhighlight?.cancel();
    _positions.itemPositions.removeListener(_onPositions);
    unawaited(_tracker.flush());
    _saveLastRead(deferred: true);
    WakelockPlus.disable().catchError((Object _) {});
    super.dispose();
  }

  /// Ayahs meaningfully in the readable band (below the bar): fully visible
  /// or filling most of it. Hidden (memorize) ayahs never count.
  Iterable<int> _visibleAyahs() sync* {
    final top = _barFraction;
    for (final p in _positions.itemPositions.value) {
      final (_, ayah) = itemInfo(p.index);
      if (ayah == null) continue;
      if (_memorize && !_revealed.contains(ayah)) continue;
      final shown = (p.itemTrailingEdge.clamp(top, 1.0) - p.itemLeadingEdge.clamp(top, 1.0));
      final full = p.itemLeadingEdge >= top - 0.02 && p.itemTrailingEdge <= 1.02;
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
      final (a, b) = pageRange(_shownPage);
      if (_pageDwell == _pageDwellFor(a, b)) _tracker.markAll([for (var i = a; i <= b; i++) i]);
      _tracker.tick(const []);
    } else {
      _tracker.tick(_visibleAyahs());
    }
    if (++_tickCount % 10 == 0) _saveLastRead();
  }

  /// Seconds on a Mushaf page before it counts: ~0.25 s per word, 15–60 s.
  int _pageDwellFor(int a, int b) {
    if (_arabic.isEmpty) return 15;
    var words = 0;
    for (var i = a; i <= b; i++) {
      words += ' '.allMatches(_arabic[i]).length + 1;
    }
    return (words * 0.25).ceil().clamp(15, 60);
  }

  void _jumpTo(int index) {
    Haptics.tap();
    setState(() {
      _current = index;
      _shownPage = pageOfIndex(index);
      _pageDwell = 0;
      _highlight = index;
      _jump++;
      _resumed = true;
    });
    _unhighlight?.cancel();
    _unhighlight = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _highlight = null);
    });
  }

  void _toggleMode() {
    Haptics.tap();
    setState(() {
      _page = !_page;
      _shownPage = pageOfIndex(_current);
      _pageDwell = 0;
    });
  }

  /// A single tap only reveals hidden ayahs (memorize mode); actions live on
  /// long-press and the ••• button so resting a finger never opens a sheet.
  void _onAyahTap(int index) {
    if (_memorize && !_revealed.contains(index)) {
      Haptics.light();
      setState(() => _revealed.add(index));
    }
  }

  void _onAyahMore(int index) => showAyahActions(context, index);

  Future<void> _rateHifz(HifzGrade grade) async {
    final strong = grade == HifzGrade.good;
    final surah = widget.hifzSurah!;
    final rows = ref.read(hifzProvider).value ?? const <HifzRow>[];
    final row = rows.where((r) => r.surah == surah).firstOrNull;
    final (step, days) = hifzNext(row?.step ?? 0, grade: grade);
    await _repo.upsertHifz(surah, step >= 3 ? HifzStatus.memorized : HifzStatus.learning, step, _today.addDays(days));
    if (strong) Haptics.success();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    _today = ref.watch(todayKeyProvider);
    final prefs = ref.watch(settingsProvider.select((s) => s.reader));
    _arabic = ref.watch(quranArabicProvider).value ?? const [];
    // "Mark as where I stopped" from the actions sheet wins for this session.
    ref.listen(settingsProvider.select((s) => s.quranLastRead), (_, next) {
      if (next != null && next != _savedLastRead) {
        _savedLastRead = next;
        _pinned = true;
      }
    });
    ref.listen(settingsProvider.select((s) => s.reader.keepAwake), (_, on) {
      (on ? WakelockPlus.enable() : WakelockPlus.disable()).catchError((Object _) {});
    });
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
              key: ValueKey('page-$_jump'),
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
              onAyah: _onAyahMore,
            )
          : _buildList(t, prefs, palette, top + barHeight + 4, bottom),
    );

    final surah = SurahInfo(surahOfIndex(_current));
    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          // Soft fade so text scrolling under the floating bar stays calm.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: top + barHeight + 18,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [palette.bg, palette.bg.withValues(alpha: 0.85), palette.bg.withValues(alpha: 0)],
                    stops: const [0, 0.6, 1],
                  ),
                ),
              ),
            ),
          ),
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
              onTitle: () => showJumpSheet(context, current: _current, onPick: _jumpTo),
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
    final readSinceKhatm = _readAtOpen;
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
      builder: (context, box) {
        _barFraction = (topPad / box.maxHeight).clamp(0.0, 0.5);
        return ScrollablePositionedList.builder(
          key: ValueKey('list-$_jump'),
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
        );
      },
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
          onMore: () => _onAyahMore(index),
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
    required this.onTitle,
    required this.onToggleMode,
    required this.onSettings,
  });

  final String title;
  final String subtitle;
  final bool pageMode;
  final VoidCallback onBack;
  final VoidCallback onTitle;
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
              child: Semantics(
                button: true,
                label: '$title. ${l.quranJumpTo}',
                child: GestureDetector(
                  onTap: onTitle,
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
  final ValueChanged<HifzGrade> onRate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ink = Theme.of(context).colorScheme.onSurface;
    Widget b(String label, HifzGrade g, PillStyle style) => Expanded(
      child: PillButton(label: label, style: style, expand: true, fontSize: 14, onPressed: () => onRate(g)),
    );
    return Glass(
      radius: 26,
      solid: !Adaptive.isCupertino(context),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.hifzHowWent, style: WaqtType.sans(15, weight: 600, color: ink)),
          const SizedBox(height: 10),
          Row(
            children: [
              b(l.hifzAgain, HifzGrade.again, PillStyle.fill),
              const SizedBox(width: 8),
              b(l.hifzWeak, HifzGrade.hard, PillStyle.mint),
              const SizedBox(width: 8),
              b(l.hifzStrong, HifzGrade.good, PillStyle.primary),
            ],
          ),
        ],
      ),
    );
  }
}

/// Jump to a surah, juz, page or `2:255` from inside the reader.
Future<void> showJumpSheet(BuildContext context, {required int current, required ValueChanged<int> onPick}) =>
    Adaptive.showSheet<void>(
      context,
      expand: true,
      builder: (ctx) => _JumpSheet(current: current, onPick: onPick),
    );

class _JumpSheet extends StatefulWidget {
  const _JumpSheet({required this.current, required this.onPick});
  final int current;
  final ValueChanged<int> onPick;

  @override
  State<_JumpSheet> createState() => _JumpSheetState();
}

enum _JumpTab { surah, juz, page }

class _JumpSheetState extends State<_JumpSheet> {
  _JumpTab _tab = _JumpTab.surah;
  String _query = '';

  void _go(int index) {
    Navigator.pop(context);
    widget.onPick(index);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final l = context.l10n;
    final lang = l.localeName;
    final ref = AyahRef.tryParse(_query);
    final page = int.tryParse(_query.replaceFirst(RegExp(r'^[pPсС]\.?\s*'), ''));
    final surahs = searchSurahs(_query, lang);
    final currentSurah = surahOfIndex(widget.current);

    final List<Widget> rows;
    switch (_tab) {
      case _JumpTab.surah:
        rows = [
          for (final s in surahs)
            ListTile(
              selected: s.number == currentSurah,
              leading: Text('${s.number}', style: WaqtType.sans(14, weight: 700, color: c.onSurfaceVariant)),
              title: Text(s.translit, style: WaqtType.sans(16, weight: 600, color: c.onSurface)),
              subtitle: Text(s.meaning(lang), style: WaqtType.sans(13, color: c.onSurfaceVariant)),
              trailing: Text(
                s.arabic,
                textDirection: TextDirection.rtl,
                style: WaqtType.arabic(19, height: 1.3, color: c.tertiary),
              ),
              onTap: () => _go(s.startIndex),
            ),
        ];
      case _JumpTab.juz:
        rows = [
          for (var j = 1; j <= 30; j++)
            ListTile(
              selected: juzOfIndex(widget.current) == j,
              title: Text(l.quranJuzN('$j'), style: WaqtType.sans(16, weight: 600, color: c.onSurface)),
              subtitle: Text(ayahReference(juzRange(j).$1), style: WaqtType.sans(13, color: c.onSurfaceVariant)),
              onTap: () => _go(juzRange(j).$1),
            ),
        ];
      case _JumpTab.page:
        rows = [
          for (var p = 1; p <= totalPages; p++)
            if (page == null || '$p'.startsWith('$page'))
              ListTile(
                dense: true,
                selected: pageOfIndex(widget.current) == p,
                title: Text(l.quranPageN('$p'), style: WaqtType.sans(15, weight: 600, color: c.onSurface)),
                subtitle: Text(ayahReference(pageStarts[p - 1]), style: WaqtType.sans(12.5, color: c.onSurfaceVariant)),
                onTap: () => _go(pageStarts[p - 1]),
              ),
        ];
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: TextField(
            autofocus: false,
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: l.quranSearchHint,
              filled: true,
              fillColor: c.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        if (ref != null)
          ListTile(
            leading: Icon(Icons.arrow_forward, color: c.tertiary),
            title: Text(l.quranGoTo('${SurahInfo(ref.surah).translit} ${ref.surah}:${ref.ayah}')),
            onTap: () => _go(ref.index),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Segmented<_JumpTab>(
            value: _tab,
            options: [(_JumpTab.surah, l.quranSurahs), (_JumpTab.juz, l.quranJuzTab), (_JumpTab.page, l.quranPages)],
            onChanged: (t) => setState(() => _tab = t),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 12),
            children: rows,
          ),
        ),
      ],
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
