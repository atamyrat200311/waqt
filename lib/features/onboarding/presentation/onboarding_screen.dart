import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/db/enums.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/choice_sheet.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/domain/method_presets.dart';
import '../../settings/presentation/location_picker.dart';
import '../../settings/presentation/settings_screen.dart' show languageNames;

/// First-run flow: language → location (+ method preset) → notifications →
/// (Android) battery → start.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { language, location, notifications, battery }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.language;
  bool _notifAllowed = false;

  List<_Step> get _steps => [
        _Step.language,
        _Step.location,
        _Step.notifications,
        if (!Adaptive.isCupertino(context)) _Step.battery,
      ];

  void _next() {
    final i = _steps.indexOf(_step);
    if (i == _steps.length - 1) {
      ref.read(settingsProvider.notifier).setOnboardingDone();
    } else {
      setState(() => _step = _steps[i + 1]);
    }
  }

  void _back() {
    final i = _steps.indexOf(_step);
    if (i > 0) setState(() => _step = _steps[i - 1]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final steps = _steps;
    final index = steps.indexOf(_step);
    final last = index == steps.length - 1;

    final body = switch (_step) {
      _Step.language => _LanguageStep(onPicked: _next),
      _Step.location => const _LocationStep(),
      _Step.notifications => _NotificationsStep(
          allowed: _notifAllowed,
          onAllow: () async {
            final ok = await ref.read(notificationServiceProvider).requestPermission();
            if (mounted) setState(() => _notifAllowed = ok);
          },
        ),
      _Step.battery => const _BatteryStep(),
    };

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, top + 12, 20, 16 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (index > 0)
                    CircleIconButton(
                      icon: WaqtIcons.chevronLeft,
                      semanticLabel: l.back,
                      foreground: c.accent,
                      onPressed: _back,
                    )
                  else
                    const SizedBox(height: 44),
                  const Spacer(),
                  for (var i = 0; i < steps.length; i++)
                    AnimatedContainer(
                      duration: Adaptive.motion(context, 250),
                      margin: const EdgeInsets.only(left: 6),
                      width: i == index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i <= index ? c.brass : c.hairline,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Adaptive.motion(context, 220),
                  child: KeyedSubtree(key: ValueKey(_step), child: body),
                ),
              ),
              const SizedBox(height: 12),
              if (_step != _Step.language)
                BigButton(label: last ? l.obStart : l.continueLabel, onPressed: _next),
              if (_step == _Step.notifications && !_notifAllowed)
                TextButton(
                  onPressed: _next,
                  child: Text(l.notNow, style: WaqtType.sans(15, weight: 600, color: c.muted)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.title, {this.kicker, this.body});
  final String title;
  final String? kicker;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kicker != null) ...[
          Text(kicker!, style: WaqtType.sans(16, weight: 600, color: c.brassText)),
          const SizedBox(height: 10),
        ],
        Semantics(header: true, child: Text(title, style: WaqtType.title(color: c.ink))),
        if (body != null) ...[
          const SizedBox(height: 10),
          Text(body!, style: WaqtType.sans(15, color: c.muted, height: 1.5)),
        ],
      ],
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep({required this.onPicked});
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final current = ref.watch(settingsProvider.select((s) => s.language)) ??
        Localizations.localeOf(context).languageCode;
    return ListView(
      children: [
        const SizedBox(height: 12),
        _Title(l.obLanguageTitle, kicker: l.obGreeting, body: l.obLanguageSub),
        const SizedBox(height: 24),
        WaqtGroup(
          children: [
            for (final e in languageNames.entries.where((e) => e.key != null))
              InkWell(
                onTap: () async {
                  await ref.read(settingsProvider.notifier).setLanguage(e.key);
                  onPicked();
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(child: Text(e.value, style: WaqtType.sans(17, weight: 600, color: c.ink))),
                        if (current == e.key) WaqtIcon(WaqtIcons.check, color: c.accent),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            WaqtIcon(WaqtIcons.lock, size: 16, color: c.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(l.obPrivacy, style: WaqtType.sans(13, color: c.muted))),
          ],
        ),
      ],
    );
  }
}

class _LocationStep extends ConsumerWidget {
  const _LocationStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    return ListView(
      children: [
        const SizedBox(height: 12),
        _Title(l.obLocationTitle),
        const SizedBox(height: 16),
        WaqtCard(
          color: c.mint,
          border: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              WaqtIcon(WaqtIcons.pin, size: 18, color: c.onMint),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayPlaceName(s.effectiveLocation.name, l),
                      style: WaqtType.sans(16, weight: 600, color: c.ink),
                    ),
                    Text(
                      l.obMethodLine(l.method(s.calcMethod), l.madhabName(s.madhab)),
                      style: WaqtType.sans(13, color: c.muted),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final m = await showChoiceSheet<CalcMethod>(
                    context,
                    title: l.calcMethod,
                    selected: s.calcMethod,
                    options: [for (final m in CalcMethod.values) (m, l.method(m), null)],
                  );
                  if (m != null) await ctl.setCalcMethod(m);
                  if (!context.mounted) return;
                  final a = await showChoiceSheet<AsrMadhab>(
                    context,
                    title: l.asr,
                    selected: ref.read(settingsProvider).madhab,
                    options: [
                      (AsrMadhab.standard, l.asrStandard, null),
                      (AsrMadhab.hanafi, l.asrHanafi, null),
                    ],
                  );
                  if (a != null) await ctl.setMadhab(a);
                },
                child: Text(l.obAdvanced, style: WaqtType.sans(14, weight: 600, color: c.onMint)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LocationPicker(
          onPicked: (loc, {countryCode}) async {
            await ctl.setLocation(loc);
            final preset = presetForRegion(countryCode: countryCode, timezone: loc.timezone);
            await ctl.setCalcMethod(preset.method);
            await ctl.setMadhab(preset.madhab);
          },
        ),
      ],
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({required this.allowed, required this.onAllow});
  final bool allowed;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return ListView(
      children: [
        const SizedBox(height: 12),
        _Title(l.obNotifTitle, body: l.obNotifBody),
        const SizedBox(height: 28),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: allowed ? c.mint : c.brassSoft, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: WaqtIcon(WaqtIcons.bell, size: 40, color: allowed ? c.onMint : c.brassText),
          ),
        ),
        const SizedBox(height: 28),
        if (allowed)
          Center(child: Text(l.obNotifAllowed, style: WaqtType.sans(16, weight: 600, color: c.accent)))
        else
          PillButton(
            label: l.obAllowNotif,
            style: PillStyle.mint,
            height: 52,
            radius: 16,
            expand: true,
            onPressed: onAllow,
          ),
      ],
    );
  }
}

class _BatteryStep extends StatelessWidget {
  const _BatteryStep();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return ListView(
      children: [
        const SizedBox(height: 12),
        _Title(l.obBatteryTitle, body: l.obBatteryBody),
        const SizedBox(height: 28),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: c.mint, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: WaqtIcon(WaqtIcons.battery, size: 40, color: c.onMint),
          ),
        ),
        const SizedBox(height: 28),
        PillButton(
          label: l.obOpenBattery,
          style: PillStyle.mint,
          height: 52,
          radius: 16,
          expand: true,
          // App settings → Battery (no plugin can open the exemption dialog
          // without the REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission).
          onPressed: Geolocator.openAppSettings,
        ),
      ],
    );
  }
}
