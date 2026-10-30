import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import '../storage/prefs.dart';
import 'ads_service.dart';

/// Règle de plafonnement, séparée du SDK pour être testable.
bool interstitialAllowed({
  required bool isFirstLaunch,
  required DateTime? lastShownAt,
  required DateTime now,
  required Duration minInterval,
}) {
  if (isFirstLaunch) return false;
  if (lastShownAt == null) return true;
  return now.difference(lastShownAt) >= minInterval;
}

/// Gère un interstitiel préchargé, avec plafond de fréquence : jamais au
/// premier lancement, et pas plus d'un par [AppConfig.interstitialMinInterval].
class InterstitialManager {
  InterstitialManager(this._ref);

  final Ref _ref;
  InterstitialAd? _ad;
  bool _loading = false;

  AppPrefs get _prefs => _ref.read(appPrefsProvider);
  AppConfig get _config => _ref.read(appConfigProvider);

  /// Précharge une pub si elle pourra être affichée.
  void preload() {
    if (!AppConfig.mobileServicesAvailable) return;
    if (_ad != null || _loading || !_ref.read(showAdsProvider)) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: _config.adUnits.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitiel : ${error.message}');
          _loading = false;
        },
      ),
    );
  }

  /// Affiche l'interstitiel si les règles le permettent et attend sa
  /// fermeture. Ne bloque jamais : sans pub prête, rend la main aussitôt.
  Future<void> showIfAllowed() async {
    if (!_ref.read(showAdsProvider)) return;
    final allowed = interstitialAllowed(
      isFirstLaunch: _prefs.isFirstLaunch,
      lastShownAt: _prefs.lastInterstitialAt,
      now: DateTime.now(),
      minInterval: _config.interstitialMinInterval,
    );
    if (!allowed) return;

    final ad = _ad;
    if (ad == null) {
      preload();
      return;
    }
    _ad = null;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await _prefs.setLastInterstitialAt(DateTime.now());
    await ad.show();
    await closed.future.timeout(const Duration(minutes: 2), onTimeout: () {});
    preload();
  }
}

final interstitialManagerProvider =
    Provider<InterstitialManager>(InterstitialManager.new);
