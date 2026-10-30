import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Partage et enregistrement de fichiers PDF.
class ShareService {
  /// Ouvre la feuille de partage du système (e-mail, WhatsApp, SMS…).
  /// Renvoie `false` si l'utilisateur a fermé la feuille sans rien choisir.
  Future<bool> sharePdf({
    required Uint8List bytes,
    required String fileName,
    String? subject,
    String? text,
    Rect? origin,
  }) async {
    if (kIsWeb) {
      // L'aperçu web télécharge le fichier.
      return Printing.sharePdf(bytes: bytes, filename: fileName);
    }
    final result = await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: fileName)],
      fileNameOverrides: [fileName],
      subject: subject,
      text: text,
      sharePositionOrigin: origin,
    ));
    return result.status != ShareResultStatus.dismissed;
  }

  /// Ouvre la boîte d'impression du système, qui propose « Enregistrer en
  /// PDF » (Android, iOS) ; sur le web, télécharge le fichier.
  Future<void> savePdf({required Uint8List bytes, required String fileName}) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return;
    }
    await Printing.layoutPdf(name: fileName, onLayout: (_) async => bytes);
  }
}

final shareServiceProvider = Provider<ShareService>((ref) => ShareService());
