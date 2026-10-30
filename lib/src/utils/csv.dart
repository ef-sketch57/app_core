import 'dart:convert';
import 'dart:typed_data';

/// Construit un CSV lisible par Excel en français : séparateur `;`, fins de
/// ligne CRLF, champs entourés de guillemets si besoin.
String toCsv(List<List<Object?>> rows, {String separator = ';'}) {
  String cell(Object? v) {
    final s = v?.toString() ?? '';
    final needsQuotes = s.contains(separator) ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r');
    return needsQuotes ? '"${s.replaceAll('"', '""')}"' : s;
  }

  return rows.map((r) => r.map(cell).join(separator)).join('\r\n');
}

/// Octets UTF-8 avec BOM, pour qu'Excel affiche correctement les accents.
Uint8List csvBytes(String csv) =>
    Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
