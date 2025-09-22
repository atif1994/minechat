import 'dart:io';

class ImageParser {
  /// Parse image URLs from AI response text
  static List<String> extractImageUrls(String text) {
    final List<String> imageUrls = [];
    
    print('🔍 ImageParser: Analyzing text for images...');
    print('🔍 Text length: ${text.length}');
    print('🔍 Text preview: ${text.length > 200 ? text.substring(0, 200) + '...' : text}');
    
    // Look for markdown image syntax: ![alt text](image_url) or ![alt text] (image_url)
    final RegExp markdownImagePattern = RegExp(
      r'!\[([^\]]*)\]\s*\(([^)]+)\)',
      caseSensitive: false,
    );
    
    // Also look for any text that looks like markdown images with more flexible matching
    final RegExp flexibleImagePattern = RegExp(
      r'!\[[^\]]*\]\s*\([^)]+\)',
      caseSensitive: false,
    );
    
    final markdownMatches = markdownImagePattern.allMatches(text);
    print('🔍 Found ${markdownMatches.length} markdown image matches');
    
        for (final match in markdownMatches) {
          final altText = match.group(1);
          final url = match.group(2);
          print('🔍 Match - Alt: "$altText", URL: "$url"');
          
          if (url != null && !imageUrls.contains(url)) {
            // Clean the URL by removing leading/trailing whitespace
            final cleanUrl = url.trim();
            print('🔍 Found markdown image: $cleanUrl');
            // Check if it's a local file path and convert to file:// URL
            if (cleanUrl.startsWith('/') && !cleanUrl.startsWith('file://')) {
              final fileUrl = 'file://$cleanUrl';
              print('🔍 Converting local path to file URL: $cleanUrl -> $fileUrl');
              imageUrls.add(fileUrl);
            } else {
              imageUrls.add(cleanUrl);
            }
          }
        }
    
    // Try the flexible pattern if no matches found
    if (imageUrls.isEmpty) {
      print('🔍 No matches with strict pattern, trying flexible pattern...');
      final flexibleMatches = flexibleImagePattern.allMatches(text);
      print('🔍 Found ${flexibleMatches.length} flexible matches');
      
      for (final match in flexibleMatches) {
        final fullMatch = match.group(0);
        print('🔍 Flexible match: "$fullMatch"');
        
            // Try to extract URL from the match
            final urlMatch = RegExp(r'\(([^)]+)\)').firstMatch(fullMatch ?? '');
            if (urlMatch != null) {
              final url = urlMatch.group(1);
              if (url != null && !imageUrls.contains(url)) {
                // Clean the URL by removing leading/trailing whitespace
                final cleanUrl = url.trim();
                print('🔍 Extracted URL from flexible match: $cleanUrl');
                if (cleanUrl.startsWith('/') && !cleanUrl.startsWith('file://')) {
                  final fileUrl = 'file://$cleanUrl';
                  print('🔍 Converting flexible local path to file URL: $cleanUrl -> $fileUrl');
                  imageUrls.add(fileUrl);
                } else {
                  imageUrls.add(cleanUrl);
                }
              }
            }
      }
    }
    
    // Look for common image URL patterns
    final RegExp imageUrlPattern = RegExp(
      r'https?://[^\s]+\.(jpg|jpeg|png|gif|webp|bmp|svg)(\?[^\s]*)?',
      caseSensitive: false,
    );
    
    final matches = imageUrlPattern.allMatches(text);
    for (final match in matches) {
      final url = match.group(0);
      if (url != null && !imageUrls.contains(url)) {
        imageUrls.add(url);
      }
    }
    
    // Look for local file paths with file:// prefix
    final RegExp fileUrlPattern = RegExp(
      r'file://[^\s]*\.(jpg|jpeg|png|gif|webp|bmp|svg)',
      caseSensitive: false,
    );
    
    final fileUrlMatches = fileUrlPattern.allMatches(text);
    for (final match in fileUrlMatches) {
      final path = match.group(0);
      if (path != null && !imageUrls.contains(path)) {
        imageUrls.add(path);
      }
    }
    
    // Look for local file paths without file:// prefix (Android cache paths)
    // Only if we haven't already found them through markdown parsing
    final RegExp localPathPattern = RegExp(
      r'/[^\s]*\.(jpg|jpeg|png|gif|webp|bmp|svg)',
      caseSensitive: false,
    );
    
    final localMatches = localPathPattern.allMatches(text);
    for (final match in localMatches) {
      final path = match.group(0);
      if (path != null) {
        // Clean the path by removing leading/trailing whitespace
        final cleanPath = path.trim();
        // Convert to file:// URL for proper handling
        final fileUrl = 'file://$cleanPath';
        // Only add if not already present (avoid duplicates from markdown parsing)
        if (!imageUrls.contains(fileUrl)) {
          print('🔍 Found direct local image path: $cleanPath -> $fileUrl');
          imageUrls.add(fileUrl);
        }
      }
    }
    
    print('🔍 Total images found: ${imageUrls.length}');
    print('🔍 Image URLs: $imageUrls');
    
    return imageUrls;
  }
  
