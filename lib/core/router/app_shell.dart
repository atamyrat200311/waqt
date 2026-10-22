import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/glass.dart';
import '../../shared/widgets/waqt_icon.dart';
import '../l10n/l10n_ext.dart';
import '../platform/adaptive.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_router.dart' show branchNavigatorKeys;

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

/// Animates the first attached primary scroll controller below [root] (the
/// visible page of a tab navigator) back to offset 0.
void scrollPrimaryToTop(BuildContext root) {
  ScrollController? found;
  void visit(Element e) {
    if (found != null) return;
    final w = e.widget;
    final c = w is PrimaryScrollController ? w.controller : null;
    if (c != null && c.hasClients) {
      found = c;
      return;
    }
    e.visitChildElements(visit);
  }

  root.visitChildElements(visit);
  final controller = found;
  if (controller == null || controller.positions.every((p) => p.pixels <= 0)) return;
  Haptics.light();
  final reduce = MediaQuery.maybeDisableAnimationsOf(root) ?? false;
  for (final p in controller.positions) {
    if (reduce) {
      p.jumpTo(0);
    } else {
      p.animateTo(0, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    }
  }
}

/// Adaptive tab scaffold: a floating "liquid glass" tab bar on iOS (content
/// scrolls underneath it), Material 3 NavigationBar with pill indicator on
/// Android.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) {
    if (index != shell.currentIndex) {
      Haptics.tap();
      shell.goBranch(index);
      return;
    }
    // Re-tapping the active tab pops to its root, and at the root scrolls
    // back to the top, like UITabBarController.
    final navigator = branchNavigatorKeys[index].currentState;
    if (navigator != null && !navigator.canPop()) {
      scrollPrimaryToTop(navigator.context);
    } else {
      shell.goBranch(index, initialLocation: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertino = Adaptive.isCupertino(context);
    return Scaffold(
      body: shell,
      extendBody: cupertino,
      // Tab bars are fixed chrome: like native ones they grow only a little
      // with large text (content screens scale fully).
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.2,
        child: cupertino
            ? GlassTabBar(index: shell.currentIndex, onTap: _go)
            : _MaterialNavBar(index: shell.currentIndex, onTap: _go),
      ),
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
    final duration = Adaptive.motion(context, 280);
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
                    // The lens: a brighter pane of glass with its own rim.
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: c.isDark
                              ? [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0.07)]
                              : [Colors.white.withValues(alpha: 0.85), Colors.white.withValues(alpha: 0.5)],
                        ),
                        borderRadius: BorderRadius.circular(barHeight / 2),
                        border: Border.all(color: Colors.white.withValues(alpha: c.isDark ? 0.18 : 0.9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: c.isDark ? 0.25 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
  const _GlassTabItem({required this.tab, required this.label, required this.active, required this.onTap});

  final ShellTab tab;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? c.accent : c.ink.withValues(alpha: 0.72);
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
            WaqtIcon(tab.icon, size: 24, color: color, strokeWidth: active ? 2.2 : 1.9),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: WaqtType.sans(11, weight: active ? 700 : 600, color: color),
                ),
              ),
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
