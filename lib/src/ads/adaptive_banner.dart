import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';
import 'ads_service.dart';

/// Bannière adaptative ancrée, pleine largeur. Ne prend aucune place si
/// l'utilisateur est Pro ou si le consentement n'a pas été donné.
class AdaptiveBanner extends ConsumerWidget {
  const AdaptiveBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showAdsProvider)) return const SizedBox.shrink();
    if (!AppConfig.mobileServicesAvailable) return const _BannerPlaceholder();
    return LayoutBuilder(
      builder: (context, constraints) => _LoadedBanner(
        key: ValueKey(constraints.maxWidth.truncate()),
        width: constraints.maxWidth.truncate(),
        adUnitId: ref.watch(appConfigProvider).adUnits.banner,
      ),
    );
  }
}

class _LoadedBanner extends StatefulWidget {
  const _LoadedBanner({super.key, required this.width, required this.adUnitId});

  final int width;
  final String adUnitId;

  @override
  State<_LoadedBanner> createState() => _LoadedBannerState();
}

class _LoadedBannerState extends State<_LoadedBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widget.width);
    if (size == null || !mounted) return;
    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Bannière : ${error.message}');
          ad.dispose();
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}

/// Emplacement factice affiché dans l'aperçu web.
class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.subtle,
        border: Border.all(color: p.border),
      ),
      child: Text('Bannière AdMob (simulée)',
          style: TextStyle(color: p.muted, fontSize: 12)),
    );
  }
}
