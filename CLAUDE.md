# Waqt — project notes for Claude sessions

Read this first. It is the single source of truth for decisions already made, so later
sessions do not need to re-read `design/`.

## Product

"Waqt" is a free Flutter "super app" (iOS + Android) for Muslims that organizes the whole
day around the five daily prayers: prayer times, prayer tracking, qada (missed prayer)
tracking, daily expenses, to-do tasks, habits, morning/evening adhkar, **Quran reader**
(translations, Mushaf pages, khatm planner, memorization), **hadith collections**, duas,
99 Names, step-by-step guides, zakat calculator, monthly timetable, Hijri calendar,
Ramadan mode, qibla, tasbih, share cards, local backup and home-screen widgets.

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
| Extra (super app) | `share_plus` (share cards / backup file), `scrollable_positioned_list` (Quran reader jump-to-ayah), `wakelock_plus` (keep screen on while reading), `file_picker` (restore backup) |

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

Typography (tabular numbers everywhere). Phase 9: "Fraunces" below now means **Literata** and
"Jakarta" means **Inter** (same sizes and roles; see app_typography.dart).
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

## Data model (drift, schemaVersion 2)

Dates are stored as **`yyyy-MM-dd` text** (`DayKey`) — see conflicts.

- `prayer_logs`: id, date, prayer (fajr…isha), status (onTime, congregation, late, missed, excused), markedAt. UNIQUE(date, prayer).
- `qada_counts`: prayer PK, remaining ≥ 0.
- `qada_events`: id, prayer, delta (+1/−1), source (missedMarked, manualAdd, madeUp), createdAt.
- `expenses`: id, amountMinor INTEGER, currency (default TMT), category (groceries, transport, food, bills, sadaqa, other), customCategory?, note?, occurredAt. User-defined category names are kept in settings and each expense stores its selected custom name.
- `tasks`: id, title, date, window (beforeFajr, afterFajr, beforeDhuhr, afterDhuhr, afterAsr, afterMaghrib, afterIsha, anytime), done, doneAt?, sortOrder.
- `adhkar_progress`: date, setId (morning/evening), itemId, count. UNIQUE(date, setId, itemId).
- `fasts`: date PK, type (ramadan, monThu, whiteDays, other), status (fasted, missed, excused).
- `tasbih_sessions`: id, phrase, count, goal, createdAt.
- v2: `bookmarks` (kind ayah/hadith/dua/name, ref, note?, createdAt; UNIQUE(kind, ref)),
  `quran_reads` (date, ayah global index; PK both), `hifz_items` (surah PK, status, step,
  nextReview), `habits` (id, title, icon key, archived, sortOrder), `habit_logs` (habitId, date).
  Bookmark refs: ayah `2:255`, hadith `bukhari:1`, dua `<id>`, name `<1…99>`.

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
- [x] iOS widget target `WaqtWidget` (bundle id `tm.ofis.waqt.WaqtWidget`, iOS 15+) added to
      Runner.xcodeproj by `tool/ios/add_widget_target.rb` (idempotent; run with
      `GEM_HOME=$(brew --prefix)/Cellar/cocoapods/<ver>/libexec ruby tool/ios/add_widget_target.rb ios/Runner.xcodeproj`).
      Embedded via "Embed Foundation Extensions" placed before Flutter's "Thin Binary" phase.
      Uses `Flutter/Generated.xcconfig` as base config so its version matches the app.
- [ ] First device build: open Runner.xcworkspace once, select the WaqtWidget target ▸ Signing &
      Capabilities and let automatic signing register `tm.ofis.waqt.WaqtWidget` + App Group
      `group.tm.ofis.waqt` (team QGWL53YZV9) for both Runner and WaqtWidget.
- [ ] Android: run `flutter build apk` once — Glance/Compose Gradle changes and the widget Kotlin
      were written without network access to Google's Maven (dl.google.com blocked here).
- [ ] Verify `assets/library/duas.json`, `names.json`, `guides.json` (Arabic, sources, translations;
      tk strings prefixed "?" in the JSON are flagged for review) and the Turkmen surah meanings in
      `lib/features/quran/domain/surah_names.dart`.
- [ ] Review the tk/tr/ru hadith chapter names in `lib/features/hadith/domain/hadith_section_names.dart`.
- [ ] Turkmenistan prayer times come from the official table (`tm_wagt_default.json` → `tool/build_tm_times.dart`
      → `lib/features/prayer/domain/tm_times_data.dart`); regenerate when a new table is published.
