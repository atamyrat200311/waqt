import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/settings/settings_controller.dart';
import '../../features/me/presentation/me_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.tools, builder: (context, state) => const ToolsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.me, builder: (context, state) => const MeScreen()),
          ]),
          // TODO(quran): add a 4th StatefulShellBranch here and a ShellTab in
          // app_shell.dart (`shellTabs`) when the Quran reader is built.
        ],
      ),
      GoRoute(
        path: Routes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const _OnboardingPlaceholder(),
      ),
    ],
  );
});

class _OnboardingPlaceholder extends ConsumerWidget {
  const _OnboardingPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => ref.read(settingsProvider.notifier).setOnboardingDone(),
          child: const Text('Start'),
        ),
      ),
    );
  }
}
