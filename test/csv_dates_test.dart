import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toCsv', () {
    test('séparateur point-virgule et guillemets si besoin', () {
      final csv = toCsv([
        ['Date', 'Type', 'Note'],
        ['30/10/2026', 'Télétravail', 'avec ; point-virgule'],
        ['31/10/2026', null, 'dit "bonjour"'],
      ]);
      expect(
        csv,
        'Date;Type;Note\r\n'
        '30/10/2026;Télétravail;"avec ; point-virgule"\r\n'
        '31/10/2026;;"dit ""bonjour"""',
      );
    });

    test('BOM UTF-8 pour Excel', () {
      final bytes = csvBytes('é');
      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(bytes.length, 5);
    });
  });

  group('jours de la semaine', () {
    test('noms et date longue', () {
      expect(weekdayNameFr(DateTime.monday), 'lundi');
      expect(weekdayNameFr(DateTime.sunday), 'dimanche');
      expect(formatWeekdayDateFr(DateTime(2026, 10, 30)), 'vendredi 30 octobre');
      expect(formatWeekdayDateFr(DateTime(2026, 12, 1)), 'mardi 1er décembre');
    });
  });
}
