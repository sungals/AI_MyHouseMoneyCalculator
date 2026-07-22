import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/ads/ad_unit_ids.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ResultAdBanner extends StatefulWidget {
  final bool enabled;

  const ResultAdBanner({
    super.key,
    this.enabled = true,
  });

  @override
  State<ResultAdBanner> createState() => _ResultAdBannerState();
}

class _ResultAdBannerState extends State<ResultAdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool get _canLoadAds =>
      widget.enabled &&
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS) &&
      AdUnitIds.hasApplicationId &&
      AdUnitIds.hasResultBannerId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ResultAdBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      _load();
    }
  }

  void _load() {
    if (!_canLoadAds) return;

    final ad = BannerAd(
      adUnitId: AdUnitIds.resultBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canLoadAds || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            const Text('광고', style: AppTextStyles.caption),
            const SizedBox(height: 6),
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ],
        ),
      ),
    );
  }
}
