import 'package:flutter/foundation.dart';

import '../db/enums.dart';

@immutable
class SavedLocation {
  const SavedLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.timezone,
    this.manual = false,
  });

  final double latitude;
  final double longitude;

  /// Display name (city or "Near `city`"). No geocoding API is used.
  final String name;

  /// IANA zone id, e.g. `Asia/Ashgabat`.
  final String timezone;

  /// True when picked from the city list / typed, false when from GPS.
  final bool manual;

  /// Fallback until the user sets a location (main audience: Turkmenistan).
  static const ashgabat = SavedLocation(
    latitude: 37.9601,
    longitude: 58.3261,
    name: 'Ashgabat',
    timezone: 'Asia/Ashgabat',
    manual: true,
  );

  Map<String, Object?> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'name': name,
        'tz': timezone,
        'manual': manual,
      };

  static SavedLocation? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return SavedLocation(
      latitude: lat,
      longitude: lng,
      name: json['name'] as String? ?? '',
      timezone: json['tz'] as String? ?? 'UTC',
      manual: json['manual'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SavedLocation &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.name == name &&
      other.timezone == timezone &&
      other.manual == manual;

  @override
  int get hashCode => Object.hash(latitude, longitude, name, timezone, manual);
}

/// All user preferences. Persisted as one JSON blob by [SettingsRepository].
@immutable
class AppSettings {
  const AppSettings({
    this.calcMethod = CalcMethod.muslimWorldLeague,
    this.madhab = AsrMadhab.hanafi,
    this.offsets = const {},
    this.alerts = const {},
    this.location,
    this.language,
    this.currency = 'TMT',
    this.hijriAdjustment = 0,
    this.ramadanMode = RamadanMode.auto,
    this.periodMode = false,
    this.periodSince,
    this.theme = AppThemeMode.system,
    this.onboardingDone = false,
    this.adhkarReminders = false,
    this.suhoorReminder = true,
    this.suhoorMinutes = 30,
    this.iftarReminder = true,
    this.taraweehReminder = false,
  });

  final CalcMethod calcMethod;
  final AsrMadhab madhab;

  /// Minute offsets per prayer ("Match my mosque"), −30…+30.
  final Map<Prayer, int> offsets;
  final Map<Prayer, AlertType> alerts;

  /// Null until onboarding sets it; use [effectiveLocation].
  final SavedLocation? location;

  /// Language code (en/tk/tr/ru) or null for the system language.
  final String? language;
  final String currency;

  /// −2…+2 days applied to the Umm al-Qura date.
  final int hijriAdjustment;
  final RamadanMode ramadanMode;
  final bool periodMode;

  /// `yyyy-MM-dd` when period mode was switched on.
  final String? periodSince;
  final AppThemeMode theme;
  final bool onboardingDone;
  final bool adhkarReminders;
  final bool suhoorReminder;
  final int suhoorMinutes;
  final bool iftarReminder;
  final bool taraweehReminder;

  static const defaultAlert = AlertType.silent;

  SavedLocation get effectiveLocation => location ?? SavedLocation.ashgabat;
  int offsetFor(Prayer p) => offsets[p] ?? 0;
  AlertType alertFor(Prayer p) => alerts[p] ?? defaultAlert;

  AppSettings copyWith({
    CalcMethod? calcMethod,
    AsrMadhab? madhab,
    Map<Prayer, int>? offsets,
    Map<Prayer, AlertType>? alerts,
    SavedLocation? location,
    String? Function()? language,
    String? currency,
    int? hijriAdjustment,
    RamadanMode? ramadanMode,
    bool? periodMode,
    String? Function()? periodSince,
    AppThemeMode? theme,
    bool? onboardingDone,
    bool? adhkarReminders,
    bool? suhoorReminder,
    int? suhoorMinutes,
    bool? iftarReminder,
    bool? taraweehReminder,
  }) {
    return AppSettings(
      calcMethod: calcMethod ?? this.calcMethod,
      madhab: madhab ?? this.madhab,
      offsets: offsets ?? this.offsets,
      alerts: alerts ?? this.alerts,
      location: location ?? this.location,
      language: language != null ? language() : this.language,
      currency: currency ?? this.currency,
      hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
      ramadanMode: ramadanMode ?? this.ramadanMode,
      periodMode: periodMode ?? this.periodMode,
      periodSince: periodSince != null ? periodSince() : this.periodSince,
      theme: theme ?? this.theme,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      adhkarReminders: adhkarReminders ?? this.adhkarReminders,
      suhoorReminder: suhoorReminder ?? this.suhoorReminder,
      suhoorMinutes: suhoorMinutes ?? this.suhoorMinutes,
      iftarReminder: iftarReminder ?? this.iftarReminder,
      taraweehReminder: taraweehReminder ?? this.taraweehReminder,
    );
  }

  Map<String, Object?> toJson() => {
        'v': 1,
        'calcMethod': calcMethod.name,
        'madhab': madhab.name,
        'offsets': {for (final e in offsets.entries) e.key.name: e.value},
        'alerts': {for (final e in alerts.entries) e.key.name: e.value.name},
        'location': location?.toJson(),
        'language': language,
        'currency': currency,
        'hijriAdjustment': hijriAdjustment,
        'ramadanMode': ramadanMode.name,
        'periodMode': periodMode,
        'periodSince': periodSince,
        'theme': theme.name,
        'onboardingDone': onboardingDone,
        'adhkarReminders': adhkarReminders,
        'suhoorReminder': suhoorReminder,
        'suhoorMinutes': suhoorMinutes,
        'iftarReminder': iftarReminder,
        'taraweehReminder': taraweehReminder,
      };

  factory AppSettings.fromJson(Map<String, Object?> j) {
    final offsets = <Prayer, int>{};
    final rawOffsets = j['offsets'];
    if (rawOffsets is Map) {
      rawOffsets.forEach((k, v) {
        final p = Prayer.tryParse(k as String?);
        if (p != null && v is num) offsets[p] = v.toInt().clamp(-30, 30);
      });
    }
    final alerts = <Prayer, AlertType>{};
    final rawAlerts = j['alerts'];
    if (rawAlerts is Map) {
      rawAlerts.forEach((k, v) {
        final p = Prayer.tryParse(k as String?);
        if (p != null) alerts[p] = enumByName(AlertType.values, v as String?, defaultAlert);
      });
    }
    return AppSettings(
      calcMethod: enumByName(CalcMethod.values, j['calcMethod'] as String?, CalcMethod.muslimWorldLeague),
      madhab: enumByName(AsrMadhab.values, j['madhab'] as String?, AsrMadhab.hanafi),
      offsets: offsets,
      alerts: alerts,
      location: SavedLocation.fromJson(j['location']),
      language: j['language'] as String?,
      currency: j['currency'] as String? ?? 'TMT',
      hijriAdjustment: ((j['hijriAdjustment'] as num?)?.toInt() ?? 0).clamp(-2, 2),
      ramadanMode: enumByName(RamadanMode.values, j['ramadanMode'] as String?, RamadanMode.auto),
      periodMode: j['periodMode'] as bool? ?? false,
      periodSince: j['periodSince'] as String?,
      theme: enumByName(AppThemeMode.values, j['theme'] as String?, AppThemeMode.system),
      onboardingDone: j['onboardingDone'] as bool? ?? false,
      adhkarReminders: j['adhkarReminders'] as bool? ?? false,
      suhoorReminder: j['suhoorReminder'] as bool? ?? true,
      suhoorMinutes: ((j['suhoorMinutes'] as num?)?.toInt() ?? 30).clamp(5, 120),
      iftarReminder: j['iftarReminder'] as bool? ?? true,
      taraweehReminder: j['taraweehReminder'] as bool? ?? false,
    );
  }
}
