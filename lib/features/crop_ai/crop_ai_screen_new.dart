import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/services/mistral_service.dart';
import '../../core/services/weather_service.dart';
import '../../widgets/chat_message.dart';
import '../../widgets/typing_indicator.dart';
import '../../widgets/voice_input_button.dart';

class CropAIScreen extends StatefulWidget {
  const CropAIScreen({super.key});

  @override
  State<CropAIScreen> createState() => _CropAIScreenState();
}

class _CropAIScreenState extends State<CropAIScreen> {
  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State variables
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isConnected = true;
  String? _connectionStatus;

  // Quick suggestion chips - Farmer-friendly questions
  final List<String> _quickSuggestions = [
    'What crops should I plant this season?',
    'How to improve soil health?',
    'Best irrigation practices',
    'My tomato leaves are turning yellow',
    'Organic fertilizer for vegetables',
    'When to harvest wheat?',
    'How to control pests naturally?',
    'Preparing soil for monsoon',
    'Best time to plant rice',
    'Cost-effective fertilizers',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _testConnection();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper Methods
  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text: '🌾 Welcome to your AI Farming Assistant! 🌱\n\n'
              'I\'m here to help you with all your agricultural needs:\n\n'
              '🌾 Crop selection and management\n'
              '🌧️ Weather-based farming advice\n'
              '🚜 Best farming practices\n'
              '🐛 Pest and disease management\n'
              '🌱 Soil health and fertilization\n'
              '💡 General agricultural guidance\n\n'
              'You can ask me questions or tap one of the suggestions below. What would you like to know today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _testConnection() async {
    try {
      // Test with a simple query
      final response = await MistralService.generateResponse(
        'Hello, are you working?',
        context: 'Test connection',
      );

      setState(() {
        if (response.isNotEmpty) {
          _isConnected = true;
          _connectionStatus = 'Connected to AI service';
        } else {
          _isConnected = false;
          _connectionStatus = 'Connected but received empty response';
        }
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Connection failed: ${e.toString()}';
      });
    }
  }

  bool _isCropSpecificQuery(String message) {
    final cropKeywords = [
      'crop',
      'plant',
      'grow',
      'cultivation',
      'farming',
      'harvest',
      'rice',
      'wheat',
      'corn',
      'maize',
      'tomato',
      'potato',
      'cotton',
      'sugarcane',
      'soybean',
      'vegetables',
      'fruits'
    ];

    final messageLower = message.toLowerCase();
    return cropKeywords.any((keyword) => messageLower.contains(keyword));
  }

