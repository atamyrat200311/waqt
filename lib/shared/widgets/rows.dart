import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'waqt_icon.dart';

/// Settings-style row: title, optional subtitle, trailing widget or chevron.
class WaqtRow extends StatelessWidget {
  const WaqtRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.trailing,
    this.onTap,
    this.chevron,
  });

  final String title;
  final String? subtitle;

  /// Muted value shown before the chevron ("Muslim World League").
  final String? value;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Defaults to true when [onTap] is set and there is no [trailing].
  final bool? chevron;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final showChevron = chevron ?? (onTap != null && trailing == null);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 12, 10),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: WaqtType.sans(16, weight: 600, color: c.ink)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: WaqtType.sans(13, color: c.muted, height: 1.35)),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 170),
                  child: Text(
                    value!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: WaqtType.sans(14, color: c.muted),
                  ),
                ),
              ],
              ?trailing,
              if (showChevron) ...[
                const SizedBox(width: 4),
                WaqtIcon(WaqtIcons.chevronRight, size: 16, color: c.muted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Row with an adaptive switch in the brand colour.
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: WaqtRow(
        title: title,
        subtitle: subtitle,
        leading: leading,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        chevron: false,
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: c.primary,
          activeThumbColor: c.isDark ? c.onPrimary : null,
        ),
      ),
    );
  }
}
