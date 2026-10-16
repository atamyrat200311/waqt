/// Route paths in one place so features never hard-code strings.
abstract final class Routes {
  static const today = '/today';
  static const qada = '/today/qada';
  static const tasks = '/today/tasks';

  static const tools = '/tools';
  static const calendar = '/tools/calendar';
  static const qiblaFull = '/tools/qibla';
  static const ramadan = '/tools/ramadan';

  static const me = '/me';
  static const settings = '/me/settings';
  /// Above the shell so Home's location chip and Settings both open it in place.
  static const location = '/location';
  static const widgetsHelp = '/me/settings/widgets';

  /// Full-screen reader, above the shell. `/adhkar/morning` or `/adhkar/evening`.
  static String adhkar(String set) => '/adhkar/$set';
  static const adhkarPattern = '/adhkar/:set';

  static const onboarding = '/onboarding';

  // ---- Quran tab
  static const quran = '/quran';
  static const quranSearch = '/quran/search';
  static const quranBookmarks = '/quran/bookmarks';
  static const khatm = '/quran/khatm';
  static const hifz = '/quran/memorize';

  /// Full-screen reader above the shell, opened at a global ayah index.
  static const readPattern = '/read';
  static String read(int index, {bool page = false, int? hifzSurah}) =>
      '/read?i=$index${page ? '&mode=page' : ''}${hifzSurah != null ? '&hifz=$hifzSurah' : ''}';

  // ---- Library tab
  static const library = '/library';
  static const hadithBooks = '/library/hadith';
  static String hadithBook(String book) => '/library/hadith/$book';
  static String hadithSection(String book, int section) => '/library/hadith/$book/$section';
  static const hadithSearch = '/library/hadith-search';
  static const duas = '/library/duas';
  static const names = '/library/names';
  static const learn = '/library/learn';
  static String learnGuide(String id) => '/library/learn/$id';
  static const libraryBookmarks = '/library/saved';

  // ---- Tools additions
  static const zakat = '/tools/zakat';
  static const timetable = '/tools/timetable';
  static const habits = '/today/habits';
  static const backup = '/me/settings/backup';

  /// Deep link used by notification taps: opens Today and the mark sheet.
  static String markPrayer(String prayer, String day) => '/today?mark=$prayer&day=$day';
}
