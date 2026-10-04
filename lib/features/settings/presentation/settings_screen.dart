import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/platform/system_settings.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/enums.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/choice_sheet.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/rows.dart';
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../notifications/application/notification_service.dart';

const appVersion = '1.0.0';

/// Language codes offered in Settings (null = system).
const languageNames = <String?, String>{
  null: '',
  'en': 'English',
  'tk': 'Türkmen',
  'tr': 'Türkçe',
  'ru': 'Русский',
};

/// Notification permission state; refreshed when the app resumes.
final notificationPermissionsProvider = FutureProvider<NotificationPermissions>((ref) {
  ref.watch(appLifecycleProvider);
  return ref.watch(notificationServiceProvider).permissions();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final perms = ref.watch(notificationPermissionsProvider).value;
    final android = !Adaptive.isCupertino(context);

    final offsets = [for (final p in Prayer.values) s.offsetFor(p)];
    final uniform = offsets.every((o) => o == offsets.first);
    String signed(int v) => v > 0 ? '+$v' : v < 0 ? '−${v.abs()}' : '±0';

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(32, 22, 32, 8),
          child: Semantics(
            header: true,
            child: Text(text.toUpperCase(), style: WaqtType.kicker(color: c.muted, size: 12, tracking: 0.07)),
          ),
        );

    Widget group(List<Widget> rows) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
          child: WaqtGroup(radius: Radii.listGroup, children: rows),
        );

    return SubScreen(
      title: l.settingsTitle,
      backLabel: l.tabMe,
      slivers: [
        SliverList.list(children: [
          header(l.secPrayerTimes),
          group([
            WaqtRow(
              title: l.location,
              value: displayPlaceName(s.effectiveLocation.name, l),
              onTap: () => context.push(Routes.location),
            ),
            WaqtRow(
              title: l.calcMethod,
              value: l.method(s.calcMethod),
              onTap: () async {
                final m = await showChoiceSheet<CalcMethod>(
                  context,
                  title: l.calcMethod,
                  selected: s.calcMethod,
                  options: [for (final m in CalcMethod.values) (m, l.method(m), null)],
                );
                if (m != null) await ctl.setCalcMethod(m);
              },
            ),
            WaqtRow(
              title: l.asr,
              chevron: false,
              trailing: SizedBox(
                width: 200,
                child: Segmented<AsrMadhab>(
                  value: s.madhab,
                  options: [(AsrMadhab.standard, l.asrStandard), (AsrMadhab.hanafi, l.asrHanafi)],
                  onChanged: ctl.setMadhab,
                ),
              ),
            ),
            WaqtRow(
              title: l.matchMosque,
              subtitle: uniform ? l.matchMosqueSub : l.perPrayerOffsets,
              onTap: () => showOffsetsSheet(context),
              chevron: false,
              trailing: _Stepper(
                label: uniform ? l.offsetMinutes(signed(offsets.first)) : '…',
                onMinus: () => ctl.shiftAllOffsets(-1),
                onPlus: () => ctl.shiftAllOffsets(1),
                minusLabel: '${l.matchMosque} −1',
                plusLabel: '${l.matchMosque} +1',
              ),
            ),
            WaqtRow(
              title: l.hijriAdjust,
              subtitle: l.hijriAdjustSub,
              chevron: false,
              trailing: _Stepper(
                label: s.hijriAdjustment == 0 ? '±0' : signed(s.hijriAdjustment),
                onMinus: s.hijriAdjustment > -2 ? () => ctl.setHijriAdjustment(s.hijriAdjustment - 1) : null,
                onPlus: s.hijriAdjustment < 2 ? () => ctl.setHijriAdjustment(s.hijriAdjustment + 1) : null,
                minusLabel: '${l.hijriAdjust} −1',
                plusLabel: '${l.hijriAdjust} +1',
              ),
            ),
          ]),
          header(l.secAlerts),
          if (perms != null && !perms.enabled)
            _Banner(
              text: l.notifPermissionOff,
              action: l.obAllowNotif,
              onAction: () async {
                final ok = await ref.read(notificationServiceProvider).requestPermission();
                // Permanently denied: the system won't ask again, open settings.
                if (!ok) await SystemSettings.openNotifications();
                ref.invalidate(notificationPermissionsProvider);
              },
            )
          else if (perms != null && android && !perms.exactAlarms)
            _Banner(
              text: l.exactAlarmOff,
              action: l.allowExact,
              onAction: () async {
                await ref.read(notificationServiceProvider).requestExactAlarms();
                ref.invalidate(notificationPermissionsProvider);
              },
            ),
          group([
            for (final p in Prayer.values)
              WaqtRow(
                title: l.prayer(p),
                chevron: false,
                trailing: SizedBox(
                  width: 214,
                  child: Segmented<AlertType>(
                    value: s.alertFor(p),
                    options: [for (final t in AlertType.values) (t, l.alert(t))],
                    onChanged: (t) => ctl.setAlert(p, t),
                  ),
                ),
              ),
            ToggleRow(
              title: l.adhkarReminders,
              subtitle: l.adhkarRemindersSub,
              value: s.adhkarReminders,
              onChanged: ctl.setAdhkarReminders,
            ),
          ]),
          header(l.secGeneral),
          group([
            WaqtRow(
              title: l.language,
              value: s.language == null ? l.languageSystem : languageNames[s.language],
              onTap: () async {
                final picked = await showChoiceSheet<String>(
                  context,
                  title: l.language,
                  selected: s.language ?? '',
                  options: [
                    for (final e in languageNames.entries)
                      (e.key ?? '', e.key == null ? l.languageSystem : e.value, null),
                  ],
                );
                if (picked != null) await ctl.setLanguage(picked.isEmpty ? null : picked);
              },
            ),
            WaqtRow(
              title: l.currency,
              value: '${s.currency} · ${supportedCurrencies[s.currency] ?? ''}',
              onTap: () async {
                final picked = await showChoiceSheet<String>(
                  context,
                  title: l.currency,
                  selected: s.currency,
                  options: [for (final e in supportedCurrencies.entries) (e.key, e.key, e.value)],
                );
                if (picked != null) await ctl.setCurrency(picked);
              },
            ),
            WaqtRow(
              title: l.ramadanMode,
              value: switch (s.ramadanMode) {
                RamadanMode.auto => l.ramadanAuto,
                RamadanMode.on => l.ramadanOn,
                RamadanMode.off => l.ramadanOff,
              },
              onTap: () async {
                final picked = await showChoiceSheet<RamadanMode>(
                  context,
                  title: l.ramadanMode,
                  selected: s.ramadanMode,
                  options: [
                    (RamadanMode.auto, l.ramadanAuto, l.ramadanNotNow),
                    (RamadanMode.on, l.ramadanOn, null),
                    (RamadanMode.off, l.ramadanOff, null),
                  ],
                );
                if (picked != null) await ctl.setRamadanMode(picked);
              },
            ),
            ToggleRow(
              title: l.periodMode,
              subtitle: l.periodModeSub,
              value: s.periodMode,
              onChanged: (v) => ctl.setPeriodMode(v, now: ref.read(clockProvider)()),
            ),
            WaqtRow(
              title: l.appearance,
              chevron: false,
              trailing: SizedBox(
                width: 200,
                child: Segmented<AppThemeMode>(
                  value: s.theme,
                  options: [
                    (AppThemeMode.light, l.themeLight),
                    (AppThemeMode.dark, l.themeDark),
                    (AppThemeMode.system, l.themeAuto),
                  ],
                  onChanged: ctl.setTheme,
                ),
              ),
            ),
            WaqtRow(title: l.widgets, onTap: () => context.push(Routes.widgetsHelp)),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
            child: Column(
              children: [
                WaqtIcon(WaqtIcons.lock, size: 18, color: c.muted),
                const SizedBox(height: 8),
                Text(l.privacyNote, textAlign: TextAlign.center, style: WaqtType.sans(13, color: c.muted, height: 1.5)),
                const SizedBox(height: 8),
                Opacity(
                  opacity: 0.8,
                  child: Text(l.versionLabel(appVersion), style: WaqtType.sans(12, color: c.muted)),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.onMinus,
    required this.onPlus,
    required this.minusLabel,
    required this.plusLabel,
  });

  final String label;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final String minusLabel;
  final String plusLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget btn(String glyph, VoidCallback? f, String a11y) => Semantics(
          button: true,
          label: a11y,
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: f == null
                ? null
                : () {
                    Haptics.tap();
                    f();
                  },
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: Text(glyph, style: WaqtType.sans(20, color: f == null ? c.hairline : c.ink)),
              ),
            ),
          ),
        );
    return Container(
      decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn('−', onMinus, minusLabel),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 58),
            child: Text(label, textAlign: TextAlign.center, style: WaqtType.sans(15, weight: 600, color: c.ink)),
          ),
          btn('+', onPlus, plusLabel),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.action, required this.onAction});
  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, 10),
      child: WaqtCard(
        color: c.brassSoft,
        border: false,
        radius: Radii.listGroup,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: WaqtType.sans(14, weight: 600, color: c.brassText, height: 1.4)),
            const SizedBox(height: 10),
            PillButton(label: action, style: PillStyle.brass, height: 38, fontSize: 14, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

/// Per-prayer offsets (tapping "Match my mosque").
Future<void> showOffsetsSheet(BuildContext context) =>
    Adaptive.showSheet<void>(context, builder: (_) => const _OffsetsSheet());

class _OffsetsSheet extends ConsumerWidget {
  const _OffsetsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    String signed(int v) => v > 0 ? '+$v' : v < 0 ? '−${v.abs()}' : '±0';
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.perPrayerOffsets, style: WaqtType.serif(26, tracking: -0.015, color: c.ink)),
          const SizedBox(height: 4),
          Text(l.matchMosqueSub, style: WaqtType.sans(14, color: c.muted)),
          const SizedBox(height: 14),
          for (final p in Prayer.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(l.prayer(p), style: WaqtType.sans(16, weight: 600, color: c.ink))),
                  _Stepper(
                    label: l.offsetMinutes(signed(s.offsetFor(p))),
                    onMinus: s.offsetFor(p) > -30 ? () => ctl.setOffset(p, s.offsetFor(p) - 1) : null,
                    onPlus: s.offsetFor(p) < 30 ? () => ctl.setOffset(p, s.offsetFor(p) + 1) : null,
                    minusLabel: '${l.prayer(p)} −1',
                    plusLabel: '${l.prayer(p)} +1',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
