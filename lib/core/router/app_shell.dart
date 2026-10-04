import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/waqt_icon.dart';
import '../l10n/l10n_ext.dart';
import '../platform/adaptive.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// One entry per bottom tab. A future "Quran" tab is added here and as a new
/// [StatefulShellBranch] in `app_router.dart` (see TODO there).
class ShellTab {
  const ShellTab(this.icon, this.label);
  final WaqtIconData icon;
  final String Function(AppLocalizations) label;
}

final shellTabs = <ShellTab>[
  ShellTab(WaqtIcons.today, (l) => l.tabToday),
  ShellTab(WaqtIcons.tools, (l) => l.tabTools),
  ShellTab(WaqtIcons.me, (l) => l.tabMe),
];

/// Adaptive tab scaffold: Cupertino-style tab bar on iOS, Material 3
/// NavigationBar with pill indicator on Android.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) {
    // Re-tapping the active tab pops to its root, like native tab bars.
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final cupertino = Adaptive.isCupertino(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: cupertino
          ? _CupertinoTabBar(index: shell.currentIndex, onTap: _go)
          : _MaterialNavBar(index: shell.currentIndex, onTap: _go),
    );
  }
}

class _CupertinoTabBar extends StatelessWidget {
  const _CupertinoTabBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      padding: EdgeInsets.only(top: 8, bottom: bottom > 0 ? bottom : 8, left: 36, right: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < shellTabs.length; i++)
            _CupertinoTabItem(
              tab: shellTabs[i],
              label: shellTabs[i].label(l),
              active: i == index,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _CupertinoTabItem extends StatelessWidget {
  const _CupertinoTabItem({
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
    final color = active ? c.accent : c.muted;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: SizedBox(
          width: 80,
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WaqtIcon(tab.icon, size: 25, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: WaqtType.sans(11, weight: active ? 700 : 500, tracking: 0.01, color: color),
              ),
            ],
          ),
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
