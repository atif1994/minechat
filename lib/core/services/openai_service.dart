// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/app_config.dart';
// import '../../model/data/ai_knowledge_model.dart';
// import '../../model/data/product_service_model.dart';
// import '../../model/data/faq_model.dart';
//
// class OpenAIService {
//   static const String _baseUrl = AppConfig.openaiBaseUrl;
//   static const String _apiKey = AppConfig.openaiApiKey;
//
//   static Future<String> generateResponse({
//     required String userMessage,
//     required String assistantName,
//     required String introMessage,
//     required String shortDescription,
//     required String aiGuidelines,
//     required String responseLength,
//   }) async {
//     return generateResponseWithKnowledge(
//       userMessage: userMessage,
//       assistantName: assistantName,
//       introMessage: introMessage,
//       shortDescription: shortDescription,
//       aiGuidelines: aiGuidelines,
//       responseLength: responseLength,
//     );
//   }
//
//   static Future<String> generateResponseWithKnowledge({
//     required String userMessage,
//     required String assistantName,
//     required String introMessage,
//     required String shortDescription,
//     required String aiGuidelines,
//     required String responseLength,
//     AIKnowledgeModel? businessInfo,
//     List<ProductServiceModel>? productsServices,
//     List<FAQModel>? faqs,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_apiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-3.5-turbo',
//           'messages': [
//             {
//               'role': 'system',
//               'content': _buildEnhancedSystemPrompt(
//                 assistantName: assistantName,
//                 introMessage: introMessage,
//                 shortDescription: shortDescription,
//                 aiGuidelines: aiGuidelines,
//                 responseLength: responseLength,
//                 businessInfo: businessInfo,
//                 productsServices: productsServices,
//                 faqs: faqs,
//               ),
//             },
//             {
//               'role': 'user',
//               'content': userMessage,
//             },
//           ],
//           'max_tokens': _getMaxTokens(responseLength),
//           'temperature': 0.7,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final content = data['choices'][0]['message']['content'];
//         if (content != null && content.isNotEmpty) {
//           return content;
//         } else {
//           print('OpenAI API returned empty content');
//           return 'Sorry, I could not generate a response.';
//         }
//       } else {
//         print('OpenAI API Error: ${response.statusCode} - ${response.body}');
//         if (response.statusCode == 401) {
//           return 'Authentication error. Please check your API key.';
//         } else if (response.statusCode == 429) {
//           return 'Rate limit exceeded. Please try again later.';
//         } else {
//           return 'Sorry, I encountered an error. Please try again.';
//         }
//       }
//     } catch (e) {
//       print('OpenAI Service Error: $e');
//       return 'Sorry, I encountered an error. Please try again.';
//     }
//   }
//
//   static String _buildSystemPrompt({
//     required String assistantName,
//     required String introMessage,
//     required String shortDescription,
//     required String aiGuidelines,
//     required String responseLength,
//   }) {
//     return _buildEnhancedSystemPrompt(
//       assistantName: assistantName,
//       introMessage: introMessage,
//       shortDescription: shortDescription,
//       aiGuidelines: aiGuidelines,
//       responseLength: responseLength,
//     );
//   }
//
//   static String _buildEnhancedSystemPrompt({
//     required String assistantName,
//     required String introMessage,
//     required String shortDescription,
//     required String aiGuidelines,
//     required String responseLength,
//     AIKnowledgeModel? businessInfo,
//     List<ProductServiceModel>? productsServices,
//     List<FAQModel>? faqs,
//   }) {
//     String prompt = '''
// You are $assistantName, an AI assistant with the following characteristics:
//
// Introduction: $introMessage
// Description: $shortDescription
// Guidelines: $aiGuidelines
//
// Response Style: ${_getResponseStyle(responseLength)}
//
// Please respond as $assistantName, following the guidelines and maintaining the specified response length. Be helpful, friendly, and professional according to the guidelines provided.
// ''';
//
//     // Add Business Information
//     if (businessInfo != null) {
//       prompt += '''
//
// BUSINESS INFORMATION:
// Business Name: ${businessInfo.businessName}
// Phone: ${businessInfo.phone}
// Address: ${businessInfo.address}
// Email: ${businessInfo.email}
// Company Story: ${businessInfo.companyStory}
// Payment Details: ${businessInfo.paymentDetails}
// Discounts: ${businessInfo.discounts}
// Policy: ${businessInfo.policy}
// Additional Notes: ${businessInfo.additionalNotes}
// Thank You Message: ${businessInfo.thankYouMessage}
// ''';
//     }
//
//     // Add Products & Services
//     if (productsServices != null && productsServices.isNotEmpty) {
//       prompt += '\n\nPRODUCTS & SERVICES:\n';
//       for (int i = 0; i < productsServices.length; i++) {
//         final product = productsServices[i];
//         prompt += '''
// ${i + 1}. Name: ${product.name}
//    Description: ${product.description}
//    Price: ${product.price}
//    Category: ${product.category}
//    Features: ${product.features}
// ''';
//       }
//     }
//
//     // Add FAQs
//     if (faqs != null && faqs.isNotEmpty) {
//       prompt += '\n\nFREQUENTLY ASKED QUESTIONS:\n';
//       for (int i = 0; i < faqs.length; i++) {
//         final faq = faqs[i];
//         prompt += '''
// ${i + 1}. Q: ${faq.question}
//    A: ${faq.answer}
//    Category: ${faq.category}
// ''';
//       }
//     }
//
//     prompt += '''
//
// INSTRUCTIONS:
// - Use the business information to answer questions about the company
// - Use the products/services information to help customers with product inquiries
// - Use the FAQs to provide quick answers to common questions
// - If a question matches an FAQ, provide the exact answer from the FAQ
// - Always be helpful, professional, and maintain the assistant's personality
// - If you don't have information about something, politely say so and offer to help with what you do know
// ''';
//
//     return prompt;
//   }
//
//   static String _getResponseStyle(String responseLength) {
//     switch (responseLength) {
//       case 'Short':
//         return 'Keep responses concise and to the point (1-2 sentences).';
//       case 'Long':
//         return 'Provide detailed, comprehensive responses with examples when helpful.';
//       default:
//         return 'Provide balanced responses that are neither too short nor too long.';
//     }
//   }
//
//   static int _getMaxTokens(String responseLength) {
//     switch (responseLength) {
//       case 'Short':
//         return 100;
//       case 'Long':
//         return 500;
//       default:
//         return 250;
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../../model/data/ai_knowledge_model.dart';
import '../../model/data/product_service_model.dart';
import '../../model/data/faq_model.dart';