- [ ] Content agent's verification list (duas/guides): sources from Abu Dawud/Tirmidhi/Ibn Majah/
      Nasa'i were written from memory of Ḥiṣn al-Muslim (enter/leave home, toilet, dressing, after
      eating, istiftah, between prostrations, debt, healing ×7, protection ×3, Laylat al-Qadr,
      farewell, newlyweds, iftar…); `enter_home` (Abu Dawud 5096) is graded weak by some;
      `enter_town` source numbers; `new_moon` wording (Tirmidhi 3451); Sayyid al-Istighfar follows
      Bukhari 6306 while `assets/adhkar/adhkar.json` m07 omits "laka" (Ḥiṣn wording) — align one way;
      Al-Ahad at no. 67 in names.json follows the popular list; Hanafi fiqh points in the guides
      (wudu, ghusl, Ramadan intention, silver nisab, fidya) need an imam's check. Quranic and
      Bukhari/Muslim texts were cross-checked against the bundled data.
- [ ] Hadith numbering in dua `source` fields uses sunnah.com numbering; the bundled hadith files
      number differently (e.g. istikhara Bukhari 1162 vs 1166) — don't deep-link by number.
- [ ] Android: `flutter build apk` after the super-app release (new plugins: share_plus, wakelock_plus,
      file_picker) — dl.google.com was still blocked in this environment.

## Adhan sound

