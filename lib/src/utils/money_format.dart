import 'package:intl/intl.dart';

final _euroFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

/// Formate des centimes en euros à la française : `105000` → « 1 050,00 € ».
///
/// Les espaces fines insécables produites par `intl` sont remplacées par des
/// espaces insécables classiques, présentes dans toutes les polices (PDF).
String formatEuros(int cents) => _euroFormat
    .format(cents / 100)
    .replaceAll(' ', ' ')
    .replaceAll(' ', ' ');

/// Variante sans décimales quand le montant est rond : « 720 € », « 12,50 € ».
String formatEurosShort(int cents) {
  if (cents % 100 != 0) return formatEuros(cents);
  final f = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
  return f
      .format(cents ~/ 100)
      .replaceAll(' ', ' ')
      .replaceAll(' ', ' ');
}

/// Lit une saisie utilisateur (« 950 », « 950,5 », « 1 050,00 € ») et renvoie
/// des centimes, ou `null` si la saisie n'est pas un montant valide.
int? parseEurosToCents(String input) {
  var s = input
      .replaceAll('€', '')
      .replaceAll(RegExp(r'[\s  ]'), '')
      .replaceAll(',', '.');
  if (s.isEmpty) return null;
  if (!RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(s)) return null;
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  final parts = s.split('.');
  final euros = int.parse(parts[0]);
  final cents = parts.length > 1 ? int.parse(parts[1].padRight(2, '0')) : 0;
  return euros * 100 + cents;
}
