import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import '../consent/consent_service.dart';
import '../purchase/pro_service.dart';

/// Vrai une fois le SDK pub initialisé, ce qui n'arrive qu'après le
/// consentement. Tant que c'est faux, aucune pub n'est chargée.
class AdsReady extends Notifier<bool> {
  @override
  bool build() => false;

  /// Recueille le consentement puis initialise le SDK si c'est permis.
  Future<void> start() async {
    if (state) return;
    final allowed = await ref.read(consentServiceProvider).gather();
    if (!allowed) return;
    if (AppConfig.mobileServicesAvailable) {
      await MobileAds.instance.initialize();
    }
    state = true;
  }
}

final adsReadyProvider = NotifierProvider<AdsReady, bool>(AdsReady.new);

/// Vrai si l'appli doit afficher des pubs : SDK prêt et utilisateur non Pro.
final showAdsProvider = Provider<bool>(
  (ref) => ref.watch(adsReadyProvider) && !ref.watch(isProProvider),
);
