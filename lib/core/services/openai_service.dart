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
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../../model/data/ai_knowledge_model.dart';
import '../../model/data/product_service_model.dart';
import '../../model/data/faq_model.dart';

class OpenAIService {
  static const String _proxyUrl = AppConfig.apiProxyUrl;

  // Removed: client-side API key is insecure. Using server proxy instead.
  static const String _apiKey_removed = "";

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
  }) async {
    try {
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
                  'content': _buildEnhancedSystemPrompt(
                    assistantName: assistantName,
                    introMessage: introMessage,
                    shortDescription: shortDescription,
                    aiGuidelines: aiGuidelines,
                    responseLength: responseLength,
                    businessInfo: businessInfo,
                    productsServices: productsServices,
                    faqs: faqs,
                  ),
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
          if (content is String && content.isNotEmpty) return content;
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

  static String _buildSystemPrompt({
    required String assistantName,
    required String introMessage,
    required String shortDescription,
    required String aiGuidelines,
    required String responseLength,
  }) {
    return _buildEnhancedSystemPrompt(
      assistantName: assistantName,
      introMessage: introMessage,
      shortDescription: shortDescription,
      aiGuidelines: aiGuidelines,
      responseLength: responseLength,
    );
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
   Features: ${product.features}
''';
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

    prompt += '''

INSTRUCTIONS:
- Use the business information to answer questions about the company
- Use the products/services information to help customers with product inquiries
- Use the FAQs to provide quick answers to common questions
- If a question matches an FAQ, provide the exact answer from the FAQ
- Always be helpful, professional, and maintain the assistant's personality
- If you don't have information about something, politely say so and offer to help with what you do know
''';

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
        return 100;
      case 'Long':
        return 500;
      default:
        return 250;
    }
  }
}
