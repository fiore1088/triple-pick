import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';

class DeepLinkService {
  static const Map<String, Map<String, String>> _appSchemes = {
    'Netflix': {'ios': 'netflix://www.netflix.com/title/{id}', 'android': 'netflix://www.netflix.com/title/{id}', 'web': 'https://www.netflix.com/title/{id}'},
    'Prime Video': {'ios': 'amazon://detail?asin={id}', 'android': 'intent://detail?asin={id}#Intent;scheme=amazon;package=com.amazon.avod;end', 'web': 'https://www.amazon.com/dp/{id}'},
    'Disney+': {'ios': 'disneyplus://brand/{id}', 'android': 'disneyplus://brand/{id}', 'web': 'https://www.disneyplus.com/brand/{id}'},
    'Apple TV+': {'ios': 'tv://{id}', 'android': 'https://tv.apple.com/show/{id}', 'web': 'https://tv.apple.com/show/{id}'},
    '.now': {'ios': 'nowtv://watch/{id}', 'android': 'nowtv://watch/{id}', 'web': 'https://www.nowtv.it/watch/{id}'},
    'Infinity': {'ios': 'infinity://watch/{id}', 'android': 'infinity://watch/{id}', 'web': 'https://www.infinitywar.com/{id}'},
  };

  static const Map<String, PlatformInfo> _platformInfo = {
    'Netflix': PlatformInfo(name: 'Netflix', brandColor: '0xFFE50914', appStoreId: '363470064', playStoreId: 'com.netflix.mediaclient', universalLink: 'https://www.netflix.com/title/'),
    'Prime Video': PlatformInfo(name: 'Prime Video', brandColor: '0xFF00A8E1', appStoreId: '545519333', playStoreId: 'com.amazon.avod', universalLink: 'https://www.amazon.com/dp/'),
    'Disney+': PlatformInfo(name: 'Disney+', brandColor: '0xFF113CCF', appStoreId: '1446075923', playStoreId: 'com.disney.disneyplus', universalLink: 'https://www.disneyplus.com/brand/'),
    'Apple TV+': PlatformInfo(name: 'Apple TV+', brandColor: '0xFF555555', appStoreId: '1174090839', playStoreId: 'com.apple.atve.androidtv.appletv', universalLink: 'https://tv.apple.com/show/'),
    '.now': PlatformInfo(name: '.now', brandColor: '0xFF6B2D8B', appStoreId: '979941392', playStoreId: 'it.nowtv.now', universalLink: 'https://www.nowtv.it/watch/'),
    'Infinity': PlatformInfo(name: 'Infinity', brandColor: '0xFFE4002B', appStoreId: '1256849169', playStoreId: 'com.wrap infinity', universalLink: 'https://www.infinitywar.com/'),
  };

  static Future<DeepLinkResult> launchContent({required String platform, required String contentId, required String fallbackUrl}) async {
    try {
      final platformSchemes = _appSchemes[platform];
      if (platformSchemes == null) return DeepLinkResult(success: false, error: 'Piattaforma non supportata: $platform', platform: platform);

      String scheme;
      if (Platform.isIOS) { scheme = platformSchemes['ios']!; }
      else if (Platform.isAndroid) { scheme = platformSchemes['android']!; }
      else { scheme = platformSchemes['web']!; }

      final appUrl = scheme.replaceFirst('{id}', contentId);
      final appUri = Uri.parse(appUrl);

      if (await canLaunchUrl(appUri)) {
        final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
        if (launched) return DeepLinkResult(success: true, openedWith: 'app', platform: platform);
      }

      final fallbackUri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(fallbackUri)) {
        final launched = await launchUrl(fallbackUri, mode: LaunchMode.inAppWebView);
        if (launched) return DeepLinkResult(success: true, openedWith: 'web', platform: platform);
      }

      return DeepLinkResult(success: false, error: 'Impossibile aprire il link', platform: platform);
    } catch (e) {
      return DeepLinkResult(success: false, error: "Errore nell'apertura del link: \$e", platform: platform);
    }
  }

  static Future<bool> isPlatformAppInstalled(String platform) async {
    final platformSchemes = _appSchemes[platform];
    if (platformSchemes == null) return false;
    String scheme;
    if (Platform.isIOS) { scheme = platformSchemes['ios']!; }
    else if (Platform.isAndroid) { scheme = platformSchemes['android']!; }
    else { return false; }
    final testUrl = scheme.replaceFirst('{id}', 'test');
    return await canLaunchUrl(Uri.parse(testUrl));
  }

  static PlatformInfo? getPlatformInfo(String platform) => _platformInfo[platform];
  static List<String> get supportedPlatforms => _appSchemes.keys.toList();

  static String generateDeepLink({required String platform, required String contentId}) {
    final platformSchemes = _appSchemes[platform];
    if (platformSchemes == null) return '';
    String scheme;
    if (Platform.isIOS) { scheme = platformSchemes['ios']!; }
    else if (Platform.isAndroid) { scheme = platformSchemes['android']!; }
    else { scheme = platformSchemes['web']!; }
    return scheme.replaceFirst('{id}', contentId);
  }

  static String getStoreUrl(String platform) {
    final info = _platformInfo[platform];
    if (info == null) return '';
    if (Platform.isIOS) { return 'https://apps.apple.com/app/id\${info.appStoreId}'; }
    else if (Platform.isAndroid) { return 'https://play.google.com/store/apps/details?id=\${info.playStoreId}'; }
    return '';
  }
}

class DeepLinkResult {
  final bool success;
  final String? error;
  final String? openedWith;
  final String platform;
  const DeepLinkResult({required this.success, this.error, this.openedWith, required this.platform});
  @override
  String toString() => 'DeepLinkResult(success: \$success, platform: \$platform, openedWith: \$openedWith)';
}

class PlatformInfo {
  final String name;
  final String brandColor;
  final String appStoreId;
  final String playStoreId;
  final String universalLink;
  const PlatformInfo({required this.name, required this.brandColor, required this.appStoreId, required this.playStoreId, required this.universalLink});
}