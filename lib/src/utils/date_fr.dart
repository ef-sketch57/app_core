/// Petits utilitaires de dates en français, sans dépendre des données de
/// localisation d'`intl` (pas d'initialisation asynchrone nécessaire).
library;

const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', //
  'septembre', 'octobre', 'novembre', 'décembre',
];

const _weekdays = [
  'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche', //
];

/// « vendredi » pour [DateTime.friday].
String weekdayNameFr(int weekday) => _weekdays[weekday - 1];

/// « vendredi 30 octobre », « mardi 1er décembre »
String formatWeekdayDateFr(DateTime d) =>
    '${weekdayNameFr(d.weekday)} ${dayFr(d.day)} ${monthNameFr(d.month)}';

/// « octobre »
String monthNameFr(int month) => _months[month - 1];

/// « Octobre 2026 »
String monthYearFr(int year, int month) {
  final name = monthNameFr(month);
  return '${name[0].toUpperCase()}${name.substring(1)} $year';
}

/// « d'octobre », « de mars » (élision devant voyelle).
String ofMonthFr(int month) {
  final name = monthNameFr(month);
  return 'aeiouâéèêîôû'.contains(name[0]) ? "d'$name" : 'de $name';
}

/// « 1er », « 2 », « 31 »
String dayFr(int day) => day == 1 ? '1er' : '$day';

/// « 05/10/2026 »
String formatDateFr(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// « 01/10 »
String formatDayMonthFr(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

/// « 5 octobre 2026 », « 1er octobre 2026 »
String formatDateLongFr(DateTime d) =>
    '${dayFr(d.day)} ${monthNameFr(d.month)} ${d.year}';

/// « du 1er au 31 octobre 2026 », ou « du 15 octobre 2026 au 14 novembre
/// 2026 » si les deux dates ne tombent pas dans le même mois.
String formatRangeFr(DateTime start, DateTime end) {
  if (start.year == end.year && start.month == end.month) {
    return 'du ${dayFr(start.day)} au ${formatDateLongFr(end)}';
  }
  return 'du ${formatDateLongFr(start)} au ${formatDateLongFr(end)}';
}

/// Lit « 05/10/2026 » ; renvoie `null` si la date est invalide.
DateTime? parseDateFr(String input) {
  final m = RegExp(r'^\s*(\d{1,2})/(\d{1,2})/(\d{4})\s*$').firstMatch(input);
  if (m == null) return null;
  final d = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final y = int.parse(m.group(3)!);
  final date = DateTime(y, mo, d);
  if (date.day != d || date.month != mo) return null;
  return date;
}

String _two(int n) => n.toString().padLeft(2, '0');
