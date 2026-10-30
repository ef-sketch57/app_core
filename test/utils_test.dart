import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

const nbsp = ' ';

void main() {
  group('formatEuros', () {
    test('format fr_FR', () {
      expect(formatEuros(105000), '1${nbsp}050,00$nbsp€');
      expect(formatEuros(95000), '950,00$nbsp€');
      expect(formatEuros(0), '0,00$nbsp€');
    });

    test('format court', () {
      expect(formatEurosShort(72000), '720$nbsp€');
      expect(formatEurosShort(105000), '1${nbsp}050$nbsp€');
      expect(formatEurosShort(1250), '12,50$nbsp€');
    });
  });

  group('parseEurosToCents', () {
    test('saisies valides', () {
      expect(parseEurosToCents('950'), 95000);
      expect(parseEurosToCents('950,5'), 95050);
      expect(parseEurosToCents('1 050,00 €'), 105000);
      expect(parseEurosToCents('12.34'), 1234);
      expect(parseEurosToCents('7,'), 700);
    });

    test('saisies invalides', () {
      expect(parseEurosToCents(''), isNull);
      expect(parseEurosToCents('abc'), isNull);
      expect(parseEurosToCents('1,234'), isNull);
      expect(parseEurosToCents('-5'), isNull);
    });
  });

  group('dates', () {
    test('mois', () {
      expect(monthYearFr(2026, 10), 'Octobre 2026');
      expect(ofMonthFr(10), "d'octobre");
      expect(ofMonthFr(8), "d'août");
      expect(ofMonthFr(3), 'de mars');
    });

    test('formats', () {
      expect(formatDateFr(DateTime(2026, 10, 5)), '05/10/2026');
      expect(formatRangeFr(DateTime(2026, 10, 1), DateTime(2026, 10, 31)),
          'du 1er au 31 octobre 2026');
      expect(parseDateFr('05/10/2026'), DateTime(2026, 10, 5));
      expect(parseDateFr('31/02/2026'), isNull);
    });
  });

  group('plafond des interstitiels', () {
    final now = DateTime(2026, 10, 30, 12);
    const interval = Duration(minutes: 3);

    test('jamais au premier lancement', () {
      expect(
          interstitialAllowed(
              isFirstLaunch: true,
              lastShownAt: null,
              now: now,
              minInterval: interval),
          isFalse);
    });

    test('pas plus d\'un toutes les 3 minutes', () {
      expect(
          interstitialAllowed(
              isFirstLaunch: false,
              lastShownAt: now.subtract(const Duration(minutes: 2)),
              now: now,
              minInterval: interval),
          isFalse);
      expect(
          interstitialAllowed(
              isFirstLaunch: false,
              lastShownAt: now.subtract(const Duration(minutes: 3)),
              now: now,
              minInterval: interval),
          isTrue);
      expect(
          interstitialAllowed(
              isFirstLaunch: false,
              lastShownAt: null,
              now: now,
              minInterval: interval),
          isTrue);
    });
  });
}
