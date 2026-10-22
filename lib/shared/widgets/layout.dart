import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
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

/// Section title in Literata ("Your day", "Upcoming").
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
/// iOS: pinned navigation bar ("‹ Today" back link in accent) that turns
/// frosted once content scrolls under it, a large Literata title in the
/// scroll that hands over to a small centred title, as in UIKit.
/// Android: top app bar with back arrow and the title in it.
class SubScreen extends StatefulWidget {
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

  @override
  State<SubScreen> createState() => _SubScreenState();
}

class _SubScreenState extends State<SubScreen> {
  /// Scroll offset of the page, read by the iOS bar (no rebuild of slivers).
  final _offset = ValueNotifier<double>(0);

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) _offset.value = n.metrics.pixels;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cupertino = Adaptive.isCupertino(context);

    final List<Widget> header = cupertino
        ? [
            SliverPersistentHeader(
              pinned: true,
              delegate: _CupertinoBarDelegate(
                top: MediaQuery.paddingOf(context).top,
                // Large title height (4 pt gap + one Literata 34 line).
                titleExtent: 4 + MediaQuery.textScalerOf(context).scale(41),
                offset: _offset,
                title: widget.title,
                backLabel: widget.backLabel,
                onBack: () => _back(context),
                trailing: widget.trailing,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Gap.title, 4, Gap.title, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(widget.title, style: WaqtType.title(color: c.ink)),
                      ),
                    ),
                    ?widget.titleTrailing,
                  ],
                ),
              ),
            ),
          ]
        : [
            SliverAppBar(
              pinned: true,
              backgroundColor: c.bg,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: WaqtIcon(WaqtIcons.arrowLeft, color: c.ink),
                onPressed: () => _back(context),
              ),
              title: Text(widget.title),
              titleTextStyle: WaqtType.serif(24, tracking: -0.01, color: c.ink),
              actions: [
                if (widget.titleTrailing != null) Center(child: widget.titleTrailing),
                ?widget.trailing,
                const SizedBox(width: 8),
              ],
            ),
          ];

    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: widget.floatingActionButton,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                ...header,
                ...widget.slivers,
                SliverToBoxAdapter(child: BottomSpace(extra: widget.bottom != null ? 120 : 32)),
              ],
            ),
          ),
          if (widget.bottom != null) Positioned(left: 0, right: 0, bottom: 0, child: widget.bottom!),
        ],
      ),
    );
  }
}

/// The pinned iOS bar: transparent over the large title, frosted with a
/// hairline once content passes under it; the inline title fades in as the
/// large one scrolls away.
class _CupertinoBarDelegate extends SliverPersistentHeaderDelegate {
  _CupertinoBarDelegate({
    required this.top,
    required this.titleExtent,
    required this.offset,
    required this.title,
    required this.backLabel,
    required this.onBack,
    required this.trailing,
  });

  final double top;
  final double titleExtent;
  final ValueListenable<double> offset;
  final String title;
  final String backLabel;
  final VoidCallback onBack;
  final Widget? trailing;

  static const _barHeight = 44.0;

  @override
  double get minExtent => top + _barHeight;

  @override
  double get maxExtent => top + _barHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = context.colors;
    return ValueListenableBuilder<double>(
      valueListenable: offset,
      builder: (context, y, _) {
        final material = (y / 12).clamp(0.0, 1.0);
        final inline = ((y - titleExtent * 0.6) / (titleExtent * 0.5)).clamp(0.0, 1.0);
        final bar = SizedBox(
          height: _barHeight,
          child: NavigationToolbar(
            leading: Semantics(
              button: true,
              label: backLabel,
              excludeSemantics: true,
              child: PressFade(
                onTap: onBack,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 8),
                  child: SizedBox(
                    height: _barHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WaqtIcon(WaqtIcons.chevronLeft, size: 26, color: c.accent, strokeWidth: 2.4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            backLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtType.sans(17, weight: 500, color: c.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            middle: ExcludeSemantics(
              child: Opacity(
                opacity: inline,
                child: Transform.translate(
                  offset: Offset(0, 6 * (1 - inline)),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WaqtType.sans(17, weight: 600, color: c.ink),
                  ),
                ),
              ),
            ),
            trailing: trailing == null
                ? null
                : Padding(padding: const EdgeInsets.only(right: 10), child: trailing),
          ),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            if (material > 0)
              Opacity(
                opacity: material,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.bg.withValues(alpha: 0.82),
                        border: Border(bottom: BorderSide(color: c.hairline, width: 0.5)),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(padding: EdgeInsets.only(top: top), child: bar),
          ],
        );
      },
    );
  }

  @override
  bool shouldRebuild(_CupertinoBarDelegate old) =>
      old.top != top ||
      old.titleExtent != titleExtent ||
      old.offset != offset ||
      old.title != title ||
      old.backLabel != backLabel ||
      old.trailing != trailing;
}

/// iOS press feedback for text-like buttons: the child dims while held
/// (UIKit's highlighted state) instead of a Material ripple.
class PressFade extends StatefulWidget {
  const PressFade({super.key, required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<PressFade> createState() => _PressFadeState();
}

class _PressFadeState extends State<PressFade> {
  bool _down = false;

  void _set(bool v) {
    if (v != _down) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _down ? 0.35 : 1,
        duration: Duration(milliseconds: _down ? 0 : 180),
        child: widget.child,
      ),
    );
  }
}

/// Space at the end of a scroll view: clears the floating iOS tab bar (which
/// the shell reports as bottom padding) plus [extra].
class BottomSpace extends StatelessWidget {
  const BottomSpace({super.key, this.extra = 32});
  final double extra;

  @override
  Widget build(BuildContext context) => SizedBox(height: MediaQuery.paddingOf(context).bottom + extra);
}

/// Large-title header for tab roots (Quran, Library…): optional round action
/// buttons top-right, then the title (Literata 34), as on Me.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, this.actions = const [], this.subtitle});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top = MediaQuery.paddingOf(context).top;
    final cupertino = Adaptive.isCupertino(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(Gap.title, top + (cupertino ? 4 : 8), 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final a in actions) ...[a, const SizedBox(width: 6)],
              ],
            ),
          ),
          Semantics(header: true, child: Text(title, style: WaqtType.title(color: c.ink))),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: WaqtType.sans(15, color: c.muted)),
          ],
        ],
      ),
    );
  }
}

/// Friendly empty list placeholder: soft icon tile + one muted sentence.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.text, this.action});
  final WaqtIconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      child: Column(
        children: [
          IconTile(icon: icon, background: c.mint, color: c.onMint),
          const SizedBox(height: 14),
          Text(text, textAlign: TextAlign.center, style: WaqtType.sans(15, color: c.muted, height: 1.45)),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
