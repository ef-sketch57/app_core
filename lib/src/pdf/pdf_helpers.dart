import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Polices embarquées pour les PDF (Manrope), pour un rendu identique hors
/// ligne et sur tous les appareils.
class PdfFonts {
  const PdfFonts({
    required this.regular,
    required this.medium,
    required this.semiBold,
    required this.bold,
    required this.extraBold,
  });

  final pw.Font regular;
  final pw.Font medium;
  final pw.Font semiBold;
  final pw.Font bold;
  final pw.Font extraBold;

  static PdfFonts? _cache;

  /// Charge les polices depuis les ressources du package `app_core`.
  static Future<PdfFonts> load([AssetBundle? bundle]) async {
    if (_cache != null && bundle == null) return _cache!;
    final b = bundle ?? rootBundle;
    Future<pw.Font> font(String style) async => pw.Font.ttf(
        await b.load('packages/app_core/assets/fonts/Manrope-$style.ttf'));
    final fonts = PdfFonts(
      regular: await font('Regular'),
      medium: await font('Medium'),
      semiBold: await font('SemiBold'),
      bold: await font('Bold'),
      extraBold: await font('ExtraBold'),
    );
    if (bundle == null) _cache = fonts;
    return fonts;
  }

  /// Construit les polices à partir d'octets bruts (tests, outils).
  factory PdfFonts.fromBytes({
    required ByteData regular,
    required ByteData medium,
    required ByteData semiBold,
    required ByteData bold,
    required ByteData extraBold,
  }) =>
      PdfFonts(
        regular: pw.Font.ttf(regular),
        medium: pw.Font.ttf(medium),
        semiBold: pw.Font.ttf(semiBold),
        bold: pw.Font.ttf(bold),
        extraBold: pw.Font.ttf(extraBold),
      );

  pw.ThemeData get theme => pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: regular,
        boldItalic: bold,
      );
}

/// Couleurs PDF reprises du thème de l'appli.
class PdfColorsKit {
  static const ink = PdfColor.fromInt(0xFF1B2430);
  static const muted = PdfColor.fromInt(0xFF5B6472);
  static const border = PdfColor.fromInt(0xFFE6E3DB);
  static const accent = PdfColor.fromInt(0xFF2F6B4F);
}

/// Document A4 avec marges confortables et polices embarquées.
pw.Document a4Document({
  required PdfFonts fonts,
  required String title,
  required String author,
  required List<pw.Widget> Function(pw.Context) build,
}) {
  final doc = pw.Document(title: title, author: author, creator: author);
  doc.addPage(
    pw.Page(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 52),
        theme: fonts.theme,
      ),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: build(ctx),
      ),
    ),
  );
  return doc;
}

/// Document A4 sur plusieurs pages (longs tableaux), avec pied de page
/// « page X / Y » facultatif.
pw.Document a4MultiPageDocument({
  required PdfFonts fonts,
  required String title,
  required String author,
  required List<pw.Widget> Function(pw.Context) build,
  String? footerText,
}) {
  final doc = pw.Document(title: title, author: author, creator: author);
  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 44),
        theme: fonts.theme,
      ),
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      footer: (ctx) => pw.Row(children: [
        pw.Expanded(
          child: pw.Text(footerText ?? '',
              style: const pw.TextStyle(fontSize: 8, color: PdfColorsKit.muted)),
        ),
        pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColorsKit.muted)),
      ]),
      build: build,
    ),
  );
  return doc;
}

/// Ligne « libellé … montant » d'un tableau de sommes.
pw.Widget pdfAmountRow(String label, String amount,
    {bool bold = false, bool last = false}) {
  final style = pw.TextStyle(
    fontSize: 10.5,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    color: PdfColorsKit.ink,
  );
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: last
        ? null
        : const pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(color: PdfColorsKit.border, width: 0.8))),
    child: pw.Row(children: [
      pw.Expanded(child: pw.Text(label, style: style)),
      pw.Text(amount, style: style),
    ]),
  );
}

/// Petit titre de bloc en capitales (« BAILLEUR », « LOCATAIRE »).
pw.Widget pdfLabel(String text) => pw.Text(
      text.toUpperCase(),
      style: const pw.TextStyle(
          fontSize: 8, color: PdfColorsKit.muted, letterSpacing: 0.6),
    );

/// Image (signature PNG) à partir d'octets, ou `null`.
pw.ImageProvider? pdfImage(Uint8List? bytes) =>
    bytes == null || bytes.isEmpty ? null : pw.MemoryImage(bytes);
