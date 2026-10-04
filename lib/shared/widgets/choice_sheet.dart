import 'package:flutter/material.dart';

import '../../core/platform/adaptive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'waqt_icon.dart';

/// Bottom sheet with a single-choice list. Returns the picked value.
Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T, String, String?)> options,
  required T selected,
}) =>
    Adaptive.showSheet<T>(
      context,
      builder: (ctx) {
        final c = ctx.colors;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 16 + MediaQuery.paddingOf(ctx).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(title, style: WaqtType.serif(26, tracking: -0.015, color: c.ink)),
              ),
              for (final (value, label, sub) in options)
                Semantics(
                  selected: value == selected,
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(ctx).pop(value),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    label,
                                    style: WaqtType.sans(16, weight: value == selected ? 600 : 500, color: c.ink),
                                  ),
                                  if (sub != null)
                                    Text(sub, style: WaqtType.sans(13, color: c.muted)),
                                ],
                              ),
                            ),
                            if (value == selected) WaqtIcon(WaqtIcons.check, size: 20, color: c.accent),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
