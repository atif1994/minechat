import 'package:url_launcher/url_launcher.dart' as url_launcher;

class UrlLauncherService {
  static Future<bool> launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      print('🔗 Attempting to launch URL: $urlString');
      
      // Try the most reliable method first - external application
      try {
        print('🔄 Trying external application mode');
        final bool launched = await url_launcher.launchUrl(
          url, 
          mode: url_launcher.LaunchMode.externalApplication,
        );
        if (launched) {
          print('✅ Successfully launched URL with external application mode');
          return true;
        }
      } catch (e) {
        print('❌ External application mode failed: $e');
      }
      
      // Try platform default
      try {
        print('🔄 Trying platform default mode');
        final bool launched = await url_launcher.launchUrl(
          url, 
          mode: url_launcher.LaunchMode.platformDefault,
        );
        if (launched) {
          print('✅ Successfully launched URL with platform default mode');
          return true;
        }
      } catch (e) {
        print('❌ Platform default mode failed: $e');
      }
      
      // Try without mode specification (legacy approach)
      try {
        print('🔄 Trying without mode specification');
        final bool launched = await url_launcher.launchUrl(url);
        if (launched) {
          print('✅ Successfully launched URL without mode');
          return true;
        }
      } catch (e) {
        print('❌ Launch without mode failed: $e');
      }
      
      print('❌ All launch attempts failed for URL: $urlString');
      return false;
    } catch (e) {
      print('❌ Error launching URL $urlString: $e');
      return false;
    }
  }
  
  static Future<bool> launchTermsAndConditions() async {
    return await launchUrl('https://www.minechat.ai/terms.html');
  }
  
  static Future<bool> launchPrivacyPolicy() async {
    return await launchUrl('https://www.minechat.ai/privacy.html');
  }
}