`assets/sounds/adhan.wav` is a **placeholder** (a short synthesized chime, not an adhan).
Copies: `android/app/src/main/res/raw/adhan.wav` (kept in release by `res/raw/keep.xml`) and
`ios/Runner/adhan.wav` (in the Runner target's Resources phase). To replace: drop a real
recording (≤ 30 s for iOS, wav/caf) into both places with the same name. Android channel
sounds are fixed once a channel exists → bump the channel id in `notification_service.dart`
(`Channels.adhan`, `…v1` → `…v2`) when the file changes.

## Phase 3 notes

- `features/prayer/application/prayer_providers.dart`: `prayerEngineProvider`, `prayerNowProvider`
  (minute tick), `todayKeyProvider`, `ensureTimeZones()` / `locationFor(id)`.
- `features/notifications/domain/notification_plan.dart`: pure planner (60 max, 7 days, ids
  `dayIndex*10+slot`, reminders ≥ 900000 survive reschedules, period mode pauses prayers/Ramadan
  alerts, iftar replaces the Maghrib alert in Ramadan). Payloads `mark:<prayer>:<day>`, `adhkar:<set>`, `today`.
- `notification_service.dart` talks to the plugin; `notification_scheduler.dart` reschedules on
  relevant settings changes + app resume; `notification_taps.dart` routes taps;
  `background.dart` = workmanager (Android periodic 6 h, iOS BGTask registered in AppDelegate).
- `period_mode_sync.dart`: auto-excuses passed prayers (≤ 14 days back) while period mode is on.
- Widget tests: use `settingsOverrides()` from `test/helpers/test_app.dart` (frozen clock
  `testNow` = 4 Oct 2026 16:00 Ashgabat, in-memory DB, fake notifications).
- This environment can't reach dl.google.com, so Android builds were not run after phase 1.

## Phase 4–5 notes

- Shared kit: `shared/widgets/` → `waqt_card.dart` (WaqtCard, WaqtGroup), `buttons.dart` (PillButton,
  BigButton, CircleIconButton), `status_marks.dart` (Done/Current/Upcoming/Missed/Excused marks,
  `popCurve`), `layout.dart` (Kicker, IconTile, SectionTitle, SubScreen = iOS back link + large
  title / Android app bar), `dashed_border.dart`. `MotionSize` (adaptive.dart) instead of raw
  AnimatedSize (zero-duration AnimatedSize asserts under reduce motion).
- Today: `features/today/domain/today_logic.dart` (pure: chip states, adhkar "up next", hero target
  incl. Ramadan iftar, countdown rounding, task windows) + `application/today_providers.dart`.
- Fonts: superseded in phase 9 (Inter + Literata cover Cyrillic; Amiri is the fallback for ﷺ).
- `assets/adhkar/adhkar.json`: 12 morning + 12 evening items (`id, ar, translit, text{en,tk,tr,ru},
  count, source`). Written from memory of Ḥiṣn al-Muslim → owner must verify (see TODOs).
- Screenshots for visual review: `WAQT_SCREENSHOTS=1 flutter test test/screenshots` → `build/screenshots/`.
  Widget tests must enable reduce motion (looping sun glow / caret never settle).

## Phase 6 notes

- Routes: `/adhkar/:set` (root navigator, full screen), `/tools/calendar`, `/tools/qibla`, `/tools/ramadan`.
- Qibla: `compassProvider` (autoDispose → sensor stops off-screen). flutter_compass heading is
  magnetic on Android; no declination correction (would need a geomagnetic model) → may be off by a
  few degrees. No sensor → dial stays north-up with the bearing text.
- Tasbih: pure `TasbihState` (preset 33·33·34 or custom phrase/goal); sessions saved on complete/reset.
- Calendar: tap a day → fast sheet (type auto: Ramadan > white days > Mon/Thu > voluntary).
- Ramadan screen (no artboard — built from the style guide): mode segmented, today's fast, month grid, reminders.
- Shared: `segmented.dart`, `rows.dart` (WaqtRow, ToggleRow with brand-coloured adaptive switch),
  `progress_ring.dart` (ProgressRing, TapRipple).

## Phase 7 notes

- Stats (pure, `features/me/domain/stats.dart`): streak per CLAUDE rules (today pending never breaks;
  all-excused days skipped; empty days break), best run, 14-day bar, per-prayer consistency for the
  month (excused + not-yet-started prayers excluded), on-time share, adhkar streak. Weakest prayer
  gets the brass bar + its tip.
- Settings: location, method, Asr, mosque stepper (tap row → per-prayer sheet), Hijri ±2, alerts
  per prayer + permission/exact-alarm banners, adhkar reminders, language, currency, Ramadan mode,
  period mode, appearance, widgets help, privacy footer. `appVersion` const in settings_screen.dart.
- `/location` is a root route (opened from Home's chip and from Settings). City search is offline;
  GPS name = nearest bundled city; manual coordinates use the device time zone.
- Onboarding (no artboard): language → location (+ region method preset, "Advanced" pickers) →
  notifications → Android battery (opens app settings; no plugin for the exemption dialog) → Start.

## Widgets (phase 8)

- Dart builds a 7-day JSON payload (`features/widgets/domain/widget_payload.dart`, key `waqt_widget`)
  → `home_widget` shared storage (App Group `group.tm.ofis.waqt` on iOS). Native code derives
  the next prayer or sunrise boundary / open window / countdown from it, so widgets stay right
  for a week offline.
- Pushed by `widgetSyncProvider` (engine, today's marks, language changes), by the workmanager
  refresh (`runBackgroundRefresh` → `refreshWidgetsFromDisk`) and after widget actions.
- Android (Glance): `android/app/src/main/kotlin/tm/ofis/waqt/widget/` (`WaqtWidgetReceiver`,
  `WidgetData` logic), `res/xml/waqt_widget_info.xml` (4×2). "Mark as prayed" → broadcast →
  Dart `widgetInteraction` (background isolate) marks on time and refreshes. Refreshes are
  scheduled at prayer times + every 15 min for 6 h (`HomeWidget.scheduleWidgetUpdates`).
- iOS (WidgetKit): `ios/WaqtWidget/WaqtWidget.swift` — small (hero), medium (6 columns including sunrise),
  large (live countdown + 6-row timetable), lock-screen rectangular; minute entries for 3 h + state changes. Taps open
  `waqt://today?homeWidget[&mark=…&day=…]` (URL scheme `waqt` in Runner/Info.plist).
- Drift DB opens with `shareAcrossIsolates: true` so background writes reach the app's streams.
- `core/platform/system_settings.dart` uses MainActivity's `waqt/system` channel (battery list,
  notification settings).

## Super-app release notes (phase 9+)

Fonts: **Inter** (UI, `WaqtType.sans`, opsz 14–32) + **Literata** (display, `WaqtType.serif`,
opsz 7–72) replaced Plus Jakarta Sans + Fraunces for readability; both cover Turkmen,
Turkish and Cyrillic (the old "Russian uses system font" note no longer applies).
Arabic: Amiri (duas, ﷺ fallback), **Amiri Quran** (`WaqtType.quran`, default Quran face) and
Scheherazade New (plain Naskh option).

Navigation: 5 tabs — Today · Quran · Library · Tools · Me (`shellTabs` in app_shell.dart).
iOS uses `GlassTabBar` (floating capsule, sliding lens) with `extendBody`, so screens must
end scroll views with `BottomSpace()` (adds MediaQuery bottom padding). Android keeps the
M3 NavigationBar. `Glass` (shared/widgets/glass.dart) = blur + tint + sheen + rim; `solid:
true` for Android surfaces. `TabHeader` = tab-root large title with round actions.

Content (offline, generated by `dart run tool/build_content.dart [quran|hadith]`, sources:
fawazahmed0 quran-api / hadith-api on GitHub, Unlicense, originally Tanzil / KFGQPC /
quranenc / sunnah.com):
- `assets/quran/ar.json.gz` (Uthmani Hafs), `translit.json.gz`, translations `en_sahih`,
  `ru_kuliev`, `tr_diyanet`, `uz_mansour`, `kk_altai`, `ky_hakimov`, `tg_arifi`,
  `az_musayev` (`QuranTranslations`; tk users default to Russian — no Turkmen translation exists).
- `lib/features/quran/domain/quran_index_data.dart` (generated): ayah counts, surah/juz/604
  page/240 rubʿ starts, sajdas. Ayahs are addressed by **global index 0…6235** everywhere.
- `assets/hadith/<book>_<ara|eng|rus|tur>.json.gz` for nawawi, qudsi, bukhari, muslim
  (`{s: [[id,name,first,last]], h: [[number,text,grade,section]]}`). Section names are English only.
- `assets/library/duas.json`, `names.json`, `guides.json` — authored content (see TODOs).
- Loaded with `loadGzJson` (core/utils/assets.dart; big files decode in an isolate).

Quran (`features/quran`): `quran.dart` (AyahRef, lookups, search normalization, KhatmPlan /
khatmProgress — remaining ayahs re-spread over remaining days, hifz ladder 1-3-7-14-30-90,
readingStreak, daily ayah pool). Reader `/read?i=<index>[&mode=page][&hifz=<surah>]` is a
root route: list view = ScrollablePositionedList over 6236 ayahs + 114 headers
(`itemInfo`/`itemOfAyah`), page view = RTL PageView over 604 pages. `ReadTracker` records an
ayah after 2 one-second ticks on screen (page mode: whole page after 4 s); flushes every 5 ticks.
Last read is saved in settings (`quranLastRead`), reader prefs in `AppSettings.reader`
(`ReaderPrefs`), khatm in `khatmPlan`. Quran reminder: notification slot 9 (Isha + 45 min).

Library (`features/library`, `features/hadith`): hub, hadith books/sections/search, duas
(category chips, search, favourites), 99 Names grid + quiz, guides timeline, saved items.
Hadith of the day rotates Nawawi 40 + Qudsi 40.

Tools: zakat (`features/zakat`, user-typed metal prices, inputs persisted in
`AppSettings.zakat`, "record as sadaqa" writes an expense), timetable (`/tools/timetable`,
share as text), habits (`/today/habits`, also on Today). Backup/restore:
`data/backup/backup_service.dart` (JSON of settings + all tables, single-transaction restore),
screen at `/me/settings/backup`. Settings has "Send a test alert".

Share cards: `showShareCardSheet(context, ShareCardData(...))` — 3 themes, PNG via share_plus;
texts over ~280 chars switch to a 9:16 story card; `credit` shows the translator.

Review-round decisions (multi-agent UX review, phase 10):
- Quran text: the build tool joins KFGQPC "open tanween + space + alif" splits and drops RLM
  marks (`_fixUthmani`); Arabic search uses `assets/quran/ar_search.json.gz` (Tanzil simple text,
  basmala prefixes stripped) — never the Uthmani text.
- Khatm is measured in **pages** (`ayahPageWeights`, 1/ayahs-on-page, sums to 604) and counts only
  ayahs read for the first time since the plan began (`watchFirstReadOn`). Continue = first unread.
- Last read moves only when the reader was opened at the saved position (or none saved) or after
  ≥ 3 ayahs were recorded; "Mark as where I stopped" pins it for the session.
- Read dwell ≈ 0.3 s/word (2–25 s), only below the toolbar, never hidden memorize ayahs; Mushaf
  pages 0.25 s/word (15–60 s). Single tap on an ayah does nothing (long-press / ••• for actions).
- Colors: brass only for checks/streaks/progress/sadaqa; `danger`/`dangerSoft` for delete and wrong
  answers; `onHeroAccent` for accent text on emerald; `track` for ring/bar tracks.
- `WaqtType.sans(..., tabular: true)` only for times/amounts that update in place.
- Text scale cap 1.6×; tab bars and the reader bar clamp to 1.2×, the hero to 1.25×.
- Tools = utilities (Qibla, Tasbih, Calendar, Ramadan, Zakat, Timetable). Adhkar lives in Today
  (up next) + Library; habits in Today (+ `/today/habits`).
- "Silent" alert renamed "Sound" (it plays the default sound). Turkmen dates use `tkOrdinal`.
- Surah names: `SurahInfo.translit` is localized (ru Cyrillic, tk Turkmen) via the static
  `SurahInfo.language` set in `WaqtApp.build`; `.latin` is the Latin form.
- Ramadan 30 (`features/ramadan/application/ramadan_challenge.dart`): fast, all prayers, ≥ 10 ayahs
  (or khatm portion), adhkar, sadaqa; "full days" = fast + prayers + Quran.
- Fasting qada: `FastType.qada`; owed = missed/excused Ramadan days − make-up fasts.
- Regression pass 2: onboarding starts with **language** (no Turkmen system locale); "Advanced"
  method/Asr survives a later city pick. Passed-but-unmarked prayers use `UnmarkedMark` (solid
  ring) vs dashed upcoming. Overdue khatm: `overdue`, target = original pace, "Extend by N days";
  `farBehind` shows the page gap; `dayShown` never exceeds the plan length. `isLargeText()`
  (rows.dart, > 1.3×) makes `WaqtRow` stack value/controls under the title. Expense deletes have
  undo. Hadith editions/search indexes are autoDispose with a 2-minute keep-alive (widget tests
  pump 3 minutes after unmounting so the grace timer fires).

Turkmenistan prayer times: `TmTable` (`features/prayer/domain/tm_times.dart`) — static official
table, 5 cities (Ashgabat, Balkanabat, Daşoguz, Türkmenabat, Mary) × 366 rows (leap-year order,
same day/month every year) × imsak/fajr/sunrise/dhuhr/asr/maghrib/isha in local minutes. Used by
`PrayerEngine` instead of adhan when the zone is Asia/Ashgabat and the point is inside the country
(nearest city); method/madhab don't apply (Settings shows "Official Turkmenistan timetable"),
mosque offsets still do. `PrayerDay.imsak` (= Fajr elsewhere) drives suhoor times.

Tajweed colours: `ReaderPrefs.tajweed` (reader settings toggle). `assets/quran/ar_tajweed.json.gz`
(built by `dart run tool/build_tajweed.dart` from quran.com `uthmani_tajweed`, 6236 ayahs with
`<tajweed class=…>` markup) is loaded only while the toggle is on (`QuranTexts.tajweed`);
`features/quran/domain/tajweed.dart` parses it, `presentation/tajweed_text.dart` maps rules → colours
(lightened on dark pages) and tints waqf signs. Same Amiri Quran / Scheherazade fonts as plain text.

Mushaf style: `ReaderPrefs.mushafStyle` (reader settings). Parchment palette (`ReaderPalette.of(mushaf: true)`
incl. `allah`/`waqf`/`medal*` colours); in page view `presentation/mushaf_page.dart` (`MushafLines`) draws the
Madani 15-line layout from `assets/quran/mushaf_lines.json.gz` (built by `dart run tool/build_mushaf.dart` from
quran.com `verses/by_page?mushaf=5`; `domain/mushaf.dart` parses it): one font size per page so the widest
line fits, full lines justified, short lines centred, "Allah" pink, waqf signs red, gold ayah medallions,
surah banner inserted before ayah 1. In list view only the palette + Allah/waqf colours apply. Tajweed colours
take precedence in list view and are not applied in the Mushaf page layout. Amiri Quran font (not KFGQPC).

Hadith language: chapter names are translated by `hadithSectionName()` (app language). Hadith of
the day: English = Nawawi + Qudsi, Turkish = Nawawi, Russian/Turkmen = `assets/hadith/daily_rus.json.gz`
(448 short Bukhari hadiths, built by `tool/build_daily_hadith.dart` from the bundled editions).

Screenshots: `WAQT_SCREENSHOTS=1 flutter test test/screenshots` (now incl. `full_*` long
pages and a `review_*` set in tk/ru). `shoot(..., height:, preload:)` helpers.

## Phase checklist

- [x] 1. Project setup, theme, fonts, l10n, router with adaptive 3-tab shell (APK builds; iOS config written, not built — no Xcode here)
- [x] 2. Database, repositories, settings service + tests
- [x] 3. Prayer engine, location, notifications, workmanager + tests
- [x] 4. Home screen (hero, day arc, chips, mark sheet, timeline)
- [x] 5. Qada, Expenses, Tasks
- [x] 6. Adhkar, Hijri calendar, Ramadan mode, Qibla, Tasbih, Tools hub
- [x] 7. Me (stats), Settings, Onboarding
- [x] 8. Widgets (iOS + Android) + polish — code written; Android/iOS builds not run here (see TODOs)
- [x] 9. Super app: fonts, 5 tabs + liquid glass, Quran, hadith, library, zakat, timetable, habits, backup
- [x] 10. Multi-agent UX review (everyday user, Quran reader, designer) and fixes; Ramadan 30; fasting qada
