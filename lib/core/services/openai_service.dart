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
        return data['choices'][0]['message']['content'] ?? 'No response generated.';
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
          if (content is String && content.isNotEmpty) {
            // Debug: Check if response is complete
            print('🤖 OpenAI Response Length: ${content.length} characters');
            print('🤖 OpenAI Response Complete: ${content.endsWith('.') || content.endsWith('!') || content.endsWith('?')}');
            
            // Check if response contains incomplete image paths
            if (content.contains('![') && content.contains('(/data/user/0') && !content.contains('.jpg)') && !content.contains('.png)') && !content.contains('.jpeg)')) {
              print('⚠️ WARNING: AI response appears to be truncated - incomplete image paths detected');
              print('⚠️ Truncated content: ${content.substring(content.length - 100)}');
            }
            
            return content;
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
        
        // Add image information
        if (product.images.isNotEmpty) {
          prompt += '\n   Images: ${product.images.length} image(s) available';
          for (int j = 0; j < product.images.length; j++) {
            prompt += '\n   - Image ${j + 1}: ${product.images[j]}';
          }
          prompt += '\n   USE THESE IMAGE PATHS: When showing this product, use: ![${product.name}](${product.images[0]})';
          if (product.images.length > 1) {
            for (int j = 1; j < product.images.length; j++) {
              prompt += '\n   AND: ![${product.name} ${j + 1}](${product.images[j]})';
            }
          }
        } else if (product.selectedImage != null && product.selectedImage!.isNotEmpty) {
          prompt += '\n   Primary Image: ${product.selectedImage}';
          prompt += '\n   USE THIS IMAGE PATH: When showing this product, use: ![${product.name}](${product.selectedImage})';
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

    prompt += '''

INSTRUCTIONS:
- Use the business information to answer questions about the company
- Use the products/services information to help customers with product inquiries
- Use the FAQs to provide quick answers to common questions
- If a question matches an FAQ, provide the exact answer from the FAQ
- When customers ask about product images, provide the image paths in this exact format: ![Product Name](image_path) (NO SPACE after the opening parenthesis)
- For image requests, mention that images are available and provide the image information from the product data
- IMPORTANT: Use the exact format ![Product Name](image_path) with NO SPACE between the opening parenthesis and the path
- CRITICAL: Always provide COMPLETE image paths - do not truncate or cut off image URLs
- When showing multiple products with images, include ALL image paths completely
- PRIORITY: If you have multiple products with images, show ALL of them - do not skip any
- FORMAT: For each product with an image, use: ![ProductName](complete_file_path)
- MANDATORY: When showing products, ALWAYS include the image paths provided in the product data above
- MANDATORY: If a product has multiple images, show ALL of them using the exact paths provided
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
