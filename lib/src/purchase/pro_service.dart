import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../config/app_config.dart';
import '../storage/prefs.dart';

/// Résultat d'une tentative d'achat ou de restauration.
enum ProActionResult { success, pending, cancelled, unavailable, error }

/// État « Pro » (achat unique non consommable), persistant.
///
/// L'état est mis en cache localement pour être connu dès le démarrage, puis
/// confirmé par le flux d'achats de la boutique.
class ProState extends Notifier<bool> {
  StreamSubscription<List<PurchaseDetails>>? _sub;
  Completer<ProActionResult>? _pending;

  @override
  bool build() {
    ref.onDispose(() => _sub?.cancel());
    if (AppConfig.mobileServicesAvailable) {
      _sub = InAppPurchase.instance.purchaseStream.listen(
        _onPurchases,
        onError: (Object e) => debugPrint('Achats : $e'),
      );
    }
    return ref.read(appPrefsProvider).isPro;
  }

  String get _productId => ref.read(appConfigProvider).proProductId;

  Future<void> _setPro(bool value) async {
    state = value;
    await ref.read(appPrefsProvider).setPro(value);
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != _productId) continue;
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setPro(true);
          _finish(ProActionResult.success);
        case PurchaseStatus.pending:
          _finish(ProActionResult.pending);
        case PurchaseStatus.canceled:
          _finish(ProActionResult.cancelled);
        case PurchaseStatus.error:
          debugPrint('Achat : ${p.error?.message}');
          _finish(ProActionResult.error);
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  void _finish(ProActionResult r) {
    final c = _pending;
    if (c != null && !c.isCompleted) c.complete(r);
  }

  /// Prix localisé du produit (« 4,99 € »), ou `null` si inconnu.
  Future<String?> fetchPrice() async {
    final details = await _productDetails();
    return details?.price;
  }

  Future<ProductDetails?> _productDetails() async {
    if (!AppConfig.mobileServicesAvailable) return null;
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return null;
    final response = await iap.queryProductDetails({_productId});
    return response.productDetails.isEmpty
        ? null
        : response.productDetails.first;
  }

  /// Lance l'achat. Dans l'aperçu web, l'achat est simulé.
  Future<ProActionResult> buy() async {
    if (!AppConfig.mobileServicesAvailable) {
      await _setPro(true);
      return ProActionResult.success;
    }
    final details = await _productDetails();
    if (details == null) return ProActionResult.unavailable;
    _pending = Completer<ProActionResult>();
    final started = await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
    if (!started) return ProActionResult.error;
    return _pending!.future
        .timeout(const Duration(minutes: 5), onTimeout: () => ProActionResult.pending);
  }

  /// Restaure un achat fait sur un autre appareil ou avant réinstallation.
  Future<ProActionResult> restore() async {
    if (!AppConfig.mobileServicesAvailable) return ProActionResult.unavailable;
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return ProActionResult.unavailable;
    _pending = Completer<ProActionResult>();
    await iap.restorePurchases();
    // Sans achat à restaurer, la boutique ne renvoie rien.
    return _pending!.future.timeout(const Duration(seconds: 15),
        onTimeout: () => state ? ProActionResult.success : ProActionResult.cancelled);
  }

  /// Revérifie silencieusement les achats au démarrage (Android uniquement :
  /// sur iOS, la restauration peut demander le mot de passe Apple).
  Future<void> refreshFromStore() async {
    if (!AppConfig.mobileServicesAvailable ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      if (await InAppPurchase.instance.isAvailable()) {
        await InAppPurchase.instance.restorePurchases();
      }
    } catch (e) {
      debugPrint('Achats : $e');
    }
  }

  /// Uniquement pour les tests et l'aperçu web.
  @visibleForTesting
  Future<void> debugSetPro(bool value) => _setPro(value);
}

final isProProvider = NotifierProvider<ProState, bool>(ProState.new);
