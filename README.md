# Waqt — your day around the five prayers

Waqt is a free Muslim "super app" for iOS and Android, built in Flutter. It plans the whole
day around the five daily prayers. It has **no account, no ads, no analytics and no network
calls**: everything, including the Quran and hadith, is bundled and works offline.

Built first for Central Asia (Turkmen, Turkish, Russian and English UI), and useful for
anyone who wants a calm planner, habit tracker and spending log.

## Features

**Prayer**
- Offline prayer times (12 calculation methods, Hanafi/standard Asr, per-prayer mosque offsets)
- Next-prayer hero with the day's arc, one-tap marking (on time, congregation, late, missed, excused)
- Qada (missed prayer) tracker, period mode, streaks and monthly consistency
- Adhan or standard-sound alerts, "remind me in 15 min", and a test-alert check
- Monthly timetable you can share, a qibla compass and a tasbih counter

**Quran**
- Uthmani text (Amiri Quran or Scheherazade), transliteration and 8 translations: English,
  Russian, Turkish, Uzbek, Kazakh, Kyrgyz, Tajik and Azerbaijani
- Translation view and right-to-left Mushaf page view (604 Madani pages)
- Continue where you stopped, bookmarks with notes, and search by surah, `2:255` or any words
- Daily goal ring and reading streak; ayahs count as read once you've stayed on them a moment
- **Khatm planner**: finish in 7–365 days. What's left is re-spread over the remaining days,
  so a missed day never ruins the plan.
- **Memorize**: spaced review (1-3-7-14-30-90 days) with a memorize mode that hides the Arabic
- Ayah of the day and beautiful share cards

**Library**
- Hadith: Sahih al-Bukhari, Sahih Muslim, 40 Nawawi and 40 Qudsi, in Arabic, English,
  Russian and Turkish, with search, bookmarks and a hadith of the day
- Duas for every moment, the 99 Names of Allah with a practice quiz, and step-by-step guides
  (Islam basics, wudu, salah, fasting, zakat…)
- Morning and evening adhkar reader

**Your day**
- Tasks grouped by prayer window, daily expenses with sadaqa, and custom habits with streaks
- Hijri calendar with Islamic events, fasting log and Ramadan mode (suhoor/iftar/taraweeh)
- Zakat calculator (gold or silver nisab; you enter today's local metal prices)
- Home-screen widgets (iOS WidgetKit, Android Glance)
- Backup & restore to a single file you keep, since there's no cloud

**Design**: an "Emerald & brass" design system set in Inter and Literata, a floating liquid-glass
tab bar on iOS, Material 3 on Android, dark mode, and reduced-motion support.

## Development

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift codegen
dart run tool/gen_arb.dart && flutter gen-l10n              # strings (edit tool/*.dart, not .arb)
flutter analyze && flutter test
WAQT_SCREENSHOTS=1 flutter test test/screenshots            # renders build/screenshots/*.png
dart run tool/build_content.dart                            # re-download Quran & hadith data
```

Architecture, design tokens, data model and decisions are documented in [CLAUDE.md](CLAUDE.md).

## Content sources

- Quran text and translations: Tanzil, King Fahd Complex and quranenc, via
  [fawazahmed0/quran-api](https://github.com/fawazahmed0/quran-api)
- Hadith: sunnah.com editions via [fawazahmed0/hadith-api](https://github.com/fawazahmed0/hadith-api)
- Fonts (SIL OFL): Inter, Literata, Amiri, Amiri Quran, Scheherazade New. Licenses are in
  `assets/fonts/`.

The duas, Names and guides were compiled from classical sources (Ḥiṣn al-Muslim, the Quran,
the Sahihayn) and should be checked by a qualified person before release (see CLAUDE.md, "Manual
TODOs").
