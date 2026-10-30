import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('amountInWordsFr (centimes)', () {
    test('cas demandés', () {
      expect(amountInWordsFr(0), 'zéro euro');
      expect(amountInWordsFr(2100), 'vingt et un euros');
      expect(amountInWordsFr(7100), 'soixante et onze euros');
      expect(amountInWordsFr(8000), 'quatre-vingts euros');
      expect(amountInWordsFr(100000), 'mille euros');
      expect(amountInWordsFr(105050),
          'mille cinquante euros et cinquante centimes');
    });

    test('singulier et centimes seuls', () {
      expect(amountInWordsFr(100), 'un euro');
      expect(amountInWordsFr(1), 'un centime');
      expect(amountInWordsFr(50), 'cinquante centimes');
      expect(amountInWordsFr(101), 'un euro et un centime');
    });

    test("« d'euros » après million", () {
      expect(amountInWordsFr(100000000), "un million d'euros");
      expect(amountInWordsFr(200000000), "deux millions d'euros");
      expect(amountInWordsFr(100020000), 'un million deux cents euros');
    });

    test('montant de la maquette', () {
      expect(amountInWordsFr(105000), 'mille cinquante euros');
      expect(amountInWordsFr(72000), 'sept cent vingt euros');
    });

    test('refuse les montants négatifs', () {
      expect(() => amountInWordsFr(-1), throwsArgumentError);
    });
  });

  group('numberToWordsFr', () {
    final cases = {
      1: 'un',
      10: 'dix',
      16: 'seize',
      17: 'dix-sept',
      20: 'vingt',
      22: 'vingt-deux',
      31: 'trente et un',
      61: 'soixante et un',
      70: 'soixante-dix',
      72: 'soixante-douze',
      77: 'soixante-dix-sept',
      81: 'quatre-vingt-un',
      90: 'quatre-vingt-dix',
      91: 'quatre-vingt-onze',
      99: 'quatre-vingt-dix-neuf',
      100: 'cent',
      101: 'cent un',
      180: 'cent quatre-vingts',
      200: 'deux cents',
      201: 'deux cent un',
      1001: 'mille un',
      2000: 'deux mille',
      80000: 'quatre-vingt mille',
      200000: 'deux cent mille',
      280000: 'deux cent quatre-vingt mille',
      1000000: 'un million',
      2500000: 'deux millions cinq cent mille',
      1000000000: 'un milliard',
    };
    cases.forEach((n, words) {
      test('$n', () => expect(numberToWordsFr(n), words));
    });
  });
}