  /// Check if a URL is a valid image URL
  static bool isValidImageUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      return path.endsWith('.jpg') || 
             path.endsWith('.jpeg') || 
             path.endsWith('.png') || 
             path.endsWith('.gif') || 
             path.endsWith('.webp') || 
             path.endsWith('.bmp') || 
             path.endsWith('.svg');
    } catch (e) {
      return false;
    }
  }
  
  /// Remove image URLs from text to get clean text
  static String removeImageUrls(String text) {
    String cleanText = text;
    
    // Remove markdown image syntax: ![alt text](image_url) or ![alt text] (image_url)
    final RegExp markdownImagePattern = RegExp(
      r'!\[([^\]]*)\]\s*\(([^)]+)\)',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(markdownImagePattern, '');
    
    // Also remove flexible pattern matches
    final RegExp flexibleImagePattern = RegExp(
      r'!\[[^\]]*\]\s*\([^)]+\)',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(flexibleImagePattern, '');
    
    // Remove HTTP/HTTPS image URLs
    final RegExp imageUrlPattern = RegExp(
      r'https?://[^\s]+\.(jpg|jpeg|png|gif|webp|bmp|svg)(\?[^\s]*)?',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(imageUrlPattern, '');
    
    // Remove file:// URLs
    final RegExp fileUrlPattern = RegExp(
      r'file://[^\s]*\.(jpg|jpeg|png|gif|webp|bmp|svg)',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(fileUrlPattern, '');
    
    // Remove local file paths without file:// prefix
    final RegExp localPathPattern = RegExp(
      r'/[^\s]*\.(jpg|jpeg|png|gif|webp|bmp|svg)',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(localPathPattern, '');
    
    // Clean up extra whitespace
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleanText;
  }
  
  /// Test method to verify regex patterns work correctly
  static void testImageParsing() {
    final testText = 'Here is an image: ![Brand](/data/user/0/com.minechatapp.minechat/cache/1e67ce42-38a7-4d38-b103-3687b3657967/1000187925.jpg) and another ![Clothes](/data/user/0/com.minechatapp.minechat/cache/b68037ba-6713-4f1e-9542-c7ac22320320/1000186061.jpg)';
    
    print('🧪 Testing image parsing with: $testText');
    final urls = extractImageUrls(testText);
    print('🧪 Found URLs: $urls');
    
    final cleanText = removeImageUrls(testText);
    print('🧪 Clean text: $cleanText');
    
    // Test the regex pattern directly
    final RegExp markdownImagePattern = RegExp(
      r'!\[([^\]]*)\]\s*\(([^)]+)\)',
      caseSensitive: false,
    );
    
    final matches = markdownImagePattern.allMatches(testText);
    print('🧪 Direct regex test found ${matches.length} matches');
    for (final match in matches) {
      print('🧪 Match: "${match.group(0)}"');
      print('🧪 Alt: "${match.group(1)}"');
      print('🧪 URL: "${match.group(2)}"');
    }
  }
}
