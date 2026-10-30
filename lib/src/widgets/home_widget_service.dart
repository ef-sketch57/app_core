import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../config/app_config.dart';

/// Données d'un widget d'écran d'accueil, transmises au code natif de l'appli
/// (Android `AppWidgetProvider`, iOS WidgetKit) via `home_widget`.
///
/// Le dessin du widget reste dans chaque appli ; le socle ne fait qu'écrire
/// les valeurs et demander le rafraîchissement.
class HomeWidgetService {
  HomeWidgetService({
    required this.androidName,
    this.iOSName,
    this.appGroupId,
  });

  /// Nom de la classe `AppWidgetProvider` Android (sans le paquet).
  final String androidName;

  /// Nom du widget iOS (`kind` WidgetKit).
  final String? iOSName;

  /// App Group iOS partagé entre l'appli et l'extension du widget.
  final String? appGroupId;

  bool _groupSet = false;

  bool get supported => AppConfig.mobileServicesAvailable;

  /// Écrit les valeurs puis rafraîchit le widget. Ne lève jamais d'erreur :
  /// un widget non installé ne doit pas gêner l'appli.
  Future<void> update(Map<String, Object> values) async {
    if (!supported) return;
    try {
      if (!_groupSet && appGroupId != null) {
        await HomeWidget.setAppGroupId(appGroupId!);
        _groupSet = true;
      }
      for (final e in values.entries) {
        await HomeWidget.saveWidgetData<Object>(e.key, e.value);
      }
      await HomeWidget.updateWidget(
        androidName: androidName,
        iOSName: iOSName,
      );
    } catch (e) {
      debugPrint('Widget : $e');
    }
  }
}

/// À surcharger dans `main()` si l'appli a un widget d'écran d'accueil.
final homeWidgetServiceProvider = Provider<HomeWidgetService>(
  (ref) => throw UnimplementedError('homeWidgetServiceProvider doit être surchargé'),
);