  String _extractCropType(String message) {
    const crops = [
      'rice',
      'wheat',
      'corn',
      'maize',
      'tomato',
      'potato',
      'cotton',
      'sugarcane',
      'soybean',
      'sunflower',
      'mustard',
      'barley',
      'onion',
      'garlic',
      'carrot',
      'cabbage',
      'cauliflower',
      'brinjal',
      'okra',
      'chilli',
      'pepper',
      'cucumber'
    ];

    final messageLower = message.toLowerCase();
    for (final crop in crops) {
      if (messageLower.contains(crop)) {
        return crop;
      }
    }
    return 'general crops';
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ta':
        return 'Tamil';
      case 'hi':
        return 'Hindi';
      case 'ml':
        return 'Malayalam';
      case 'mr':
        return 'Marathi';
      case 'pa':
        return 'Punjabi';
      case 'te':
        return 'Telugu';
      case 'en':
      default:
        return 'English';
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Chat methods
  Future<void> _sendMessage({String? predefinedMessage}) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
      _connectionStatus = null;
    });

    // Clear input if it's from text field
    if (predefinedMessage == null) {
      _messageController.clear();
    }

    _scrollToBottom();

    try {
      print('=== Sending Message ===');
      print('Message: $message');

      // Check if it's a crop-specific query that needs weather context
      if (_isCropSpecificQuery(message)) {
        final response = await _getCropAdviceWithWeather(message);
        print('Received response: $response');

        setState(() {
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isTyping = false;
          _isConnected = true;
          _connectionStatus = 'Response received successfully';
        });
      } else {
        // Simple chat for general queries
        final currentLocale = Localizations.localeOf(context);
        String languageName = _getLanguageName(currentLocale.languageCode);

        final response = await MistralService.generateResponse(
          message,
          context: context.toString(),
        );

        print('Received response: $response');

        setState(() {
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isTyping = false;
          _isConnected = true;
          _connectionStatus = 'Response received successfully';
        });
      }
    } catch (e) {
      print('Error in _sendMessage: $e');

      setState(() {
        String errorMessage;

        if (e.toString().contains('SocketException') ||
            e.toString().contains('No internet connection')) {
          errorMessage =
              '🌐 No internet connection detected.\n\nPlease check your network settings and try again.';
          _connectionStatus = 'No internet connection';
          _isConnected = false;
        } else if (e.toString().contains('TimeoutException') ||
            e.toString().contains('timeout')) {
          errorMessage =
              '⏱️ Request timed out.\n\nThe AI service is taking too long to respond. Please try again.';
          _connectionStatus = 'Request timeout';
        } else if (e.toString().contains('Rate limit') ||
            e.toString().contains('429')) {
          errorMessage =
              '🚦 Too many requests.\n\nI\'m receiving a lot of requests right now. Please wait a few minutes and try again.';
          _connectionStatus = 'Rate limit exceeded';
        } else if (e.toString().contains('Authentication') ||
            e.toString().contains('401')) {
          errorMessage =
              '🔑 Authentication issue.\n\nThere\'s a problem with the AI service configuration. Please contact support.';
          _connectionStatus = 'Authentication failed';
          _isConnected = false;
        } else if (e.toString().contains('503') ||
            e.toString().contains('Service unavailable')) {
          errorMessage =
              '🔧 Service temporarily unavailable.\n\nThe AI service is currently overloaded. Please try again in a few minutes.';
          _connectionStatus = 'Service overloaded';
        } else {
          errorMessage =
              '❌ I\'m having trouble processing your request.\n\nThis might be a temporary issue. Please try again in a moment.';
          _connectionStatus = 'Processing error';
        }

        _messages.add(
          ChatMessage(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _getCropAdviceWithWeather(String message) async {
    try {
      // Try to get current weather for context
      final weatherService =
          Provider.of<WeatherService>(context, listen: false);
      final weather = await weatherService.getWeatherByLocation();

      // Build a prompt with weather context
      final prompt = '''
      I need crop advice with the following weather conditions:
      - Temperature: ${weather.temperature}°C
      - Humidity: ${weather.humidity}%
      - Condition: ${weather.mainCondition}
      - Wind Speed: ${weather.windSpeed} m/s
      - Location: ${weather.cityName}, ${weather.countryCode}
      
      Crop type: ${_extractCropType(message) ?? 'Not specified'}
      
      Here's my question: $message
      
      Please provide specific advice considering these weather conditions.
      Include recommendations for:
      - Irrigation scheduling
      - Pest and disease prevention
      - Nutrient management
      - Any other relevant agricultural practices
      
      Format the response in clear, easy-to-read sections with emojis for better readability.
      ''';

      return await MistralService.generateResponse(prompt);
    } catch (e) {
      print('Error getting weather data: $e');
      // Fallback to simple chat without weather context
      return await MistralService.generateResponse('''
      I need crop advice but couldn't get weather data. 
      Here's my question: $message
      
      Please provide general agricultural advice for Indian farming conditions.
      ''');
    }
  }

  // UI Methods
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const Text(
          'Ask me anything about farming and agriculture. Here are some examples:\n\n'
          '• What crops should I plant this season?\n'
          '• How to improve soil health?\n'
          '• Best irrigation practices for my farm\n'
          '• My tomato leaves are turning yellow, what should I do?\n\n'
          'I can also provide weather-based advice if you enable location services.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Connection Status: ${_isConnected ? 'Connected' : 'Disconnected'}'),
            const SizedBox(height: 8),
            Text('Status: ${_connectionStatus ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Messages: ${_messages.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear the chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farming Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          if (_connectionStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: _isConnected ? Colors.green[100] : Colors.orange[100],
              child: Text(
                _connectionStatus!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isConnected ? Colors.green[800] : Colors.orange[800],
                  fontSize: 12,
                ),
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),

          // Quick suggestions
          if (!_isTyping)
            Container(
              height: 60,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _quickSuggestions
                    .map((suggestion) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ActionChip(
                            label: Text(suggestion),
                            onPressed: () =>
                                _sendMessage(predefinedMessage: suggestion),
                            backgroundColor: Colors.green[50],
                            labelStyle: const TextStyle(fontSize: 12),
                            padding: const EdgeInsets.all(4.0),
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Typing indicator
          if (_isTyping) const TypingIndicator(),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Voice input button
                  VoiceInputButton(
                    onTextRecognized: (text) {
                      if (text.isNotEmpty) {
                        _messageController.text = text;
                        _sendMessage();
                      }
                    },
                  ),

                  // Text input field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me about farming...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isTyping,
                    ),
                  ),

                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isTyping ? null : () => _sendMessage(),
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
