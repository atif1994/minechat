import 'dart:io';

class ImageParser {
  /// Parse image URLs from AI response text
  static List<String> extractImageUrls(String text) {
    final List<String> imageUrls = [];
    
    // Look for markdown image syntax: ![alt text](image_url)
    final RegExp markdownImagePattern = RegExp(
      r'!\[([^\]]*)\]\(([^)]+)\)',
      caseSensitive: false,
    );
    
    final markdownMatches = markdownImagePattern.allMatches(text);
    for (final match in markdownMatches) {
      final url = match.group(2); // Get the URL from the parentheses
      if (url != null && !imageUrls.contains(url)) {
        imageUrls.add(url);
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
    
    // Also look for local file paths (for development/testing)
    final RegExp localPathPattern = RegExp(
      r'file://[^\s]*\.(jpg|jpeg|png|gif|webp|bmp|svg)',
      caseSensitive: false,
    );
    
    final localMatches = localPathPattern.allMatches(text);
    for (final match in localMatches) {
      final path = match.group(0);
      if (path != null && !imageUrls.contains(path)) {
        imageUrls.add(path);
      }
    }
    
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
    
    // Remove markdown image syntax: ![alt text](image_url)
    final RegExp markdownImagePattern = RegExp(
      r'!\[([^\]]*)\]\(([^)]+)\)',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(markdownImagePattern, '');
    
    // Remove HTTP/HTTPS image URLs
    final RegExp imageUrlPattern = RegExp(
      r'https?://[^\s]+\.(jpg|jpeg|png|gif|webp|bmp|svg)(\?[^\s]*)?',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(imageUrlPattern, '');
    
    // Remove local file paths
    final RegExp localPathPattern = RegExp(
      r'file://[^\s]*\.(jpg|jpeg|png|gif|webp|bmp|svg)',
      caseSensitive: false,
    );
    
    cleanText = cleanText.replaceAll(localPathPattern, '');
    
    // Clean up extra whitespace
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleanText;
  }
}
