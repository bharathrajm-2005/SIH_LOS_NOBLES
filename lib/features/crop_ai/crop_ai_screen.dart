import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/services/mistral_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/services/whisper_service.dart';
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
      final response = await MistralService.generateResponse(
        'Hello, are you working?',
        context: 'Test connection',
      );

      if (!mounted) return;
      setState(() {
        _isConnected = response.isNotEmpty;
        _connectionStatus = _isConnected 
            ? 'Connected to AI service' 
            : 'Connected but received empty response';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Connection failed: ${e.toString()}';
      });
    }
  }

  bool _isCropSpecificQuery(String message) {
    final cropKeywords = [
      'crop', 'plant', 'grow', 'cultivation', 'farming', 'harvest',
      'sow', 'seed', 'yield', 'irrigation', 'fertilizer', 'pest',
      'disease', 'soil', 'weather', 'rain', 'drought', 'monsoon',
      'rice', 'wheat', 'maize', 'vegetable', 'fruit', 'cash crop',
      'plantation', 'horticulture', 'organic', 'compost', 'manure',
      'weed', 'insect', 'pesticide', 'herbicide', 'fungicide'
    ];

    final lowerMessage = message.toLowerCase();
    return cropKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  String? _extractCropType(String message) {
    final cropTypes = [
      'rice', 'wheat', 'maize', 'sugarcane', 'cotton', 'jute',
      'coffee', 'tea', 'rubber', 'coconut', 'banana', 'mango',
      'apple', 'orange', 'potato', 'tomato', 'onion', 'chilli',
      'brinjal', 'okra', 'cucumber', 'pumpkin', 'watermelon',
      'millet', 'sorghum', 'pulses', 'lentils', 'beans', 'peas'
    ];

    final lowerMessage = message.toLowerCase();
    for (var crop in cropTypes) {
      if (lowerMessage.contains(crop)) {
        return crop;
      }
    }
    return null;
  }

  String _getLanguageName(String languageCode) {
    // Extract the base language code (e.g., 'en' from 'en_US')
    final baseLang = languageCode.split('_')[0];
    
    switch (baseLang) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'ta':
        return 'தமிழ்';
      case 'te':
        return 'తెలుగు';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'ml':
        return 'മലയാളം';
      case 'gu':
        return 'ગુજરાતી';
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

  Future<void> _sendMessage({String? predefinedMessage}) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      String response;
      
      // Handle simple greetings
      final lowerMessage = message.toLowerCase();
      if (['hi', 'hello', 'hey', 'hi there', 'hello there'].contains(lowerMessage)) {
        response = '👋 Hello! I\'m your farming assistant. How can I help you with your crops today?';
      } 
      // Handle thanks/gratitude
      else if (['thanks', 'thank you', 'thank you!', 'thanks!'].contains(lowerMessage)) {
        response = 'You\'re welcome! 😊 Is there anything else you\'d like to know about farming?';
      }
      // Handle how are you
      else if (['how are you', 'how are you?', 'how are you doing'].contains(lowerMessage)) {
        response = 'I\'m doing well, thank you! Ready to help with all your farming questions. What would you like to know?';
      }
      // Handle farming-specific queries
      else if (_isCropSpecificQuery(message)) {
        response = await _getCropAdviceWithWeather(message);
      } 
      // Default to AI for other queries
      else {
        response = await MistralService.generateResponse(
          message,
          context: 'User asked about farming',
        );
      }

      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isConnected = true;
        _isTyping = false;  // Add this line to stop the typing indicator
        _connectionStatus = 'Connected to AI service';
      });
    } catch (e) {
      String errorMessage;
      bool shouldSetConnected = _isConnected;
      String? newConnectionStatus = _connectionStatus;
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('No internet connection')) {
        errorMessage = '⚠️ No internet connection. Please check your connection and try again.';
        shouldSetConnected = false;
        newConnectionStatus = 'No internet connection';
      } else if (e.toString().contains('TimeoutException') || 
                e.toString().contains('timeout')) {
        errorMessage = '⏱️ Request timed out.\n\nThe AI service is taking too long to respond. Please try again.';
        newConnectionStatus = 'Request timeout';
      } else if (e.toString().contains('Rate limit') || 
                e.toString().contains('429')) {
        errorMessage = '⚠️ Rate limit exceeded. Please wait a moment before sending another message.';
        newConnectionStatus = 'Rate limit exceeded';
      } else {
        errorMessage = '⚠️ An error occurred: ${e.toString()}';
        shouldSetConnected = false;
        newConnectionStatus = 'Processing error';
      }

      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isConnected = shouldSetConnected;
        _connectionStatus = newConnectionStatus;
        _isTyping = false;  // Stop the typing indicator on error
      });
    }

    _scrollToBottom();
  }

  Future<String> _getCropAdviceWithWeather(String message) async {
    try {
      // Try to get current weather for context
      final weatherService = Provider.of<WeatherService>(context, listen: false);
      final weather = await weatherService.getWeatherByLocation();
      
      // Build a prompt with weather context
      final prompt = '''
      I need crop advice with the following weather conditions:
      - Temperature: ${weather.temperature}°C
      - Humidity: ${weather.humidity}%
      - Condition: ${weather.mainCondition}
      - Wind Speed: ${weather.windSpeed} m/s
      - Location: ${weather.cityName}, ${weather.countryCode}
      
      Crop type: ${_extractCropType(message)}
      
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
            Text('Connection Status: ${_isConnected ? 'Connected' : 'Disconnected'}'),
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
              if (!mounted) return;
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop AI Assistant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'Help',
          ),
          
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _clearChat(),
            tooltip: 'Clear Chat',
          ),
          
          // Debug info button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => _showDebugInfo(),
            tooltip: 'Debug Info',
          ),
          
          // Voice input language selector
          Consumer<WhisperService>(
            builder: (context, whisperService, _) {
              return IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Select Voice Input Language',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...whisperService.availableLanguages.map((languageCode) {
                              final isSelected = whisperService.currentLanguage == languageCode;
                              return ListTile(
                                title: Text(whisperService.getLanguageName(languageCode)),
                                trailing: isSelected
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : null,
                                onTap: () {
                                  whisperService.setLanguage(languageCode);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Voice input language set to: ${whisperService.getLanguageName(languageCode)}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  );
                },
                tooltip: 'Change voice input language',
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F9F5),
              Colors.white,
            ],
          ),
        ),
          child: Column(
            children: [
              // Status Bar - Only show when there's an error
              if (!_isConnected && _connectionStatus != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 20,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _connectionStatus!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return const TypingIndicator();
                    }
                    return _messages[index];
                  },
                ),
              ),

              // Quick suggestions
              if (!_isTyping)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _quickSuggestions
                        .map((suggestion) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ActionChip(
                                label: Text(suggestion),
                                onPressed: () => _sendMessage(predefinedMessage: suggestion),
                                backgroundColor: Colors.green[50],
                                labelStyle: const TextStyle(fontSize: 12),
                                padding: const EdgeInsets.all(4.0),
                              ),
                            ))
                        .toList(),
                  ),
                ),

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
                      // Message input field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            enabled: !_isTyping,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8.0),
                      
                      // Voice input button
                      Consumer<WhisperService>(
                        builder: (context, whisperService, _) {
                          return VoiceInputButton(
                            initialLanguage: whisperService.currentLanguage,
                            onTextRecognized: (text) {
                              if (text.isNotEmpty) {
                                _sendMessage(predefinedMessage: text);
                                // Show a snackbar with the recognized text
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('You said: $text'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            onListeningStarted: () {
                              // Show a snackbar when recording starts
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Listening... Speak now'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            onListeningStopped: () {
                              // Show a snackbar when recording stops
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Processing your voice...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
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
      ),
    );
  }
}