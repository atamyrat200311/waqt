import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/glass.dart';
import '../../shared/widgets/waqt_icon.dart';
import '../l10n/l10n_ext.dart';
import '../platform/adaptive.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// One entry per bottom tab (order = StatefulShellBranch order).
class ShellTab {
  const ShellTab(this.icon, this.label);
  final WaqtIconData icon;
  final String Function(AppLocalizations) label;
}

final shellTabs = <ShellTab>[
  ShellTab(WaqtIcons.today, (l) => l.tabToday),
  ShellTab(WaqtIcons.quran, (l) => l.tabQuran),
  ShellTab(WaqtIcons.library, (l) => l.tabLibrary),
  ShellTab(WaqtIcons.tools, (l) => l.tabTools),
  ShellTab(WaqtIcons.me, (l) => l.tabMe),
];

/// Adaptive tab scaffold: a floating "liquid glass" tab bar on iOS (content
/// scrolls underneath it), Material 3 NavigationBar with pill indicator on
/// Android.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) {
    // Re-tapping the active tab pops to its root, like native tab bars.
    if (index != shell.currentIndex) Haptics.tap();
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final cupertino = Adaptive.isCupertino(context);
    return Scaffold(
      body: shell,
      extendBody: cupertino,
      bottomNavigationBar: cupertino
          ? GlassTabBar(index: shell.currentIndex, onTap: _go)
          : _MaterialNavBar(index: shell.currentIndex, onTap: _go),
    );
  }
}

/// Floating capsule tab bar with a sliding glass "lens" behind the active tab.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const barHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final duration = Adaptive.motion(context, 320);
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 6, 14, bottom > 0 ? bottom - 6 : 12),
      child: SizedBox(
        height: barHeight,
        child: Glass(
          radius: barHeight / 2,
          child: LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 8) / shellTabs.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: duration,
                    curve: const Cubic(.3, 1.25, .5, 1),
                    left: 4 + w * index,
                    top: 4,
                    bottom: 4,
                    width: w,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.mint.withValues(alpha: c.isDark ? 0.85 : 0.9),
                        borderRadius: BorderRadius.circular(barHeight / 2),
                        border: Border.all(color: Colors.white.withValues(alpha: c.isDark ? 0.08 : 0.6)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        for (var i = 0; i < shellTabs.length; i++)
                          Expanded(
                            child: _GlassTabItem(
                              tab: shellTabs[i],
                              label: shellTabs[i].label(l),
                              active: i == index,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlassTabItem extends StatelessWidget {
  const _GlassTabItem({
    required this.tab,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final ShellTab tab;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? c.onMint : c.muted;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WaqtIcon(tab.icon, size: 23, color: color, strokeWidth: active ? 2.2 : 1.9),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: WaqtType.sans(10.5, weight: active ? 700 : 500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialNavBar extends StatelessWidget {
  const _MaterialNavBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onTap,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final t in shellTabs)
          NavigationDestination(
            icon: WaqtIcon(t.icon, size: 22, color: c.muted),
            selectedIcon: WaqtIcon(t.icon, size: 22, color: c.onMint),
            label: t.label(l),
          ),
      ],
    );
  }
}
