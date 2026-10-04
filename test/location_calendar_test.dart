import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/features/calendar/domain/hijri_service.dart';
import 'package:waqt/features/prayer/location/city_catalog.dart';
import 'package:waqt/features/prayer/location/location_service.dart';
import 'package:waqt/features/ramadan/domain/ramadan.dart';
import 'package:waqt/features/tools/domain/qibla.dart';

void main() {
  final catalog = CityCatalog.fromJsonString(File('assets/data/cities.json').readAsStringSync());

  group('CityCatalog', () {
    test('search ignores case and Turkmen diacritics, and finds other scripts', () {
      expect(catalog.search('asgabat').first.name, 'Ashgabat');
      expect(catalog.search('Ашхабад').first.name, 'Ashgabat');
      expect(catalog.search('turkmenabat').first.name, 'Türkmenabat');
      expect(catalog.search('').length, lessThanOrEqualTo(30));
    });

    test('display name: exact city, "near", or coordinates', () {
      expect(LocationService.displayName(catalog, 37.95, 58.33), 'Ashgabat');
      final near = LocationService.displayName(catalog, 37.2, 61.0);
      expect(near.startsWith('~'), isTrue);
      expect(LocationService.displayName(catalog, -60, -150), contains('°S'));
    });

    test('every city has a valid zone id and coordinates', () {
      for (final c in catalog.cities) {
        expect(c.latitude.abs() <= 90 && c.longitude.abs() <= 180, isTrue, reason: c.name);
        expect(c.timezone.contains('/'), isTrue, reason: c.name);
      }
    });
  });

  group('Qibla', () {
    test('Ashgabat faces roughly south-west', () {
      final b = qiblaBearing(37.9601, 58.3261);
      expect(b, inInclusiveRange(220, 240));
    });

    test('facing tolerance wraps around north', () {
      expect(isFacingQibla(2, 358), isTrue);
      expect(isFacingQibla(90, 100), isFalse);
      expect(qiblaRelativeToHeading(10, 350), 20);
    });
  });

  group('Hijri + Ramadan', () {
    const h = HijriService();

    test('Ramadan 1448 starts around 8 Feb 2027 (Umm al-Qura)', () {
      final start = h.toGregorian(1448, 9, 1);
      expect(start.year, 2027);
      expect(start.month, 2);
      expect(start.day, inInclusiveRange(7, 9));
      expect(h.fromGregorian(start).isRamadan, isTrue);
    });

    test('adjustment shifts the Hijri day', () {
      final d = DateTime(2026, 10, 4);
      final base = h.fromGregorian(d);
      final plus = const HijriService(adjustment: 1).fromGregorian(d);
      expect(plus == base, isFalse);
      expect(const HijriService(adjustment: 1).toGregorian(plus.year, plus.month, plus.day), d);
    });

    test('ramadan mode on/off/auto', () {
      final inRamadan = h.toGregorian(1448, 9, 10);
      expect(isRamadanActive(RamadanMode.auto, h, inRamadan), isTrue);
      expect(isRamadanActive(RamadanMode.off, h, inRamadan), isFalse);
      expect(isRamadanActive(RamadanMode.on, h, DateTime(2026, 10, 4)), isTrue);
      expect(ramadanDay(h, inRamadan)!.day, 10);
      final start = h.toGregorian(1448, 9, 1);
      expect(daysUntilRamadan(h, DateTime(start.year, start.month, start.day - 1)), 1);
      expect(daysUntilRamadan(h, start), 0);
    });

    test('upcoming events are sorted and non-negative', () {
      final ev = upcomingEvents(h, DateTime(2026, 10, 4));
      expect(ev, isNotEmpty);
      for (var i = 1; i < ev.length; i++) {
        expect(ev[i].daysAway >= ev[i - 1].daysAway, isTrue);
      }
    });
  });
}
