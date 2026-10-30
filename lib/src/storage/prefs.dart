import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Petits réglages persistants communs à toutes les applis (drapeaux, dates).
/// Les données métier, elles, vont dans la base drift de chaque appli.
class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboardingDone = 'core.onboarding_done';
  static const _kLaunchCount = 'core.launch_count';
  static const _kLastInterstitial = 'core.last_interstitial_ms';
  static const _kIsPro = 'core.is_pro';

  static Future<AppPrefs> load() async =>
      AppPrefs(await SharedPreferences.getInstance());

  SharedPreferences get raw => _prefs;

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool(_kOnboardingDone, true);

  int get launchCount => _prefs.getInt(_kLaunchCount) ?? 0;

  /// Vrai pendant toute la session du tout premier lancement.
  late final bool isFirstLaunch = launchCount <= 1;

  /// À appeler une fois au démarrage, avant de lire [isFirstLaunch].
  Future<void> registerLaunch() =>
      _prefs.setInt(_kLaunchCount, launchCount + 1);

  DateTime? get lastInterstitialAt {
    final ms = _prefs.getInt(_kLastInterstitial);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastInterstitialAt(DateTime t) =>
      _prefs.setInt(_kLastInterstitial, t.millisecondsSinceEpoch);

  bool get isPro => _prefs.getBool(_kIsPro) ?? false;
  Future<void> setPro(bool value) => _prefs.setBool(_kIsPro, value);
}

/// À surcharger dans `main()` avec `await AppPrefs.load()`.
final appPrefsProvider = Provider<AppPrefs>(
  (ref) => throw UnimplementedError('appPrefsProvider doit être surchargé'),
);
