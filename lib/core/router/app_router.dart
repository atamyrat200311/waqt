import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/enums.dart';
import '../../data/settings/settings_controller.dart';
import '../../features/adhkar/presentation/adhkar_reader.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/expenses/presentation/expense_history_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/hadith/domain/hadith.dart';
import '../../features/hadith/presentation/hadith_book_screen.dart';
import '../../features/hadith/presentation/hadith_search_screen.dart';
import '../../features/library/presentation/duas_screen.dart';
import '../../features/library/presentation/learn_screens.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/library/presentation/names_screen.dart';
import '../../features/library/presentation/saved_screen.dart';
import '../../features/me/presentation/me_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/qada/presentation/qada_screen.dart';
import '../../features/quran/domain/quran.dart' show totalAyahs;
import '../../features/quran/presentation/hifz_screen.dart';
import '../../features/quran/presentation/khatm_screen.dart';
import '../../features/quran/presentation/quran_bookmarks_screen.dart';
import '../../features/quran/presentation/quran_home_screen.dart';
import '../../features/quran/presentation/quran_reader.dart';
import '../../features/quran/presentation/quran_search_screen.dart';
import '../../features/ramadan/presentation/ramadan_screen.dart';
import '../../features/settings/presentation/backup_screen.dart';
import '../../features/settings/presentation/location_picker.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/widgets_help_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/tools/presentation/qibla_screen.dart';
import '../../features/tools/presentation/timetable_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/zakat/presentation/zakat_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// One navigator per tab (same order as [shellTabs]); the shell uses them to
/// tell whether a re-tapped tab is already at its root.
final branchNavigatorKeys = [
  for (final name in ['today', 'quran', 'library', 'tools', 'me'])
    GlobalKey<NavigatorState>(debugLabel: name),
];

/// Known hadith book id from the path (falls back to the 40 Nawawi).
String _book(GoRouterState state) {
  final id = state.pathParameters['book'] ?? '';
  return HadithBooks.byId(id)?.id ?? HadithBooks.nawawi.id;
}

/// Last path segment of a full route ('/today/qada' → 'qada').
String _child(String full) => full.substring(full.lastIndexOf('/') + 1);

/// A route whose page is always a Flutter [MaterialPage]. go_router decides
/// the page type by looking for a `MaterialApp` from its own `material_ui`
/// dependency, which never matches ours, so without this every page would be
/// a `NoTransitionPage`: no slide animation and no iOS edge-swipe back.
GoRoute _route({
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
  List<RouteBase> routes = const [],
  GlobalKey<NavigatorState>? parentNavigatorKey,
}) =>
    GoRoute(
      path: path,
      parentNavigatorKey: parentNavigatorKey,
      routes: routes,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        name: state.name ?? state.path,
        arguments: <String, String>{...state.pathParameters, ...state.uri.queryParameters},
        restorationId: state.pageKey.value,
        child: builder(context, state),
      ),
    );

