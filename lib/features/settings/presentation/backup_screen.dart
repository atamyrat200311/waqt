import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../data/backup/backup_service.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';

/// Export everything to a JSON file (shared via the system sheet) and
/// restore from one — the no-account answer to changing phones.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _message;

  BackupService get _service => BackupService(ref.read(databaseProvider));

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final json = await _service.export(ref.read(settingsProvider));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/waqt-backup-${DayKey.fromDate(DateTime.now()).value}.json');
      await file.writeAsString(json);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
    } on Object {
      if (mounted) setState(() => _message = context.l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l = context.l10n;
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['json']);
    if (file == null || !mounted) return;
    final raw = utf8.decode(await file.readAsBytes());
    if (BackupService.peekSettings(raw) == null) {
      setState(() => _message = l.backupInvalid);
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l.backupRestoreTitle),
        content: Text(l.backupRestoreBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.backupRestore)),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      final restored = await _service.restore(raw);
      await ref.read(settingsProvider.notifier).update((_) => restored.copyWith(onboardingDone: true));
      Haptics.success();
      if (mounted) setState(() => _message = l.backupRestored);
    } on Object {
      if (mounted) setState(() => _message = l.backupInvalid);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return SubScreen(
      title: l.backupTitle,
      backLabel: l.settingsTitle,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
          sliver: SliverList.list(
            children: [
              WaqtCard(
                color: c.mint,
                border: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WaqtIcon(WaqtIcons.lock, color: c.onMint),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.backupIntro, style: WaqtType.sans(14.5, color: c.onMint, height: 1.45))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BigButton(label: l.backupExport, onPressed: _busy ? null : _export),
              const SizedBox(height: 10),
              PillButton(
                label: l.backupImport,
                icon: WaqtIcons.upload,
                style: PillStyle.fill,
                expand: true,
                height: 52,
                onPressed: _busy ? null : _import,
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!, textAlign: TextAlign.center, style: WaqtType.sans(14.5, weight: 600, color: c.accent)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
