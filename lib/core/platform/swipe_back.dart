import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

/// iOS page transition with the iOS 26 back gesture: a rightward drag that
/// starts anywhere on the page pops it, not only one from the 20 pt edge.
///
/// Like UIKit, the edge keeps priority over everything, while inside the
/// page any horizontal scroller, slider, page view or swipe-to-delete row
/// below the finger wins (they join the gesture arena first). A drag that
/// starts leftward is never claimed, so trailing swipe actions keep working.
class FullSwipeBackPageTransitionsBuilder extends CupertinoPageTransitionsBuilder {
  const FullSwipeBackPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.fullscreenDialog) {
      return super.buildTransitions(route, context, animation, secondaryAnimation, child);
    }
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: route.popGestureInProgress,
      child: SwipeBackDetector(route: route, child: child),
    );
  }
}

/// Width of the always-wins strip at the leading edge (UIKit ≈ 20–24 pt).
const double _edgeWidth = 24;

/// Release faster than this (screen widths per second) to commit or cancel
/// regardless of position; same value as Flutter's Cupertino route.
const double _minFlingVelocity = 1;

const Duration _settleDuration = Duration(milliseconds: 350);

@visibleForTesting
class SwipeBackDetector extends StatefulWidget {
  const SwipeBackDetector({super.key, required this.route, required this.child});

  final PageRoute<dynamic> route;
  final Widget child;

  @override
  State<SwipeBackDetector> createState() => _SwipeBackDetectorState();
}

class _SwipeBackDetectorState extends State<SwipeBackDetector> {
  late final HorizontalDragGestureRecognizer _edge;
  late final _ForwardDragGestureRecognizer _content;
  _BackGestureController? _controller;

  @override
  void initState() {
    super.initState();
    _edge = HorizontalDragGestureRecognizer(debugOwner: this);
    _content = _ForwardDragGestureRecognizer(debugOwner: this, isRtl: () => _rtl);
    for (final r in <DragGestureRecognizer>[_edge, _content]) {
      r
        ..onStart = _start
        ..onUpdate = _update
        ..onEnd = _end
        ..onCancel = _cancel;
    }
  }

  @override
  void dispose() {
    _edge.dispose();
    _content.dispose();
    final controller = _controller;
    if (controller != null) {
      // Disposed mid-drag (e.g. the route was removed): release the navigator.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.navigator.mounted) controller.navigator.didStopUserGesture();
      });
      _controller = null;
    }
    super.dispose();
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  bool get _enabled => widget.route.popGestureEnabled && !widget.route.navigator!.userGestureInProgress;

  double _logical(double v) => _rtl ? -v : v;

  void _start(DragStartDetails d) {
    // ignore: invalid_use_of_protected_member
    final animation = widget.route.controller;
    if (animation == null || _controller != null) return;
    _controller = _BackGestureController(
      navigator: widget.route.navigator!,
      animation: animation,
      isCurrent: () => widget.route.isCurrent,
      isActive: () => widget.route.isActive,
    );
  }

  void _update(DragUpdateDetails d) {
    _controller?.dragUpdate(_logical(d.primaryDelta! / context.size!.width));
  }

  void _end(DragEndDetails d) {
    _controller?.dragEnd(_logical(d.velocity.pixelsPerSecond.dx / context.size!.width));
    _controller = null;
  }

  void _cancel() {
    _controller?.dragEnd(0);
    _controller = null;
  }

  void _edgeDown(PointerDownEvent e) {
    if (_enabled) _edge.addPointer(e);
  }

  void _contentDown(PointerDownEvent e) {
    if (_enabled) _content.addPointer(e);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final notch = _rtl ? padding.right : padding.left;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Wraps the page, so recognizers inside it are in the arena first.
        Listener(onPointerDown: _contentDown, behavior: HitTestBehavior.translucent, child: widget.child),
        // On top: hit first, so the edge strip beats inner recognizers.
        PositionedDirectional(
          start: 0,
          width: math.max(notch, _edgeWidth),
          top: 0,
          bottom: 0,
          child: Listener(onPointerDown: _edgeDown, behavior: HitTestBehavior.translucent),
        ),
      ],
    );
  }
}

/// Horizontal drag that bows out as soon as the finger moves backward
/// (leftward in LTR) before the gesture is accepted.
class _ForwardDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  _ForwardDragGestureRecognizer({super.debugOwner, required this.isRtl});

  final bool Function() isRtl;
  final Map<int, Offset> _origins = {};
  final Set<int> _accepted = {};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _origins[event.pointer] = event.position;
  }

  @override
  void handleEvent(PointerEvent event) {
    final origin = _origins[event.pointer];
    if (event is PointerMoveEvent && origin != null && !_accepted.contains(event.pointer)) {
      final dx = (event.position - origin).dx * (isRtl() ? -1 : 1);
      if (dx < -2) {
        _origins.remove(event.pointer);
        resolvePointer(event.pointer, GestureDisposition.rejected);
        return;
      }
    }
    super.handleEvent(event);
  }

  @override
  void acceptGesture(int pointer) {
    _accepted.add(pointer);
    super.acceptGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _origins.clear();
    _accepted.clear();
    super.didStopTrackingLastPointer(pointer);
  }
}

/// Drives the route's animation from the drag, then settles it (mirrors
/// Flutter's private Cupertino back gesture controller).
class _BackGestureController {
  _BackGestureController({
    required this.navigator,
    required this.animation,
    required this.isCurrent,
    required this.isActive,
  }) {
    navigator.didStartUserGesture();
  }

  final NavigatorState navigator;
  final AnimationController animation;
  final bool Function() isCurrent;
  final bool Function() isActive;

  void dragUpdate(double delta) => animation.value -= delta;

  void dragEnd(double velocity) {
    const curve = Curves.fastEaseInToSlowEaseOut;
    final current = isCurrent();
    final bool stay;
    if (!current) {
      stay = isActive();
    } else if (velocity.abs() >= _minFlingVelocity) {
      stay = velocity <= 0;
    } else {
      stay = animation.value > 0.5;
    }

    if (stay) {
      animation.animateTo(1, duration: _settleDuration, curve: curve);
    } else {
      if (current) navigator.pop();
      if (animation.isAnimating) {
        animation.animateBack(0, duration: _settleDuration, curve: curve);
      }
    }

    if (animation.isAnimating) {
      // Keep userGestureInProgress until the page has settled, so the
      // transition stays linear and no second drag starts mid-flight.
      late final AnimationStatusListener listener;
      listener = (status) {
        navigator.didStopUserGesture();
        animation.removeStatusListener(listener);
      };
      animation.addStatusListener(listener);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
