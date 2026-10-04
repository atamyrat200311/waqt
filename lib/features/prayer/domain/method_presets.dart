import '../../../data/db/enums.dart';

/// Calculation method preset by region, chosen from the device time zone or a
/// city's country (offline). The user can always change it ("Advanced").
({CalcMethod method, AsrMadhab madhab}) presetForRegion({String? countryCode, String? timezone}) {
  final cc = countryCode?.toUpperCase();
  final tz = timezone ?? '';

  const hanafiMwl = (method: CalcMethod.muslimWorldLeague, madhab: AsrMadhab.hanafi);

  // Central Asia, Caucasus, Russia → MWL + Hanafi (main audience).
  const centralAsia = {'TM', 'UZ', 'KZ', 'KG', 'TJ', 'AF', 'AZ', 'RU', 'BY', 'UA', 'GE'};
  if (cc != null && centralAsia.contains(cc)) return hanafiMwl;
  if (const ['Asia/Ashgabat', 'Asia/Tashkent', 'Asia/Samarkand', 'Asia/Almaty', 'Asia/Bishkek', 'Asia/Dushanbe', 'Asia/Baku', 'Asia/Kabul']
      .contains(tz)) {
    return hanafiMwl;
  }
  if (tz.startsWith('Europe/Moscow') || tz.startsWith('Asia/Q') || tz.startsWith('Asia/Aq')) return hanafiMwl;

  if (cc == 'TR' || tz == 'Europe/Istanbul') {
    return (method: CalcMethod.turkey, madhab: AsrMadhab.hanafi);
  }
  if (const {'SA', 'YE'}.contains(cc) || tz == 'Asia/Riyadh' || tz == 'Asia/Aden') {
    return (method: CalcMethod.ummAlQura, madhab: AsrMadhab.standard);
  }
  if (cc == 'AE' || tz == 'Asia/Dubai' || cc == 'OM' || tz == 'Asia/Muscat') {
    return (method: CalcMethod.dubai, madhab: AsrMadhab.standard);
  }
  if (cc == 'QA' || tz == 'Asia/Qatar' || cc == 'BH' || tz == 'Asia/Bahrain') {
    return (method: CalcMethod.qatar, madhab: AsrMadhab.standard);
  }
  if (cc == 'KW' || tz == 'Asia/Kuwait') {
    return (method: CalcMethod.kuwait, madhab: AsrMadhab.standard);
  }
  if (const {'EG', 'SD', 'LY', 'DZ', 'MA', 'TN', 'SY', 'LB', 'JO', 'PS', 'IQ'}.contains(cc) ||
      tz.startsWith('Africa/')) {
    return (method: CalcMethod.egyptian, madhab: AsrMadhab.standard);
  }
  if (const {'PK', 'IN', 'BD'}.contains(cc) ||
      const ['Asia/Karachi', 'Asia/Kolkata', 'Asia/Dhaka'].contains(tz)) {
    return (method: CalcMethod.karachi, madhab: AsrMadhab.hanafi);
  }
  if (cc == 'IR' || tz == 'Asia/Tehran') {
    return (method: CalcMethod.tehran, madhab: AsrMadhab.standard);
  }
  if (const {'SG', 'MY', 'ID', 'BN'}.contains(cc) ||
      const ['Asia/Singapore', 'Asia/Kuala_Lumpur', 'Asia/Jakarta'].contains(tz)) {
    return (method: CalcMethod.singapore, madhab: AsrMadhab.standard);
  }
  if (const {'US', 'CA'}.contains(cc) || tz.startsWith('America/')) {
    return (method: CalcMethod.northAmerica, madhab: AsrMadhab.standard);
  }
  if (tz.startsWith('Europe/') || tz.startsWith('Australia/')) {
    return (method: CalcMethod.muslimWorldLeague, madhab: AsrMadhab.standard);
  }
  return hanafiMwl;
}
