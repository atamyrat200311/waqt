import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/enums.dart';
import '../../data/settings/settings_controller.dart';
import '../../features/adhkar/presentation/adhkar_reader.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/hadith/domain/hadith.dart';
import '../../features/hadith/presentation/hadith_book_screen.dart';
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

/// Known hadith book id from the path (falls back to the 40 Nawawi).
String _book(GoRouterState state) {
  final id = state.pathParameters['book'] ?? '';
  return HadithBooks.byId(id)?.id ?? HadithBooks.nawawi.id;
}

/// Last path segment of a full route ('/today/qada' → 'qada').
String _child(String full) => full.substring(full.lastIndexOf('/') + 1);

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
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!done && !atOnboarding) return Routes.onboarding;
      if (done && atOnboarding) return Routes.today;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.today,
              builder: (context, state) => TodayScreen(
                markPrayer: state.uri.queryParameters['mark'],
                markDay: state.uri.queryParameters['day'],
              ),
              routes: [
                GoRoute(path: _child(Routes.qada), builder: (context, state) => const QadaScreen()),
                GoRoute(path: _child(Routes.tasks), builder: (context, state) => const TasksScreen()),
                GoRoute(path: _child(Routes.habits), builder: (context, state) => const HabitsScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.quran,
              builder: (context, state) => const QuranHomeScreen(),
              routes: [
                GoRoute(path: _child(Routes.quranSearch), builder: (context, state) => const QuranSearchScreen()),
                GoRoute(path: _child(Routes.quranBookmarks), builder: (context, state) => const QuranBookmarksScreen()),
                GoRoute(path: _child(Routes.khatm), builder: (context, state) => const KhatmScreen()),
                GoRoute(path: _child(Routes.hifz), builder: (context, state) => const HifzScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.library,
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'hadith/:book',
                  builder: (context, state) => HadithBookScreen(bookId: _book(state)),
                  routes: [
                    GoRoute(
                      path: ':section',
                      builder: (context, state) => HadithSectionScreen(
                        bookId: _book(state),
                        sectionId: int.tryParse(state.pathParameters['section'] ?? '') ?? 1,
                      ),
                    ),
                  ],
                ),
                GoRoute(path: _child(Routes.duas), builder: (context, state) => const DuasScreen()),
                GoRoute(path: _child(Routes.names), builder: (context, state) => const NamesScreen()),
                GoRoute(
                  path: _child(Routes.learn),
                  builder: (context, state) => const LearnScreen(),
                  routes: [
                    GoRoute(path: ':id', builder: (context, state) => GuideScreen(id: state.pathParameters['id'] ?? '')),
                  ],
                ),
                GoRoute(path: _child(Routes.libraryBookmarks), builder: (context, state) => const SavedScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.tools,
              builder: (context, state) => const ToolsScreen(),
              routes: [
                GoRoute(path: _child(Routes.calendar), builder: (context, state) => const CalendarScreen()),
                GoRoute(path: _child(Routes.qiblaFull), builder: (context, state) => const QiblaScreen()),
                GoRoute(path: _child(Routes.ramadan), builder: (context, state) => const RamadanScreen()),
                GoRoute(path: _child(Routes.zakat), builder: (context, state) => const ZakatScreen()),
                GoRoute(path: _child(Routes.timetable), builder: (context, state) => const TimetableScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.me,
              builder: (context, state) => const MeScreen(),
              routes: [
                GoRoute(
                  path: _child(Routes.settings),
                  builder: (context, state) => const SettingsScreen(),
                  routes: [
                    GoRoute(path: _child(Routes.widgetsHelp), builder: (context, state) => const WidgetsHelpScreen()),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(
        path: Routes.adhkarPattern,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => AdhkarReader(
          set: state.pathParameters['set'] == 'evening' ? AdhkarSet.evening : AdhkarSet.morning,
        ),
      ),
      GoRoute(
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
      GoRoute(
        path: Routes.location,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
});
