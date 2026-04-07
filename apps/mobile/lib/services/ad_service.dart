import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// All ad-unit IDs in one place.
/// Pass real IDs at build time via --dart-define (see PRODUCTION.md).
/// Defaults are Google's official test IDs — safe for development.
abstract final class AdIds {
  // ── iOS ───────────────────────────────────────────────────────────────────
  static const _iosBannerStation = String.fromEnvironment(
    'ADMOB_IOS_BANNER_STATION',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );
  static const _iosRewardedSave = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_SAVE',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313',
  );
  static const _iosBannerFriends = String.fromEnvironment(
    'ADMOB_IOS_BANNER_FRIENDS',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  // ── Android ───────────────────────────────────────────────────────────────
  static const _androidBannerStation = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_STATION',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const _androidRewardedSave = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_SAVE',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const _androidBannerFriends = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_FRIENDS',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );

  static String get bannerStation =>
      Platform.isIOS ? _iosBannerStation : _androidBannerStation;
  static String get rewardedSave =>
      Platform.isIOS ? _iosRewardedSave : _androidRewardedSave;
  static String get bannerFriends =>
      Platform.isIOS ? _iosBannerFriends : _androidBannerFriends;
}

/// Manages the rewarded-ad lifecycle: preloading and showing.
///
/// Banners manage themselves inside [StationBannerWidget] / [FriendsBannerWidget]
/// because their lifetimes are tied to widget trees.
class AdService {
  RewardedAd? _rewardedSaveAd;
  bool _rewardedLoading = false;

  /// Initialise the SDK once at app startup.
  static Future<void> initialise() async {
    await MobileAds.instance.initialize();
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: const ['EMULATOR']),
      );
    }
  }

  /// Start loading the rewarded ad in the background.
  /// Call when the workout begins so it is ready when the user finishes.
  void preloadSaveAd() {
    if (_rewardedSaveAd != null || _rewardedLoading) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdIds.rewardedSave,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedSaveAd = ad;
          _rewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: rewarded failed — ${error.message}');
          _rewardedLoading = false;
        },
      ),
    );
  }

  /// Shows the rewarded save-gate ad. Returns true if the user earned the
  /// reward (watched enough of it), false if unavailable or dismissed early.
  ///
  /// IMPORTANT: always save the workout regardless of return value — never
  /// punish the user for AdMob availability issues.
  Future<bool> showSaveRewardedAd() async {
    final ad = _rewardedSaveAd;
    if (ad == null) return false;

    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _rewardedSaveAd = null;
        completer.complete(rewarded);
        preloadSaveAd(); // reload for next time
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _rewardedSaveAd = null;
        completer.complete(false);
        preloadSaveAd();
      },
    );

    await ad.show(onUserEarnedReward: (_, __) => rewarded = true);
    return completer.future;
  }

  void dispose() {
    _rewardedSaveAd?.dispose();
    _rewardedSaveAd = null;
  }
}
