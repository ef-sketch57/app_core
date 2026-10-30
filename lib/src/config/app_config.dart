import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identifiants de blocs d'annonces pour une plateforme.
class AdUnitIds {
  const AdUnitIds({required this.banner, required this.interstitial});

  final String banner;
  final String interstitial;

  /// Blocs de test officiels de Google : à utiliser en développement.
  static const testAndroid = AdUnitIds(
    banner: 'ca-app-pub-3940256099942544/9214589741',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const testIos = AdUnitIds(
    banner: 'ca-app-pub-3940256099942544/2435281174',
    interstitial: 'ca-app-pub-3940256099942544/4411468910',
  );
}

/// Configuration propre à chaque appli construite sur `app_core`.
///
/// Chaque appli en crée une instance et l'injecte via [appConfigProvider].
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.androidAds,
    required this.iosAds,
    required this.proProductId,
    this.interstitialMinInterval = const Duration(minutes: 3),
    this.forceTestAds = kDebugMode,
  });

  final String appName;

  /// IDs AdMob réels (remplacés par les IDs de test si [forceTestAds]).
  final AdUnitIds androidAds;
  final AdUnitIds iosAds;

  /// Identifiant du produit « Pro » non consommable dans les boutiques.
  final String proProductId;

  /// Délai minimum entre deux interstitiels.
  final Duration interstitialMinInterval;

  /// Vrai en debug : on n'affiche jamais de vraies pubs pendant le développement.
  final bool forceTestAds;

  AdUnitIds get adUnits {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    if (forceTestAds) return ios ? AdUnitIds.testIos : AdUnitIds.testAndroid;
    return ios ? iosAds : androidAds;
  }

  /// Pubs et achats ne sont disponibles que sur Android et iOS. Ailleurs
  /// (aperçu web), ils sont simulés.
  static bool get mobileServicesAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

/// À surcharger dans `main()` avec la configuration de l'appli.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider doit être surchargé'),
);
