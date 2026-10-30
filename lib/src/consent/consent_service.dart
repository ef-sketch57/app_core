import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';

/// Consentement RGPD via Google UMP (User Messaging Platform).
///
/// [gather] doit être appelé à chaque lancement (exigence de Google), et au
/// premier lancement juste après l'onboarding, avant tout chargement de pub.
class ConsentService {
  /// Met à jour l'état du consentement et affiche le formulaire si besoin.
  /// Renvoie `true` si l'appli a le droit de demander des pubs.
  Future<bool> gather() async {
    if (!AppConfig.mobileServicesAvailable) return true;
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => updated.complete(),
        (error) => updated.completeError(error.message),
      );
      await updated.future;

      final dismissed = Completer<void>();
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) debugPrint('UMP : ${error.message}');
        dismissed.complete();
      });
      await dismissed.future;
    } catch (e) {
      // Hors ligne ou erreur UMP : on se fie au dernier consentement connu.
      debugPrint('UMP indisponible : $e');
    }
    return canRequestAds();
  }

  Future<bool> canRequestAds() async {
    if (!AppConfig.mobileServicesAvailable) return true;
    return ConsentInformation.instance.canRequestAds();
  }

  /// Vrai si l'utilisateur doit pouvoir modifier ses choix (zone RGPD).
  Future<bool> privacyOptionsRequired() async {
    if (!AppConfig.mobileServicesAvailable) return false;
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// Rouvre le formulaire « Gérer mes choix ».
  Future<void> showPrivacyOptions() async {
    if (!AppConfig.mobileServicesAvailable) return;
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('UMP : ${error.message}');
      done.complete();
    });
    return done.future;
  }
}

final consentServiceProvider = Provider<ConsentService>((ref) => ConsentService());