class OpenAIService {
  static const String _proxyUrl = AppConfig.apiProxyUrl;

  // Using server proxy for secure API calls

  static Future<String> generateResponse({
    required String userMessage,
    required String assistantName,
    required String introMessage,
    required String shortDescription,
    required String aiGuidelines,
    required String responseLength,
  }) async {
    return generateResponseWithKnowledge(
      userMessage: userMessage,
      assistantName: assistantName,
      introMessage: introMessage,
      shortDescription: shortDescription,
      aiGuidelines: aiGuidelines,
      responseLength: responseLength,
    );
  }

  /// Generate response with file attachment support
  static Future<String> generateResponseWithFile({
    required String userMessage,
    required String assistantName,
    required String introMessage,
    required String shortDescription,
    required String aiGuidelines,
    required String responseLength,
    required File attachedFile,
    required String fileType,
    AIKnowledgeModel? businessInfo,
    List<ProductServiceModel>? productsServices,
    List<FAQModel>? faqs,
  }) async {
    try {
      String fileContent;
      
      if (fileType == 'image') {
        // Convert image to base64 for OpenAI Vision API
        fileContent = await _encodeImageToBase64(attachedFile);
      } else {
        // Extract text from document
        fileContent = await _extractTextFromFile(attachedFile);
      }

      final response = await http
          .post(
            Uri.parse(_proxyUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': fileType == 'image' ? 'gpt-4o-mini' : 'gpt-4o-mini',
              'messages': [
                {
                  'role': 'system',
                  'content': _buildFileAnalysisSystemPrompt(
                    assistantName: assistantName,
                    introMessage: introMessage,
                    shortDescription: shortDescription,
                    aiGuidelines: aiGuidelines,
                    responseLength: responseLength,
                    fileType: fileType,
                    businessInfo: businessInfo,
                    productsServices: productsServices,
                    faqs: faqs,
                  ),
                },
                {
                  'role': 'user',
                  'content': fileType == 'image' 
                    ? [
                        {
                          'type': 'text',
                          'text': userMessage.isEmpty ? 'Please analyze this image and tell me what you see.' : userMessage,
                        },
                        {
                          'type': 'image_url',
                          'image_url': {
                            'url': 'data:image/jpeg;base64,$fileContent',
                          },
                        },
                      ]
                    : 'File content:\n$fileContent\n\nUser question: ${userMessage.isEmpty ? "Please analyze this document and provide insights." : userMessage}',
                },
              ],
              'max_tokens': _getMaxTokens(responseLength),
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['choices'][0]['message']['content'] ?? 'No response generated.';
        
        // CRITICAL FIX: Remove any Firebase Storage URLs that might slip through
        aiResponse = _removeFirebaseUrls(aiResponse);
        
        return aiResponse;
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in generateResponseWithFile: $e');
      throw Exception('Failed to process file: $e');
    }
  }

  static Future<String> generateResponseWithKnowledge({
    required String userMessage,
    required String assistantName,
    required String introMessage,
    required String shortDescription,
    required String aiGuidelines,
    required String responseLength,
    AIKnowledgeModel? businessInfo,
    List<ProductServiceModel>? productsServices,
    List<FAQModel>? faqs,
    bool isFacebookChat = false, // NEW: Detect context
  }) async {
    try {
      final systemPrompt = _buildEnhancedSystemPrompt(
        assistantName: assistantName,
        introMessage: introMessage,
        shortDescription: shortDescription,
        aiGuidelines: aiGuidelines,
        responseLength: responseLength,
        businessInfo: businessInfo,
        productsServices: productsServices,
        faqs: faqs,
        isFacebookChat: isFacebookChat,
      );
      
      // DEBUG: Print system prompt to verify image instructions
      print('🤖 SYSTEM PROMPT DEBUG:');
      print('🤖   isFacebookChat: $isFacebookChat');
      print('🤖   Products count: ${productsServices?.length ?? 0}');
      if (productsServices != null && productsServices.isNotEmpty) {
        print('🤖   First product name: ${productsServices[0].name}');
        print('🤖   First product images: ${productsServices[0].images}');
        print('🤖   First product selectedImage: ${productsServices[0].selectedImage}');
      }
      print('🤖   System prompt length: ${systemPrompt.length} characters');
      if (systemPrompt.contains('MANDATORY IMAGE SYNTAX')) {
        print('🤖   ✅ System prompt contains MANDATORY IMAGE SYNTAX');
      } else {
        print('🤖   ❌ WARNING: System prompt does NOT contain MANDATORY IMAGE SYNTAX');
      }
      
      final response = await http
          .post(
            Uri.parse(_proxyUrl),
            headers: {
              'Content-Type': 'application/json',
              // auth handled by server
            },
            body: jsonEncode({
              'model': 'gpt-4o-mini',
              'messages': [
                {
                  'role': 'system',
                  'content': systemPrompt,
                },
                {
                  'role': 'user',
                  'content': userMessage,
                },
              ],
              'max_tokens': _getMaxTokens(responseLength),
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'];
        if (choices is List && choices.isNotEmpty) {
          final content = choices[0]?['message']?['content'];
          if (content is String && content.isNotEmpty) {
            // Enhanced Debug: Check AI response details
            print('🤖 AI RESPONSE DEBUG:');
            print('🤖   Response length: ${content.length} characters');
            print('🤖   First 200 chars: ${content.length > 200 ? content.substring(0, 200) : content}');
            print('🤖   Contains ![: ${content.contains('![')}');
            print('🤖   Contains markdown image: ${content.contains('![') && content.contains('](http')}');
            print('🤖   Contains firebasestorage: ${content.contains('firebasestorage.googleapis.com')}');
            
            // Extract and print any image URLs found
            final imageMarkdownPattern = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
            final matches = imageMarkdownPattern.allMatches(content);
            if (matches.isNotEmpty) {
              print('🤖   ✅ Found ${matches.length} image(s) in response:');
              for (final match in matches) {
                print('🤖      - Alt text: ${match.group(1)}');
                print('🤖      - URL: ${match.group(2)}');
              }
            } else {
              print('🤖   ❌ WARNING: No image markdown found in AI response!');
              print('🤖   This means images will NOT be sent to Facebook Messenger');
            }
            
            // CONTEXT-AWARE: Only clean URLs for Facebook chat
            if (isFacebookChat) {
              final cleanedContent = _removeFirebaseUrls(content);
              return cleanedContent;
            } else {
              // For app chat: Keep URLs for image display
              return content;
            }
          }
        }
        return 'Sorry, I could not generate a response.';
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 401) {
          return 'Auth error at proxy. Ask admin to check OPENAI_API_KEY secret.';
        } else if (response.statusCode == 429) {
          return 'Rate limit exceeded. Please try again later.';
        } else {
          return 'Sorry, I encountered an error. Please try again.';
        }
      }
    } catch (e) {
      print('OpenAI Service Error: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }


  static String _buildEnhancedSystemPrompt({
    required String assistantName,
    required String introMessage,
    required String shortDescription,
    required String aiGuidelines,
    required String responseLength,
    AIKnowledgeModel? businessInfo,
    List<ProductServiceModel>? productsServices,
    List<FAQModel>? faqs,
    bool isFacebookChat = false,
  }) {
    String prompt = '''
You are $assistantName, an AI assistant with the following characteristics:

Introduction: $introMessage
Description: $shortDescription
Guidelines: $aiGuidelines

Response Style: ${_getResponseStyle(responseLength)}

Please respond as $assistantName, following the guidelines and maintaining the specified response length. Be helpful, friendly, and professional according to the guidelines provided.
''';

    // Add Business Information
    if (businessInfo != null) {
      prompt += '''

BUSINESS INFORMATION:
Business Name: ${businessInfo.businessName}
Phone: ${businessInfo.phone}
Address: ${businessInfo.address}
Email: ${businessInfo.email}
Company Story: ${businessInfo.companyStory}
Payment Details: ${businessInfo.paymentDetails}
Discounts: ${businessInfo.discounts}
Policy: ${businessInfo.policy}
Additional Notes: ${businessInfo.additionalNotes}
Thank You Message: ${businessInfo.thankYouMessage}
''';
    }

    // Add Products & Services
    if (productsServices != null && productsServices.isNotEmpty) {
      prompt += '\n\nPRODUCTS & SERVICES:\n';
      for (int i = 0; i < productsServices.length; i++) {
        final product = productsServices[i];
        prompt += '''
${i + 1}. Name: ${product.name}
   Description: ${product.description}
   Price: ${product.price}
   Category: ${product.category}
   Features: ${product.features}''';
        
        // Add image information - CONTEXT-AWARE: Handle images based on chat type
        if (product.images.isNotEmpty) {
          if (isFacebookChat) {
            // For Facebook chat: Don't include URLs, just mention availability
            prompt += '\n   Images: ${product.images.length} image(s) available';
            prompt += '\n   NOTE: Images are available but cannot be displayed in Facebook chat. Describe the product instead.';
          } else {
            // For app chat: Include image URLs for display
            final imageUrl = product.images[0];
            prompt += '\n   📸 IMAGE URL: $imageUrl';
            prompt += '\n   ⚠️⚠️⚠️ MANDATORY IMAGE SYNTAX ⚠️⚠️⚠️';
            prompt += '\n   YOU MUST START YOUR RESPONSE WITH: ![${product.name}]($imageUrl)';
            prompt += '\n   EXAMPLE CORRECT RESPONSE: "![${product.name}]($imageUrl)\n\nHere are the details for ${product.name}..."';
            prompt += '\n   ❌ NEVER respond without including the image markdown first!';
            prompt += '\n   ❌ DO NOT describe images - SHOW them using ![name](url) syntax!';
          }
        } else if (product.selectedImage != null && product.selectedImage!.isNotEmpty) {
          if (isFacebookChat) {
            // For Facebook chat: Don't include URL, just mention availability
            prompt += '\n   NOTE: Image is available but cannot be displayed in Facebook chat. Describe the product instead.';
          } else {
            // For app chat: Include image URL for display
            final imageUrl = product.selectedImage!;
            prompt += '\n   📸 IMAGE URL: $imageUrl';
            prompt += '\n   ⚠️⚠️⚠️ MANDATORY IMAGE SYNTAX ⚠️⚠️⚠️';
            prompt += '\n   YOU MUST START YOUR RESPONSE WITH: ![${product.name}]($imageUrl)';
            prompt += '\n   EXAMPLE CORRECT RESPONSE: "![${product.name}]($imageUrl)\n\nHere are the details for ${product.name}..."';
            prompt += '\n   ❌ NEVER respond without including the image markdown first!';
            prompt += '\n   ❌ DO NOT describe images - SHOW them using ![name](url) syntax!';
          }
        }
        
        prompt += '\n';
      }
    }

    // Add FAQs
    if (faqs != null && faqs.isNotEmpty) {
      prompt += '\n\nFREQUENTLY ASKED QUESTIONS:\n';
      for (int i = 0; i < faqs.length; i++) {
        final faq = faqs[i];
        prompt += '''
${i + 1}. Q: ${faq.question}
   A: ${faq.answer}
   Category: ${faq.category}
''';
      }
    }

    // CONTEXT-AWARE INSTRUCTIONS: Different behavior for app vs Facebook chat
    if (isFacebookChat) {
      prompt += '''

INSTRUCTIONS:
- Use the business information to answer questions about the company
- Use the products/services information to help customers with product inquiries
- Use the FAQs to provide quick answers to common questions
- If a question matches an FAQ, provide the exact answer from the FAQ
- CRITICAL: DO NOT include image URLs in your responses - they will not display in Facebook chat
- When customers ask about products, describe them in detail instead of including image links
- For product inquiries, provide comprehensive descriptions including color, style, features, and price
- NEVER use markdown image syntax like ![Product Name](url) in Facebook chat responses
- Focus on detailed product descriptions rather than image references
- If customers ask about images, explain that images are available but cannot be displayed in this chat
- IMPORTANT: When showing products, provide detailed descriptions of what the images would show
- Always be helpful, professional, and maintain the assistant's personality
- If you don't have information about something, politely say so and offer to help with what you do know
''';
    } else {
      prompt += '''

INSTRUCTIONS FOR PRODUCT RESPONSES:
⚠️⚠️⚠️ CRITICAL RULES - YOU MUST FOLLOW THESE ⚠️⚠️⚠️

1. IMAGE DISPLAY IS MANDATORY:
   - You are in the app interface where images MUST be displayed
   - When customers ask about products, START your response with the image markdown
   - Format: ![Product Name](exact_image_url)
   - The image URL is provided above in the product data as "📸 IMAGE URL:"
   
2. RESPONSE STRUCTURE FOR PRODUCTS:
   Step 1: START with image markdown: ![Product Name](image_url)
   Step 2: Add a blank line
   Step 3: Then provide product details
   
3. EXAMPLES:
   ❌ WRONG: "Here are the product details for Clothes: Name: Clothes, Price: 4500..."
   ✅ CORRECT: "![Clothes](https://firebasestorage.googleapis.com/...)\n\nHere are the details for Clothes: Price: 4500..."
   
4. GENERAL INSTRUCTIONS:
   - Use the business information to answer questions about the company
   - Use the products/services information to help customers with product inquiries
   - Use the FAQs to provide quick answers to common questions
   - If a question matches an FAQ, provide the exact answer from the FAQ
   - Always be helpful, professional, and maintain the assistant's personality
   - If you don't have information about something, politely say so and offer to help with what you do know

⚠️ REMEMBER: ALWAYS start product responses with ![Product Name](url) - NO EXCEPTIONS!
''';
    }

    return prompt;
  }

  static String _getResponseStyle(String responseLength) {
    switch (responseLength) {
      case 'Short':
        return 'Keep responses concise and to the point (1-2 sentences).';
      case 'Long':
        return 'Provide detailed, comprehensive responses with examples when helpful.';
      default:
        return 'Provide balanced responses that are neither too short nor too long.';
    }
  }

  static int _getMaxTokens(String responseLength) {
    switch (responseLength) {
      case 'Short':
        return 300;
      case 'Long':
        return 1500;
      default:
        return 800;
    }
  }

  /// Encode image file to base64 string
  static Future<String> _encodeImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to encode image: $e');
    }
  }

  /// Remove Firebase Storage URLs from AI responses
  static String _removeFirebaseUrls(String content) {
    // Remove Firebase Storage URLs
    final firebaseUrlPattern = RegExp(r'https://firebasestorage\.googleapis\.com/[^\s)]+');
    String cleaned = content.replaceAll(firebaseUrlPattern, '[Image not available in chat]');
    
    // Remove markdown image syntax with Firebase URLs
    final markdownImagePattern = RegExp(r'!\[[^\]]*\]\(https://firebasestorage\.googleapis\.com/[^)]+\)');
    cleaned = cleaned.replaceAll(markdownImagePattern, '[Image not available in chat]');
    
    // Remove any remaining Firebase URLs in parentheses
    final parenthesesUrlPattern = RegExp(r'\(https://firebasestorage\.googleapis\.com/[^)]+\)');
    cleaned = cleaned.replaceAll(parenthesesUrlPattern, '(Image not available in chat)');
    
    print('🧹 Cleaned Firebase URLs from AI response');
    return cleaned;
  }

  /// Extract text content from various file types
  static Future<String> _extractTextFromFile(File file) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'txt':
        case 'csv':
          return await file.readAsString();
        case 'pdf':
          // For PDF, we'll need a PDF parsing library
          // For now, return a placeholder
          return 'PDF content extraction not yet implemented. Please convert to text file for analysis.';
        case 'doc':
        case 'docx':
          // For Word documents, we'll need a document parsing library
          return 'Word document content extraction not yet implemented. Please convert to text file for analysis.';
        default:
          return 'File type not supported for text extraction. Please use .txt or .csv files.';
      }
    } catch (e) {
      throw Exception('Failed to extract text from file: $e');
    }
  }

  /// Build system prompt for file analysis
  static String _buildFileAnalysisSystemPrompt({
    required String assistantName,
    required String introMessage,
    required String shortDescription,
    required String aiGuidelines,
    required String responseLength,
    required String fileType,
    AIKnowledgeModel? businessInfo,
    List<ProductServiceModel>? productsServices,
    List<FAQModel>? faqs,
  }) {
    String prompt = '''You are $assistantName, an AI assistant.

Your role: $introMessage
Your background: $shortDescription

Guidelines for your responses:
$aiGuidelines

Response length: ${responseLength.toLowerCase()}

You are now analyzing a $fileType file. Please provide detailed, helpful analysis based on the file content. Be specific and actionable in your response.''';

    // Add business context if available
    if (businessInfo != null) {
      prompt += '\n\nBusiness Context:\n';
      if (businessInfo.businessName.isNotEmpty) {
        prompt += 'Business Name: ${businessInfo.businessName}\n';
      }
      if (businessInfo.companyStory.isNotEmpty) {
        prompt += 'Company Story: ${businessInfo.companyStory}\n';
      }
      if (businessInfo.address.isNotEmpty) {
        prompt += 'Address: ${businessInfo.address}\n';
      }
      if (businessInfo.phone.isNotEmpty) {
        prompt += 'Phone: ${businessInfo.phone}\n';
      }
      if (businessInfo.email.isNotEmpty) {
        prompt += 'Email: ${businessInfo.email}\n';
      }
    }

    // Add products/services context
    if (productsServices != null && productsServices.isNotEmpty) {
      prompt += '\n\nAvailable Products/Services:\n';
      for (var product in productsServices) {
        prompt += '- ${product.name}: ${product.description}\n';
      }
    }

    // Add FAQ context
    if (faqs != null && faqs.isNotEmpty) {
      prompt += '\n\nFrequently Asked Questions:\n';
      for (var faq in faqs) {
        prompt += 'Q: ${faq.question}\nA: ${faq.answer}\n\n';
      }
    }

    return prompt;
  }
}
