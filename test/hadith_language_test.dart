import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/features/hadith/application/hadith_providers.dart';
import 'package:waqt/features/hadith/domain/hadith.dart';
import 'package:waqt/features/hadith/domain/hadith_section_names.dart';

import 'helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DailyHadith?> daily(String language) async {
    final c = testContainer(AppSettings(onboardingDone: true, language: language));
    addTearDown(c.dispose);
    return c.read(hadithOfDayProvider.future);
  }

  test('hadith of the day is in the app language', () async {
    final ru = (await daily('ru'))!;
    expect(ru.book.id, 'bukhari');
    expect(ru.hadith.text, contains(RegExp('[а-яА-Я]')));
    expect(ru.arabic!.text, contains(RegExp('[؀-ۿ]')));

    final tk = (await daily('tk'))!;
    expect(tk.hadith.text, contains(RegExp('[а-яА-Я]'))); // Russian: no Turkmen hadith translation

    final tr = (await daily('tr'))!;
    expect(tr.book.id, 'nawawi'); // the only 40-hadith collection with a Turkish edition
    expect(tr.hadith.text, isNot(contains('Narrated')));
  });

  test('chapter names follow the app language', () {
    const s = HadithSection(30, 'Fasting', 1891, 1969);
    expect(hadithSectionName('bukhari', s, 'tr'), 'Oruç');
    expect(hadithSectionName('bukhari', s, 'ru'), 'Пост');
    expect(hadithSectionName('bukhari', s, 'tk'), 'Oraza');
    expect(hadithSectionName('bukhari', s, 'en'), 'Fasting');
    expect(hadithSectionName('muslim', const HadithSection(13, 'The Book of Fasting', 0, 0), 'tr'), 'Oruç');
  });
}
