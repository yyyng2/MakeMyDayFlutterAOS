import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544/2247696110";
      if (kDebugMode) {
        return "ca-app-pub-3940256099942544/2247696110";
      } else if (kReleaseMode) {
        return "ca-app-pub-7183232535482605/1716038473";
      } else {
        throw UnsupportedError("Unknown mode");
      }

    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/3986624511";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static final NativeAdListener nativeAdListener = NativeAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad fail to load: $error');
    },
    onAdOpened: (ad) => debugPrint('Ad opened'),
    onAdClosed: (ad) => debugPrint('Ad closed'),
  );
}