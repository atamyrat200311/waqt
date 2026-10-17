import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/repositories/quran_repository.dart';
import 'package:waqt/features/quran/application/read_tracker.dart';
import 'package:waqt/features/quran/domain/quran.dart';
import 'package:waqt/features/quran/domain/quran_index_data.dart';
import 'package:waqt/features/quran/domain/translations.dart';
import 'package:waqt/features/quran/presentation/quran_reader.dart';

import 'helpers/test_db.dart';

void main() {
  group('index', () {
    test('ayah counts add up to 6236', () {
      expect(surahAyahCounts.fold<int>(0, (a, b) => a + b), totalAyahs);
      expect(surahAyahCounts[1], 286);
      expect(pageStarts.length, totalPages);
      expect(juzStarts.length, 30);
      expect(rubStarts.length, 240);
    });

    test('AyahRef round-trips through global indexes', () {
      expect(const AyahRef(1, 1).index, 0);
      expect(const AyahRef(2, 255).index, 261);
      expect(AyahRef.fromIndex(261), const AyahRef(2, 255));
      expect(AyahRef.fromIndex(totalAyahs - 1), const AyahRef(114, 6));
      for (final i in [0, 6, 7, 293, 1000, 4000, 6235]) {
        expect(AyahRef.fromIndex(i).index, i);
      }
    });

    test('parses references and rejects out-of-range ones', () {
      expect(AyahRef.tryParse('2:255'), const AyahRef(2, 255));
      expect(AyahRef.tryParse(' 36 . 1 '), const AyahRef(36, 1));
      expect(AyahRef.tryParse('1:8'), isNull);
      expect(AyahRef.tryParse('115:1'), isNull);
      expect(AyahRef.tryParse('mercy'), isNull);
    });

    test('juz, page and sajda lookups', () {
      expect(juzOfIndex(0), 1);
      expect(juzOfIndex(const AyahRef(2, 142).index), 2);
      expect(juzOfIndex(const AyahRef(78, 1).index), 30);
      expect(pageOfIndex(0), 1);
      expect(pageOfIndex(const AyahRef(2, 1).index), 2);
      expect(pageOfIndex(totalAyahs - 1), 604);
      expect(isSajda(const AyahRef(96, 19).index), isTrue);
      expect(isSajda(0), isFalse);
      final (a, b) = pageRange(1);
      expect((a, b), (0, 6));
    });

    test('surah facts', () {
      const s = SurahInfo(9);
      expect(s.hasBasmala, isFalse);
      expect(const SurahInfo(1).hasBasmala, isFalse);
      expect(const SurahInfo(2).hasBasmala, isTrue);
      expect(const SurahInfo(2).medinan, isTrue);
      expect(const SurahInfo(1).medinan, isFalse);
      expect(const SurahInfo(36).translit, 'Ya-Sin');
      expect(const SurahInfo(1).meaning('ru'), 'Открывающая');
    });

    test('reader list items map to ayahs and headers', () {
      expect(itemInfo(0), (1, null));
      expect(itemInfo(1), (1, 0));
      expect(itemInfo(8), (2, null));
      expect(itemInfo(9), (2, 7));
      expect(itemOfAyah(7), 9);
      const last = totalAyahs + totalSurahs - 1;
      expect(itemInfo(last), (114, totalAyahs - 1));
    });
  });

  group('search', () {
    test('Arabic normalization folds marks and letter forms', () {
      expect(normalizeArabic('ٱلرَّحۡمَٰنِ'), 'الرحمن');
      expect(normalizeArabic('إِيَّاكَ'), 'اياك');
      expect(normalizeArabic('رَحْمَةً'), 'رحمه');
    });

    test('Latin normalization folds accents and apostrophes', () {
      expect(normalizeLatin("Ali 'Imran"), 'ali imran');
      expect(normalizeLatin('Ýaşyl Şäher'), 'yasyl saher');
    });

    test('surah search by number, name, meaning and Arabic', () {
      expect(searchSurahs('36', 'en').single.number, 36);
      SurahInfo.language = 'ru';
      expect(searchSurahs('бакара', 'ru').first.number, 2);
      expect(const SurahInfo(2).translit, 'Аль-Бакара');
      SurahInfo.language = 'tk';
      expect(const SurahInfo(36).translit, 'Ýasin');
      SurahInfo.language = 'en';
      expect(searchSurahs('baqara', 'en').first.number, 2);
      expect(searchSurahs('Al-Kahf', 'en').first.number, 18);
      expect(searchSurahs('cave', 'en').single.number, 18);
      expect(searchSurahs('пещера', 'ru').single.number, 18);
      expect(searchSurahs('الكهف', 'en').single.number, 18);
    });

    test('ayah search scans the normalized text', () {
      final ar = ['بسم الله', 'الحمد لله رب العالمين', 'الرحمن الرحيم'];
      final tr = ['in the name of god', 'praise be to god', 'the merciful'];
      expect(searchAyahs(query: 'merciful', arabicNormalized: ar, translationNormalized: tr), [2]);
      expect(searchAyahs(query: 'لله', arabicNormalized: ar, translationNormalized: tr), [0, 1]);
      expect(searchAyahs(query: 'a', arabicNormalized: ar, translationNormalized: tr), isEmpty);
    });
  });

  group('khatm', () {
    test('page weights sum to 604 and short ayahs weigh less', () {
      expect(ayahPageWeights.fold<double>(0, (a, b) => a + b), closeTo(totalPages, 1e-6));
      expect(ayahPageWeights[const AyahRef(2, 282).index], greaterThan(ayahPageWeights[const AyahRef(108, 1).index]));
      expect(pagesOf([for (var i = 0; i < 7; i++) i]), closeTo(1, 1e-9)); // Al-Fatihah = page 1
    });

    test('first day of a 30-day plan spreads all pages evenly', () {
      final k = khatmProgress(
        plan: const KhatmPlan(start: '2026-10-01', days: 30),
        today: DateTime(2026, 10, 1),
        readPages: 0,
        readTodayPages: 0,
      );
      expect(k.dayNumber, 1);
      expect(k.todayTargetPages, closeTo(totalPages / 30, 1e-9));
      expect(k.targetPagesRounded, 21);
      expect(k.behind, isFalse);
      expect(k.todayDone, isFalse);
    });

    test('missed days are re-spread over the remaining days', () {
      final k = khatmProgress(
        plan: const KhatmPlan(start: '2026-10-01', days: 30),
        today: DateTime(2026, 10, 11),
        readPages: 0,
        readTodayPages: 0,
      );
      expect(k.dayNumber, 11);
      expect(k.daysLeft, 20);
      expect(k.todayTargetPages, closeTo(totalPages / 20, 1e-9));
      expect(k.behind, isTrue);
    });

    test("reading today doesn't shrink today's target and can complete it", () {
      const plan = KhatmPlan(start: '2026-10-01', days: 10);
      final before = khatmProgress(plan: plan, today: DateTime(2026, 10, 2), readPages: 60, readTodayPages: 0);
      final after = khatmProgress(plan: plan, today: DateTime(2026, 10, 2), readPages: 121, readTodayPages: 61);
      expect(after.todayTargetPages, before.todayTargetPages);
      expect(after.todayDone, isTrue);
    });

    test('an overdue plan asks for the usual pace and offers an extension', () {
      final k = khatmProgress(
        plan: const KhatmPlan(start: '2026-10-01', days: 30),
        today: DateTime(2026, 11, 4), // day 35
        readPages: 300,
        readTodayPages: 0,
      );
      expect(k.overdue, isTrue);
      expect(k.dayShown, 30);
      expect(k.todayTargetPages, closeTo(totalPages / 30, 1e-9)); // not all 304 pages
      // 304 pages at ~20.1/day = 16 more days from day 35 → plan of 50 days.
      expect(k.extensionDays, 20);
      final extended = khatmProgress(
        plan: KhatmPlan(start: k.plan.start, days: k.plan.days + k.extensionDays),
        today: DateTime(2026, 11, 4),
        readPages: 300,
        readTodayPages: 0,
      );
      expect(extended.overdue, isFalse);
      expect(extended.daysLeft, 16);
    });

    test('far behind reports the gap in pages', () {
      final k = khatmProgress(
        plan: const KhatmPlan(start: '2026-10-01', days: 30),
        today: DateTime(2026, 10, 7),
        readPages: 0,
        readTodayPages: 0,
      );
      expect(k.farBehind, isTrue);
      expect(k.pagesBehind, closeTo(totalPages * 6 / 30, 1e-9));
    });

    test('complete only when every ayah was read', () {
      final k = khatmProgress(
        plan: const KhatmPlan(start: '2026-10-01', days: 7),
        today: DateTime(2026, 10, 9),
        readPages: 603.99999,
        readTodayPages: 5,
        allRead: true,
      );
      expect(k.complete, isTrue);
      expect(k.fraction, 1);
      expect(k.behind, isFalse);
    });

    test('portion helpers', () {
      expect(firstUnread({0, 1, 2}), 3);
      expect(firstUnread({}), 0);
      // One page from Al-Fatihah ends at its last ayah.
      expect(portionEnd(0, 1), 6);
    });

    test('plan JSON round-trip and validation', () {
      const p = KhatmPlan(start: '2026-10-01', days: 30);
      expect(KhatmPlan.fromJson(p.toJson()), p);
      expect(KhatmPlan.fromJson({'start': '2026-10-01', 'days': 0}), isNull);
      expect(KhatmPlan.fromJson('nope'), isNull);
    });
  });

  test('reading streak tolerates an unfinished today', () {
    final days = {'2026-10-02', '2026-10-03', '2026-10-04'};
    expect(readingStreak(days, DateTime(2026, 10, 4)), 3);
    expect(readingStreak(days, DateTime(2026, 10, 5)), 3);
    expect(readingStreak(days, DateTime(2026, 10, 6)), 0);
    expect(readingStreak({}, DateTime(2026, 10, 6)), 0);
  });

  test('hifz ladder: good climbs, hard steps back, again restarts', () {
    expect(hifzNext(0, grade: HifzGrade.good), (1, 3));
    expect(hifzNext(4, grade: HifzGrade.good), (5, 90));
    expect(hifzNext(5, grade: HifzGrade.good), (5, 90));
    expect(hifzNext(4, grade: HifzGrade.hard), (3, 14));
    expect(hifzNext(0, grade: HifzGrade.hard), (0, 1));
    expect(hifzNext(4, grade: HifzGrade.again), (0, 1));
  });

  test('tracker honours a per-ayah dwell', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final t = ReadTracker(
      repository: QuranRepository(db),
      today: () => const DayKey('2026-10-04'),
      flushEvery: 100,
      dwellFor: (a) => a == 1 ? 4 : 2,
    );
    for (var i = 0; i < 3; i++) {
      t.tick([0, 1]);
    }
    expect(t.recorded, {0});
    t.tick([0, 1]);
    expect(t.recorded, {0, 1});
  });

  test('daily ayah is stable within a day and valid', () {
    final a = dailyAyah(DateTime(2026, 10, 4, 6));
    expect(dailyAyah(DateTime(2026, 10, 4, 23)), a);
    for (final r in dailyAyahPool) {
      expect(AyahRef.tryParse(r.toString()), r);
    }
  });

  test('translations resolve to a language default', () {
    expect(QuranTranslations.resolve(null, 'tr'), 'tr_diyanet');
    expect(QuranTranslations.resolve(null, 'tk'), 'ru_kuliev');
    expect(QuranTranslations.resolve('kk_altai', 'en'), 'kk_altai');
    expect(QuranTranslations.resolve('xx', 'en'), 'en_sahih');
  });

  test('read tracker records ayahs that stay on screen', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = QuranRepository(db);
    final tracker = ReadTracker(repository: repo, today: () => const DayKey('2026-10-04'), flushEvery: 100);
    tracker.tick([1, 2]);
    tracker.tick([2, 3]); // 1 scrolled away after one tick, 2 dwelled
    tracker.tick([3]);
    await tracker.flush();
    final counts = await repo.watchDailyCounts(const DayKey('2026-10-04'), const DayKey('2026-10-04')).first;
    expect(counts[const DayKey('2026-10-04')], 2);
    expect(tracker.recorded, {2, 3});
    expect(await repo.watchDistinctSince(const DayKey('2026-10-01')).first, 2);
  });
}
