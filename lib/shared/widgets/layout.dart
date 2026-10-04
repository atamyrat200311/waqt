import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/platform/adaptive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dimens.dart';
import 'waqt_icon.dart';

/// Uppercase kicker ("UP NEXT", "NEXT PRAYER").
class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color, this.size = 11, this.tracking = 0.08});
  final String text;
  final Color? color;
  final double size;
  final double tracking;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: WaqtType.kicker(color: color ?? context.colors.muted, size: size, tracking: tracking),
      );
}

/// 44×44 rounded icon square (40×40 r13 when [small]).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.background,
    this.color,
    this.small = false,
    this.iconSize,
  });

  final WaqtIconData icon;
  final Color? background;
  final Color? color;
  final bool small;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = small ? 40.0 : 44.0;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: background ?? c.fill,
        borderRadius: BorderRadius.circular(small ? Radii.smallTile : Radii.iconTile),
      ),
      alignment: Alignment.center,
      child: WaqtIcon(icon, size: iconSize ?? (small ? 19 : 22), color: color ?? c.accent),
    );
  }
}

/// Section title in Fraunces ("Your day", "Upcoming").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.size = 24, this.padding});
  final String text;
  final double size;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(22, 28, 22, 12),
        child: Semantics(
          header: true,
          child: Text(
            text,
            style: WaqtType.serif(size, tracking: -0.01, color: context.colors.ink),
          ),
        ),
      );
}

/// Scaffold for pushed sub-screens (Qada, Tasks, Calendar, Settings…).
///
/// iOS: "‹ Today" back link in accent + large Fraunces title in the scroll.
/// Android: top app bar with back arrow and the title in it.
class SubScreen extends StatelessWidget {
  const SubScreen({
    super.key,
    required this.title,
    required this.backLabel,
    required this.slivers,
    this.trailing,
    this.titleTrailing,
    this.bottom,
    this.floatingActionButton,
  });

  final String title;

  /// Label of the parent screen for the iOS back link ("Today", "Me").
  final String backLabel;
  final List<Widget> slivers;

  /// Action at the top right (both platforms).
  final Widget? trailing;

  /// Small text aligned with the large title (iOS) — e.g. "2 of 5 done".
  final Widget? titleTrailing;

  /// Docked widget above the bottom edge (task add field).
  final Widget? bottom;
  final Widget? floatingActionButton;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cupertino = Adaptive.isCupertino(context);
    final top = MediaQuery.paddingOf(context).top;

    final header = cupertino
        ? SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Semantics(
                          button: true,
                          label: backLabel,
                          excludeSemantics: true,
                          child: InkWell(
                            onTap: () => _back(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: SizedBox(
                                height: 44,
                                child: Row(
                                  children: [
                                    WaqtIcon(WaqtIcons.chevronLeft, size: 26, color: c.accent, strokeWidth: 2.4),
                                    Text(backLabel, style: WaqtType.sans(17, weight: 500, color: c.accent)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        ?trailing,
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Gap.title, 4, Gap.title, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(title, style: WaqtType.title(color: c.ink)),
                          ),
                        ),
                        ?titleTrailing,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : SliverAppBar(
            pinned: true,
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: WaqtIcon(WaqtIcons.arrowLeft, color: c.ink),
              onPressed: () => _back(context),
            ),
            title: Text(title),
            titleTextStyle: WaqtType.serif(24, tracking: -0.01, color: c.ink),
            actions: [
              if (titleTrailing != null) Center(child: titleTrailing),
              ?trailing,
              const SizedBox(width: 8),
            ],
          );

    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              header,
              ...slivers,
              SliverToBoxAdapter(child: SizedBox(height: bottom != null ? 120 : 32)),
            ],
          ),
          if (bottom != null) Positioned(left: 0, right: 0, bottom: 0, child: bottom!),
        ],
      ),
    );
  }
}
