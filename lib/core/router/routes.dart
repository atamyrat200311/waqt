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
  static const location = '/me/settings/location';
  static const widgetsHelp = '/me/settings/widgets';

  /// Full-screen reader, above the shell. `/adhkar/morning` or `/adhkar/evening`.
  static String adhkar(String set) => '/adhkar/$set';
  static const adhkarPattern = '/adhkar/:set';

  static const onboarding = '/onboarding';

  /// Deep link used by notification taps: opens Today and the mark sheet.
  static String markPrayer(String prayer, String day) => '/today?mark=$prayer&day=$day';
}
