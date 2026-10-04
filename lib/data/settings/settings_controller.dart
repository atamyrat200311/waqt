import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../db/enums.dart';
import 'app_settings.dart';
import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(SharedPrefsStore()),
);

/// Loaded once in `main()` before `runApp` and injected via override, so the
/// first frame already has the right theme, locale and location.
final initialSettingsProvider = Provider<AppSettings>((ref) => const AppSettings());

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    state = change(state);
    await _repo.save(state);
  }

  Future<void> setCalcMethod(CalcMethod m) => update((s) => s.copyWith(calcMethod: m));
  Future<void> setMadhab(AsrMadhab m) => update((s) => s.copyWith(madhab: m));

  Future<void> setOffset(Prayer p, int minutes) => update(
        (s) => s.copyWith(offsets: {...s.offsets, p: minutes.clamp(-30, 30)}),
      );

  /// "Match my mosque" stepper: shifts all five by [delta].
  Future<void> shiftAllOffsets(int delta) => update(
        (s) => s.copyWith(offsets: {
          for (final p in Prayer.values) p: (s.offsetFor(p) + delta).clamp(-30, 30),
        }),
      );

  Future<void> setAlert(Prayer p, AlertType t) =>
      update((s) => s.copyWith(alerts: {...s.alerts, p: t}));

  Future<void> setLocation(SavedLocation l) => update((s) => s.copyWith(location: l));
  Future<void> setLanguage(String? code) => update((s) => s.copyWith(language: () => code));
  Future<void> setCurrency(String code) => update((s) => s.copyWith(currency: code));

  Future<void> setHijriAdjustment(int days) =>
      update((s) => s.copyWith(hijriAdjustment: days.clamp(-2, 2)));

  Future<void> setRamadanMode(RamadanMode m) => update((s) => s.copyWith(ramadanMode: m));

  Future<void> setPeriodMode(bool on, {DateTime? now}) => update(
        (s) => s.copyWith(
          periodMode: on,
          periodSince: () => on ? DayKey.fromDate(now ?? DateTime.now()).value : null,
        ),
      );

  Future<void> setTheme(AppThemeMode t) => update((s) => s.copyWith(theme: t));
  Future<void> setOnboardingDone() => update((s) => s.copyWith(onboardingDone: true));
  Future<void> setAdhkarReminders(bool on) => update((s) => s.copyWith(adhkarReminders: on));
  Future<void> setSuhoorReminder(bool on) => update((s) => s.copyWith(suhoorReminder: on));
  Future<void> setSuhoorMinutes(int m) => update((s) => s.copyWith(suhoorMinutes: m));
  Future<void> setIftarReminder(bool on) => update((s) => s.copyWith(iftarReminder: on));
  Future<void> setTaraweehReminder(bool on) => update((s) => s.copyWith(taraweehReminder: on));
}
