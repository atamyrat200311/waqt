import 'package:flutter/foundation.dart';

import '../../features/quran/domain/quran.dart' show KhatmPlan;
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

/// Quran / hadith reading preferences.
@immutable
class ReaderPrefs {
  const ReaderPrefs({
    this.translation,
    this.showTranslation = true,
    this.showTranslit = false,
    this.arabicSize = 30,
    this.textSize = 17,
    this.quranFont = 'amiri',
    this.tajweed = false,
    this.mushafStyle = false,
    this.sepia = false,
    this.keepAwake = true,
    this.dailyGoal = 10,
    this.hadithArabic = true,
    this.hadithLanguage,
  });

  /// Translation id (`en_sahih`…) or null for the default of the app
  /// language. Use [QuranTranslations.resolve].
  final String? translation;
  final bool showTranslation;
  final bool showTranslit;
  final double arabicSize;
  final double textSize;

  /// `amiri` (Amiri Quran) or `scheherazade` (Scheherazade New).
  final String quranFont;

  /// Colour the tajweed rules in the Arabic text.
  final bool tajweed;

  /// Parchment page, Madani 15-line layout, coloured "Allah", gold ayah medallions.
  final bool mushafStyle;

  /// Warm paper background in the readers.
  final bool sepia;
  final bool keepAwake;

  /// Ayahs per day for the reading ring when no khatm plan is active.
  final int dailyGoal;

  /// Show the Arabic text of hadith alongside the translation.
  final bool hadithArabic;

  /// Hadith translation edition (`eng`/`rus`/`tur`) or null for the default.
  final String? hadithLanguage;

  static const minArabic = 22.0, maxArabic = 48.0, minText = 14.0, maxText = 26.0;

  ReaderPrefs copyWith({
    String? Function()? translation,
    bool? showTranslation,
    bool? showTranslit,
    double? arabicSize,
    double? textSize,
    String? quranFont,
    bool? tajweed,
    bool? mushafStyle,
    bool? sepia,
    bool? keepAwake,
    int? dailyGoal,
    bool? hadithArabic,
    String? Function()? hadithLanguage,
  }) {
    return ReaderPrefs(
      translation: translation != null ? translation() : this.translation,
      showTranslation: showTranslation ?? this.showTranslation,
      showTranslit: showTranslit ?? this.showTranslit,
      arabicSize: (arabicSize ?? this.arabicSize).clamp(minArabic, maxArabic),
      textSize: (textSize ?? this.textSize).clamp(minText, maxText),
      quranFont: quranFont ?? this.quranFont,
      tajweed: tajweed ?? this.tajweed,
      mushafStyle: mushafStyle ?? this.mushafStyle,
      sepia: sepia ?? this.sepia,
      keepAwake: keepAwake ?? this.keepAwake,
      dailyGoal: (dailyGoal ?? this.dailyGoal).clamp(1, 1000),
      hadithArabic: hadithArabic ?? this.hadithArabic,
      hadithLanguage: hadithLanguage != null ? hadithLanguage() : this.hadithLanguage,
    );
  }

  Map<String, Object?> toJson() => {
        'translation': translation,
        'showTranslation': showTranslation,
        'showTranslit': showTranslit,
        'arabicSize': arabicSize,
        'textSize': textSize,
        'quranFont': quranFont,
        'tajweed': tajweed,
        'mushafStyle': mushafStyle,
        'sepia': sepia,
        'keepAwake': keepAwake,
        'dailyGoal': dailyGoal,
        'hadithArabic': hadithArabic,
        'hadithLanguage': hadithLanguage,
      };

  factory ReaderPrefs.fromJson(Object? raw) {
    if (raw is! Map) return const ReaderPrefs();
    double num0(Object? v, double d) => v is num ? v.toDouble() : d;
    return ReaderPrefs(
      translation: raw['translation'] as String?,
      showTranslation: raw['showTranslation'] as bool? ?? true,
      showTranslit: raw['showTranslit'] as bool? ?? false,
      arabicSize: num0(raw['arabicSize'], 30).clamp(minArabic, maxArabic),
      textSize: num0(raw['textSize'], 17).clamp(minText, maxText),
      quranFont: raw['quranFont'] as String? ?? 'amiri',
      tajweed: raw['tajweed'] as bool? ?? false,
      mushafStyle: raw['mushafStyle'] as bool? ?? false,
      sepia: raw['sepia'] as bool? ?? false,
      keepAwake: raw['keepAwake'] as bool? ?? true,
      dailyGoal: ((raw['dailyGoal'] as num?)?.toInt() ?? 10).clamp(1, 1000),
      hadithArabic: raw['hadithArabic'] as bool? ?? true,
      hadithLanguage: switch (raw['hadithLanguage']) {
        final String l when const {'eng', 'rus', 'tur'}.contains(l) => l,
        _ => null,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderPrefs &&
      other.translation == translation &&
      other.showTranslation == showTranslation &&
      other.showTranslit == showTranslit &&
      other.arabicSize == arabicSize &&
      other.textSize == textSize &&
      other.quranFont == quranFont &&
      other.tajweed == tajweed &&
      other.mushafStyle == mushafStyle &&
      other.sepia == sepia &&
      other.keepAwake == keepAwake &&
      other.dailyGoal == dailyGoal &&
      other.hadithArabic == hadithArabic &&
      other.hadithLanguage == hadithLanguage;

  @override
  int get hashCode => Object.hash(translation, showTranslation, showTranslit, arabicSize, textSize, quranFont,
      tajweed, mushafStyle, sepia, keepAwake, dailyGoal, hadithArabic, hadithLanguage);
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
    this.reader = const ReaderPrefs(),
    this.quranLastRead,
    this.khatmPlan,
    this.quranReminder = false,
    this.zakat = const {},
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
  final ReaderPrefs reader;

  /// Global ayah index (0…6235) where the user stopped reading.
  final int? quranLastRead;
  final KhatmPlan? khatmPlan;

  /// Daily reminder after Isha to read the day's Quran portion.
  final bool quranReminder;

  /// Last values entered in the zakat calculator (minor units / grams).
  final Map<String, num> zakat;

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
    ReaderPrefs? reader,
    int? Function()? quranLastRead,
    KhatmPlan? Function()? khatmPlan,
    bool? quranReminder,
    Map<String, num>? zakat,
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
      reader: reader ?? this.reader,
      quranLastRead: quranLastRead != null ? quranLastRead() : this.quranLastRead,
      khatmPlan: khatmPlan != null ? khatmPlan() : this.khatmPlan,
      quranReminder: quranReminder ?? this.quranReminder,
      zakat: zakat ?? this.zakat,
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
        'reader': reader.toJson(),
        'quranLastRead': quranLastRead,
        'khatmPlan': khatmPlan?.toJson(),
        'quranReminder': quranReminder,
        'zakat': zakat,
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
      reader: ReaderPrefs.fromJson(j['reader']),
      quranLastRead: switch (j['quranLastRead']) {
        final num n when n >= 0 && n < 6236 => n.toInt(),
        _ => null,
      },
      khatmPlan: KhatmPlan.fromJson(j['khatmPlan']),
      quranReminder: j['quranReminder'] as bool? ?? false,
      zakat: {
        if (j['zakat'] case final Map<Object?, Object?> z)
          for (final e in z.entries)
            if (e.key is String && e.value is num) e.key as String: e.value as num,
      },
    );
  }
}
