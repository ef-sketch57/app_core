import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Ouvre la base SQLite locale de l'appli (fichier dans le dossier privé de
/// l'appli). Rien ne quitte l'appareil.
///
/// Sur le web (aperçu), drift utilise `sqlite3.wasm` et `drift_worker.js`, à
/// placer dans le dossier `web/` de l'appli.
///
/// [shareAcrossIsolates] : une seule connexion partagée entre l'appli et ses
/// isolats d'arrière-plan (actions de notification), pour éviter deux accès
/// concurrents au même fichier.
QueryExecutor openAppDatabase(String name, {bool shareAcrossIsolates = false}) =>
    driftDatabase(
      name: name,
      native: DriftNativeOptions(shareAcrossIsolates: shareAcrossIsolates),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
