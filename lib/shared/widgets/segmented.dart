import 'package:flutter/material.dart';

import '../../core/platform/adaptive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dimens.dart';

/// Segmented control: fill background (radius 12) with a card-coloured
/// thumb (radius 9) behind the selected option.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(Radii.segment)),
      child: Row(
        children: [
          for (final (v, label) in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: v == value,
                label: label,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (v != value) {
                      Haptics.tap();
                      onChanged(v);
                    }
                  },
                  child: AnimatedContainer(
                    duration: Adaptive.motion(context, 180),
                    height: 38,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: v == value ? c.card : Colors.transparent,
                      borderRadius: BorderRadius.circular(Radii.segmentInner),
                      boxShadow: v == value && !c.isDark
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 3, offset: const Offset(0, 1))]
                          : null,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WaqtType.sans(14, weight: v == value ? 600 : 500, color: v == value ? c.ink : c.muted),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
