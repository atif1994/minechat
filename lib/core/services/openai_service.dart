import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/data/ai_knowledge_model.dart';
import '../../model/data/product_service_model.dart';
import '../../model/data/faq_model.dart';

class OpenAIService {
  // OpenAI API Configuration
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Generate AI response using direct OpenAI API
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

  /// Generate AI response with business knowledge using direct OpenAI API
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
      // Build system prompt
      String systemPrompt = _buildSystemPrompt(
        assistantName: assistantName,
        introMessage: introMessage,
        shortDescription: shortDescription,
        aiGuidelines: aiGuidelines,
        responseLength: responseLength,
        businessInfo: businessInfo,
        productsServices: productsServices,
        faqs: faqs,
      );

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'max_tokens': _getMaxTokens(responseLength),
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response generated';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Build system prompt with business information
  static String _buildSystemPrompt({
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

    // Add Products/Services
    if (productsServices != null && productsServices.isNotEmpty) {
      prompt += '\n\nPRODUCTS/SERVICES:\n';
      for (int i = 0; i < productsServices.length; i++) {
        final item = productsServices[i];
        prompt += '''
${i + 1}. ${item.name}
   Description: ${item.description}
   Price: ${item.price}
   Category: ${item.category}
''';
      }
    }

    // Add FAQs
    if (faqs != null && faqs.isNotEmpty) {
      prompt += '\n\nFREQUENTLY ASKED QUESTIONS:\n';
      for (int i = 0; i < faqs.length; i++) {
        final faq = faqs[i];
        prompt += '''
Q${i + 1}: ${faq.question}
A${i + 1}: ${faq.answer}
''';
      }
    }

    return prompt;
  }

  /// Get response style based on length preference
  static String _getResponseStyle(String responseLength) {
    switch (responseLength.toLowerCase()) {
      case 'short':
        return 'Keep responses concise and to the point (1-2 sentences)';
      case 'medium':
        return 'Provide detailed but not overly long responses (2-4 sentences)';
      case 'long':
        return 'Give comprehensive and detailed responses (4+ sentences)';
      default:
        return 'Provide appropriate length responses based on the question';
    }
  }

  /// Get max tokens based on response length
  static int _getMaxTokens(String responseLength) {
    switch (responseLength.toLowerCase()) {
      case 'short':
        return 100;
      case 'medium':
        return 300;
      case 'long':
        return 500;
      default:
        return 300;
    }
  }
}