final appRouterProvider = Provider<GoRouter>((ref) {
  // Rebuild redirects only when onboarding completes, not on every setting.
  final onboarding = ValueNotifier<bool>(ref.read(settingsProvider).onboardingDone);
  ref.listen(settingsProvider.select((s) => s.onboardingDone), (_, v) => onboarding.value = v);
  ref.onDispose(onboarding.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.today,
    refreshListenable: onboarding,
    redirect: (context, state) {
      final done = onboarding.value;
      // ActivityKit may deliver a custom-scheme tap as `/` on some iOS
      // versions. Never expose GoRouter's error page for that valid app-open.
      if (state.uri.path == '/') {
        return done ? Routes.today : Routes.onboarding;
      }
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!done && !atOnboarding) return Routes.onboarding;
      if (done && atOnboarding) return Routes.today;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(navigatorKey: branchNavigatorKeys[0], routes: [
            _route(
              path: Routes.today,
              builder: (context, state) => TodayScreen(
                markPrayer: state.uri.queryParameters['mark'],
                markDay: state.uri.queryParameters['day'],
              ),
              routes: [
                _route(
                  path: _child(Routes.qada),
                  builder: (context, state) {
                    final tab = state.uri.queryParameters['tab'] == 'fasts'
                        ? QadaTab.fasts
                        : QadaTab.prayers;
                    return QadaScreen(initialTab: tab);
                  },
                ),
                _route(path: _child(Routes.tasks), builder: (context, state) => const TasksScreen()),
                _route(path: _child(Routes.habits), builder: (context, state) => const HabitsScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(navigatorKey: branchNavigatorKeys[1], routes: [
            _route(
              path: Routes.quran,
              builder: (context, state) => const QuranHomeScreen(),
              routes: [
                _route(path: _child(Routes.quranSearch), builder: (context, state) => const QuranSearchScreen()),
                _route(path: _child(Routes.quranBookmarks), builder: (context, state) => const QuranBookmarksScreen()),
                _route(path: _child(Routes.khatm), builder: (context, state) => const KhatmScreen()),
                _route(path: _child(Routes.hifz), builder: (context, state) => const HifzScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(navigatorKey: branchNavigatorKeys[2], routes: [
            _route(
              path: Routes.library,
              builder: (context, state) => const LibraryScreen(),
              routes: [
                _route(
                  path: 'hadith/:book',
                  builder: (context, state) => HadithBookScreen(bookId: _book(state)),
                  routes: [
                    _route(
                      path: ':section',
                      builder: (context, state) => HadithSectionScreen(
                        bookId: _book(state),
                        sectionId: int.tryParse(state.pathParameters['section'] ?? '') ?? 1,
                      ),
                    ),
                  ],
                ),
                _route(path: _child(Routes.duas), builder: (context, state) => const DuasScreen()),
                _route(path: _child(Routes.hadithSearch), builder: (context, state) => const HadithSearchScreen()),
                _route(path: _child(Routes.names), builder: (context, state) => const NamesScreen()),
                _route(
                  path: _child(Routes.learn),
                  builder: (context, state) => const LearnScreen(),
                  routes: [
                    _route(path: ':id', builder: (context, state) => GuideScreen(id: state.pathParameters['id'] ?? '')),
                  ],
                ),
                _route(path: _child(Routes.libraryBookmarks), builder: (context, state) => const SavedScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(navigatorKey: branchNavigatorKeys[3], routes: [
            _route(
              path: Routes.tools,
              builder: (context, state) => const ToolsScreen(),
              routes: [
                _route(path: _child(Routes.calendar), builder: (context, state) => const CalendarScreen()),
                _route(path: _child(Routes.qiblaFull), builder: (context, state) => const QiblaScreen()),
                _route(path: _child(Routes.ramadan), builder: (context, state) => const RamadanScreen()),
                _route(path: _child(Routes.zakat), builder: (context, state) => const ZakatScreen()),
                _route(path: _child(Routes.timetable), builder: (context, state) => const TimetableScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(navigatorKey: branchNavigatorKeys[4], routes: [
            _route(
              path: Routes.me,
              builder: (context, state) => const MeScreen(),
              routes: [
                _route(path: _child(Routes.expenses), builder: (context, state) => const ExpenseHistoryScreen()),
                _route(
                  path: _child(Routes.settings),
                  builder: (context, state) => const SettingsScreen(),
                  routes: [
                    _route(path: _child(Routes.widgetsHelp), builder: (context, state) => const WidgetsHelpScreen()),
                    _route(path: _child(Routes.backup), builder: (context, state) => const BackupScreen()),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
      _route(
        path: Routes.adhkarPattern,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => AdhkarReader(
          set: state.pathParameters['set'] == 'evening' ? AdhkarSet.evening : AdhkarSet.morning,
        ),
      ),
      _route(
        path: Routes.readPattern,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return QuranReaderScreen(
            start: (int.tryParse(q['i'] ?? '') ?? 0).clamp(0, totalAyahs - 1),
            pageMode: q['mode'] == 'page',
            hifzSurah: int.tryParse(q['hifz'] ?? ''),
          );
        },
      ),
      _route(
        path: Routes.location,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LocationScreen(),
      ),
      _route(
        path: Routes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
});
