import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MistralService {
  static String get _apiKey => dotenv.env['MISTRAL_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.mistral.ai/v1';
  
  // Fallback responses for when API is unavailable
  static const Map<String, String> _fallbackResponses = {
    'soil': '''🌱 **Soil Health Tips:**

• **Test your soil pH** - Most crops prefer pH 6.0-7.0
• **Add organic matter** - Compost or well-rotted manure (₹200-500 per bag)
• **Improve drainage** - Create raised beds if waterlogged
• **Regular testing** - Get soil tested every 2-3 years

**Cost-effective fertilizers:**
• NPK 19:19:19 - ₹800-1200 per 50kg bag
• Organic compost - ₹150-300 per bag

Contact your local agricultural extension officer for soil testing facilities.''',
    
    'pest': '''🐛 **Natural Pest Control:**

• **Neem oil spray** - Mix 5ml per liter water (₹100-200 per bottle)
• **Regular inspection** - Check plants daily for early detection
• **Companion planting** - Marigolds, basil deter many pests
• **Beneficial insects** - Encourage ladybugs, spiders

**Organic solutions:**
• Soap spray for aphids
• Turmeric powder for fungal issues
• Garlic-chili spray for general pests

**When to use chemicals:** Only if organic methods fail, consult local experts.''',
    
    'crop': '''🌾 **Crop Selection Tips:**

• **Consider your soil type** - Sandy, clay, or loamy
• **Check water availability** - Match crops to irrigation capacity
• **Seasonal timing** - Plant according to monsoon patterns
• **Market demand** - Research local prices before planting

**Popular profitable crops:**
• Vegetables: Tomato, onion, potato
• Cereals: Rice, wheat (based on region)
• Cash crops: Cotton, sugarcane (if suitable)'''
  };

  static Future<String> generateResponse(String prompt, {String? context}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': 'mistral-tiny',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful agricultural assistant providing advice to farmers in India. '
                  'Provide practical, cost-effective solutions considering local conditions. '
                  'Use simple language and include local pricing in INR when possible.'
            },
            {'role': 'user', 'content': context != null ? '$context\n\n$prompt' : prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Mistral API error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(prompt);
      }
    } catch (e) {
      print('Error calling Mistral API: $e');
      return _getFallbackResponse(prompt);
    }
  }

  static Future<String> generateResponseWithImage({
    required String prompt,
    required String imageBase64,
    String? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': 'mistral-vision',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an agricultural expert analyzing plant health issues. Provide detailed '
                  'analysis of any pests, diseases, or other issues visible in the image. Include: '
                  '1. Identification 2. Confidence level 3. Description 4. Impact 5. Treatment options 6. Prevention. '
                  'Be specific and provide actionable advice for farmers in India.'
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': context != null ? '$context\n\n$prompt' : prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$imageBase64',
                    'detail': 'high'
                  }
                }
              ]
            }
          ],
          'temperature': 0.3,  // Lower temperature for more focused, factual responses
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Mistral Vision API error: ${response.statusCode} - ${response.body}');
        return 'I couldn\'t analyze the image right now. Please describe the issue you\'re seeing.';
      }
    } catch (e) {
      print('Error calling Mistral Vision API: $e');
      return 'I encountered an error while analyzing the image. Please try again or describe the issue.';
    }
  }

  static String _getFallbackResponse(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains('soil') || 
        lowerPrompt.contains('fertilizer') || 
        lowerPrompt.contains('nutrient')) {
      return _fallbackResponses['soil']!;
    } else if (lowerPrompt.contains('pest') || 
              lowerPrompt.contains('disease') || 
              lowerPrompt.contains('insect')) {
      return _fallbackResponses['pest']!;
    } else if (lowerPrompt.contains('crop') || 
              lowerPrompt.contains('plant') || 
              lowerPrompt.contains('harvest')) {
      return _fallbackResponses['crop']!;
    }
    
    return "I'm sorry, I'm having trouble connecting to the AI service. "
        "Here's some general farming advice: ${_fallbackResponses['crop']}";
  }
}
