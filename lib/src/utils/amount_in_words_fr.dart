/// Écrit un montant en euros en toutes lettres, en français (orthographe
/// traditionnelle : traits d'union uniquement en dessous de cent).
///
/// Le montant est donné en centimes pour éviter les erreurs d'arrondi :
/// `amountInWordsFr(105050)` → « mille cinquante euros et cinquante centimes ».
String amountInWordsFr(int cents) {
  if (cents < 0) {
    throw ArgumentError.value(cents, 'cents', 'Le montant doit être positif');
  }
  final euros = cents ~/ 100;
  final centimes = cents % 100;

  final String eurosPart;
  if (euros == 0) {
    eurosPart = centimes == 0 ? 'zéro euro' : '';
  } else if (euros == 1) {
    eurosPart = 'un euro';
  } else {
    // « un million d'euros », mais « un million deux cents euros ».
    final words = numberToWordsFr(euros);
    eurosPart = euros % 1000000 == 0 ? "$words d'euros" : '$words euros';
  }

  if (centimes == 0) return eurosPart;
  final centimesPart =
      centimes == 1 ? 'un centime' : '${numberToWordsFr(centimes)} centimes';
  return eurosPart.isEmpty ? centimesPart : '$eurosPart et $centimesPart';
}

/// Écrit un entier positif en toutes lettres (« soixante et onze »,
/// « quatre-vingts », « deux cent mille »…).
String numberToWordsFr(int n) {
  if (n < 0) throw ArgumentError.value(n, 'n', 'Doit être positif');
  if (n == 0) return 'zéro';

  final parts = <String>[];
  final milliards = n ~/ 1000000000;
  final millions = (n ~/ 1000000) % 1000;
  final milliers = (n ~/ 1000) % 1000;
  final reste = n % 1000;

  if (milliards > 0) {
    parts.add(milliards == 1
        ? 'un milliard'
        : '${_below1000(milliards)} milliards');
  }
  if (millions > 0) {
    parts.add(
        millions == 1 ? 'un million' : '${_below1000(millions)} millions');
  }
  if (milliers > 0) {
    // « mille » est invariable et fige « cent » et « quatre-vingt » devant lui.
    parts.add(milliers == 1
        ? 'mille'
        : '${_below1000(milliers, beforeMille: true)} mille');
  }
  if (reste > 0) parts.add(_below1000(reste));
  return parts.join(' ');
}

const _units = [
  'zéro', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', //
  'neuf', 'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize',
];

const _tens = {
  2: 'vingt',
  3: 'trente',
  4: 'quarante',
  5: 'cinquante',
  6: 'soixante',
};

String _below1000(int n, {bool beforeMille = false}) {
  final hundreds = n ~/ 100;
  final rest = n % 100;
  final parts = <String>[];
  if (hundreds == 1) {
    parts.add('cent');
  } else if (hundreds > 1) {
    final plural = rest == 0 && !beforeMille;
    parts.add('${_units[hundreds]} ${plural ? 'cents' : 'cent'}');
  }
  if (rest > 0) parts.add(_below100(rest, beforeMille: beforeMille));
  return parts.join(' ');
}

String _below100(int n, {bool beforeMille = false}) {
  if (n < 17) return _units[n];
  if (n < 20) return 'dix-${_units[n - 10]}';
  final ten = n ~/ 10;
  final unit = n % 10;
  if (ten <= 6) {
    final t = _tens[ten]!;
    if (unit == 0) return t;
    if (unit == 1) return '$t et un';
    return '$t-${_units[unit]}';
  }
  if (ten == 7) {
    if (n == 71) return 'soixante et onze';
    return 'soixante-${_below100(n - 60)}';
  }
  // 80 à 99
  if (n == 80) return beforeMille ? 'quatre-vingt' : 'quatre-vingts';
  return 'quatre-vingt-${_below100(n - 80)}';
}
