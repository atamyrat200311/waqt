# Waqt — project notes for Claude sessions

Read this first. It is the single source of truth for decisions already made, so later
sessions do not need to re-read `design/`.

## Product

"Waqt" is a free Flutter app (iOS + Android) for Muslims that organizes the whole day
around the five daily prayers: prayer times, prayer tracking, qada (missed prayer)
tracking, daily expenses, to-do tasks, morning/evening adhkar, Hijri calendar, Ramadan
mode, qibla, tasbih and home-screen widgets.

Hard rules: **no backend, no account, no ads, no analytics, no network calls.** All data
stays on the device. Fonts are bundled (no google_fonts package).

Main audience: Central Asia (Turkmenistan first). Defaults: Muslim World League + Hanafi
Asr, currency TMT, location Ashgabat until the user sets one.

## Stack (do not substitute without asking)

| Concern | Package |
|---|---|
| State | flutter_riverpod 3 (plain providers, **no codegen**) |
| DB | drift + drift_flutter (codegen via build_runner) |
| Settings | shared_preferences |
| Navigation | go_router (StatefulShellRoute, 3 tabs) |
| Prayer times | adhan (offline) |
| Hijri | hijri (Umm al-Qura) + user adjustment −2…+2 |
| Location | geolocator + bundled city list (`assets/data/cities.json`) |
| Compass | flutter_compass |
| Notifications | flutter_local_notifications + timezone + flutter_timezone |
| Background | workmanager |
| Widgets | home_widget + WidgetKit (Swift) + Glance (Kotlin) |
| Animation | flutter_animate |
| Charts | fl_chart |
| i18n | flutter_localizations + intl, ARB: en (template), tk, tr, ru |
| Extra (added) | `path_drawing` (renders the design's Lucide-style SVG icon paths), `path_provider` |

Org / ids: org `tm.ofis`, Dart package `waqt`, bundle id / applicationId `tm.ofis.waqt`.

Strings: **edit `tool/gen_arb.dart`, not the .arb files** (they are generated):
`dart run tool/gen_arb.dart && flutter gen-l10n`. Prefix a translation with `?` to flag it REVIEW.
Turkmen has no Flutter Material/Cupertino localizations → `app.dart` falls back to English for those.
Text scale is clamped to 0.85–1.3× in `app.dart`.

Commands:
```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift codegen
flutter gen-l10n                                           # also runs on build
flutter analyze && flutter test
```

## Folder structure

```
lib/
  main.dart, app.dart
  core/
    theme/      app_colors.dart (WaqtColors ThemeExtension, light/dark), app_typography.dart,
                app_theme.dart, dimens.dart (spacing/radius)
    router/     app_router.dart (shell + routes; Quran tab slot marked TODO)
    l10n/       *.arb + generated app_localizations*.dart, l10n_ext.dart (names of prayers, months…)
    platform/   adaptive.dart (isCupertino, adaptive sheet, tab bar vs NavigationBar, FAB vs "+")
    utils/      dates.dart (DayKey = yyyy-MM-dd), money.dart, durations.dart
  data/
    db/         app_database.dart (+ .g.dart), tables.dart, enums.dart
    repositories/ prayer_log_repository.dart, qada_repository.dart, expense_repository.dart, …
    settings/   app_settings.dart (model), settings_repository.dart (shared_preferences)
  features/<feature>/   domain/ (pure Dart, tested) · application/ (providers) · presentation/ (widgets)
  shared/widgets/       WaqtCard, Pill buttons, chips, sheet scaffold, section headers, WaqtIcon …
assets/
  fonts/      Fraunces-Variable.ttf, PlusJakartaSans-Variable.ttf, Amiri-Regular/Bold.ttf (+ OFL)
  adhkar/adhkar.json
  data/cities.json
  sounds/     (source of the adhan placeholder; real copies live in android/app/src/main/res/raw and ios/Runner)
```

## Design tokens (from `design/Waqt Style.dc.html` + artboards)

Theme "Emerald & brass". Artboards are 390×844.

| Token (css var) | Light | Dark | Use |
|---|---|---|---|
| bg | #F7F4EE | #0A1310 | page background |
| card | #FFFFFF | #121D18 | cards, sheets |
| ink | #14201B | #F0ECE3 | primary text |
| mu (muted) | #56635C | #A3AFA8 | secondary text |
| ln (hairline) | #E7E1D5 | #22302A | borders, dividers, inactive |
| hero | #0F4C3A | #143F32 | hero card bg (next prayer, tasbih, Me streak) |
| hink | #F7F4EE | #F0ECE3 | text on hero |
| hmu | hink @ 74% | hink @ 74% | muted text on hero |
| mint | #DFECE4 | #173328 | soft emerald fill (Up next, Made up buttons) |
| mink | #0F4C3A | #6CC9A1 | text/icon on mint |
| br (brass) | #B88A3E | #E0BD78 | checks, sun, streaks, ring progress — *only* these |
| bri (brass text) | #8A6324 | #E0BD78 | text on brass-soft, "Add to qada" button bg |
| brs (soft brass) | #F4EAD6 | #2A2418 | qada banner, tips, white-day cells |
| onbr | #FFFFFF | #0A1310 | text on bri |
| pri (primary) | #0F4C3A | #6CC9A1 | primary buttons, today cell |
| onp | #FFFFFF | #0A1310 | text on pri |
| acc (accent) | #0F4C3A | #6CC9A1 | links, icons, active tab |
| fill | #F0ECE4 (Android #EEEAE2) | #17231E | keypad keys, segmented bg, chips |
| dim | rgba(20,32,27,.44) | rgba(0,0,0,.6) | sheet scrim |

Spending palette (Me): Groceries=pri, Food #4F8A71, Bills #8FB8A2, Transport #C4D8CC,
Other=ln, Sadaqa=br.

Typography (tabular numbers everywhere):
- Hero number: Fraunces 66, wght 350, opsz 144, letter-spacing −0.035em, line-height 1 ("1h 12m", unit letters 30).
- Title: Fraunces 34, −0.015em (screen titles, date on Home iOS). Android Home date: Fraunces 24.
- Section: Fraunces 24 ("Your day"), Fraunces 22 ("Upcoming").
- Big stats: Fraunces 34 (tiles), 72 (streak), 112 wght 300 (qada total), 80 wght 350 (expense amount).
- Item: Plus Jakarta Sans 17/600. Body: Jakarta 15 muted. Small: 13 muted. Caption 12.
- Kicker: Jakarta 12/700 uppercase, letter-spacing .09em (hero) / 11px .08em (cards).
- Arabic: Amiri 42 line-height 1.5 (short), 28 line-height 1.9 (long > 60 chars), RTL, centered.
- Fraunces is variable: always set `opsz` (= font size, clamped 9–144) and `wght` variations.

Shape & spacing:
- Cards radius 24 (Android 28), hero card 28, sheet top radius 28, sheet grabber 36×5 (Android 32×4).
- Chips/pills radius 999; big buttons 56 tall radius 18; small pill buttons 44 tall.
- Screen side padding 16 (cards) / 20 (titles); card padding 16–20; gap between cards 10–12.
- Icon tiles 44×44 radius 14 (40×40 r13 in smaller rows).
- Icons: 24px grid, 2px stroke, round caps/joins (Lucide shapes). Implemented in `shared/widgets/waqt_icon.dart`.
- Shadows only on sheets and FAB. Hairline borders (1px ln) on cards.
- States differ by **shape**, not just color: done = filled brass circle + check; current = brass ring + dot;
  upcoming = dashed circle at 74% opacity.
- Touch targets ≥ 44.

Platform differences (from design notes):
- iOS: large-title header, "+" circle button top-right, tab bar (84 tall, bg = page bg, top hairline,
  icon 25, label 11, active = acc/700), back link "‹ Today" in acc 17/500, sheets with 36×5 grabber.
- Android: top app bar (Home: date Fraunces 24 + Hijri line, location chip radius 8), extended FAB
  "+ Add" (mint bg, 56 tall, radius 16, shadow) at bottom-right above nav, M3 NavigationBar 80 tall
  bg=fill with 64×32 mint pill indicator, labels 12, all cards radius 28, M3 sheet 32×4 handle.
  Qada: "Add older missed prayers" becomes the FAB. Tasks: add field docks above nav bar.

Screens (design artboards): Home (iOS light/dark, Android, Ramadan), Mark-a-prayer sheet, Qada,
Add-expense sheet, Tasks, Adhkar reader, Tools hub (Qibla card + Tasbih card + tiles), Hijri
calendar, Me, Settings, Widgets (iOS small/medium/lock-screen, Android 4×2 with action).

Motion (design keyframes): check pop 0.45–0.5s `cubic-bezier(.3,1.4,.5,1)` scale .3→1.18→1; check
draw 0.4s; sun glow pulse 3.4s; qada count bump .3s; tap ripple ring .5s; tasbih/adhkar ring
progress .2–.25s. App rule: keep UI transitions 150–300 ms, honour reduced motion
(`MediaQuery.disableAnimations`).

## Data model (drift, schemaVersion 1)

Dates are stored as **`yyyy-MM-dd` text** (`DayKey`) — see conflicts.

- `prayer_logs`: id, date, prayer (fajr…isha), status (onTime, congregation, late, missed, excused), markedAt. UNIQUE(date, prayer).
- `qada_counts`: prayer PK, remaining ≥ 0.
- `qada_events`: id, prayer, delta (+1/−1), source (missedMarked, manualAdd, madeUp), createdAt.
- `expenses`: id, amountMinor INTEGER, currency (default TMT), category (groceries, transport, food, bills, sadaqa, other), note?, occurredAt.
- `tasks`: id, title, date, window (beforeFajr, afterFajr, beforeDhuhr, afterDhuhr, afterAsr, afterMaghrib, afterIsha, anytime), done, doneAt?, sortOrder.
- `adhkar_progress`: date, setId (morning/evening), itemId, count. UNIQUE(date, setId, itemId).
- `fasts`: date PK, type (ramadan, monThu, whiteDays, other), status (fasted, missed, excused).
- `tasbih_sessions`: id, phrase, count, goal, createdAt.

Settings (shared_preferences, `SettingsRepository`): calculation method, madhab, per-prayer
offsets, per-prayer alert (adhan/silent/off), location (lat, lng, name, tz), language,
currency, hijri adjustment, ramadan mode (auto/on/off), period mode, theme, onboarding done,
adhkar reminders, suhoor/iftar reminders.

## Behaviour notes / decisions

- Prayer windows: Fajr→Sunrise, Dhuhr→Asr, Asr→Maghrib, Maghrib→Isha, Isha→next Fajr. Between
  sunrise and Dhuhr there is no current window.
- Times are computed in UTC with `PrayerTimes.utc` and converted to the location's IANA tz with
  the `timezone` package, so a manual city in another zone shows that city's local times.
- Unmarked prayers are never auto-added to qada. A gentle card on Home lists yesterday's unmarked prayers.
- "Missed" in the mark sheet asks for confirmation before adding to qada (design).
- Period mode: prayer alerts paused, passed prayers auto-marked `excused` on app open,
  excused days neither break nor extend streaks, never create qada.
- Streak = consecutive days where every prayer is prayed (onTime/congregation/late) or excused
  and at least one is prayed; all-excused days are skipped; today only counts once complete.
- Notifications: max 60 pending (iOS limit 64, 4 kept free for "remind me in 15 min"), ≤ 7 days.

## Conflicts between design and prompt (resolution)

1. **Date format**: prompt says `dd-mm-yyyy`; stored as ISO `yyyy-MM-dd` so range queries/sorting work. Display format is localized.
2. **Alert "Silent"**: design label is "Silent"; prompt says "default sound (silent-style)". Behaviour: `silent` = notification with the system default sound (no adhan). Easy to flip in `notification_service.dart`.
3. **Mosque offset**: design shows one "Match my mosque" stepper; prompt wants per-prayer offsets. The stepper shifts all five; tapping the row opens per-prayer steppers.
4. **"+" button**: design wires the iOS "+" / Android "+ Add" to the Add-expense sheet. Kept.
5. **Task windows**: design shows 5 windows; prompt has 8. All 8 exist; only non-empty groups render.
6. **Adhkar count**: design shows "of 12"; real count = verified items in `adhkar.json`.
7. Sub-screens keep the tab bar (design): Qada/Tasks under Today, Calendar under Tools, Settings under Me. Adhkar reader is full-screen.

## Manual TODOs for the owner

- [ ] Verify every adhkar item in `assets/adhkar/adhkar.json` against Hisn al-Muslim (Arabic, counts, references). All tk/tr/ru translations are flagged REVIEW.
- [ ] Review tk/tr/ru ARB strings marked `"REVIEW"` in their `@` descriptions.
- [ ] Replace placeholder adhan audio (see "Adhan sound" below).
- [ ] iOS: install Xcode + CocoaPods (this machine had neither, so iOS was not built here).

## Phase checklist

- [x] 1. Project setup, theme, fonts, l10n, router with adaptive 3-tab shell (APK builds; iOS config written, not built — no Xcode here)
- [ ] 2. Database, repositories, settings service + tests
- [ ] 3. Prayer engine, location, notifications, workmanager + tests
- [ ] 4. Home screen (hero, day arc, chips, mark sheet, timeline)
- [ ] 5. Qada, Expenses, Tasks
- [ ] 6. Adhkar, Hijri calendar, Ramadan mode, Qibla, Tasbih, Tools hub
- [ ] 7. Me (stats), Settings, Onboarding
- [ ] 8. Widgets (iOS + Android) + polish
