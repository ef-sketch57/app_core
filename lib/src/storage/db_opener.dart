import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Ouvre la base SQLite locale de l'appli (fichier dans le dossier privé de
/// l'appli). Rien ne quitte l'appareil.
///
/// Sur le web (aperçu), drift utilise `sqlite3.wasm` et `drift_worker.js`, à
/// placer dans le dossier `web/` de l'appli.
QueryExecutor openAppDatabase(String name) => driftDatabase(
      name: name,
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
