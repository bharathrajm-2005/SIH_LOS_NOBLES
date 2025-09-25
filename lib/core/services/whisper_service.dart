import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class WhisperService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isRecording = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _currentLanguage = 'en_US'; // Default to English US

  // Language codes for speech recognition
  static const Map<String, String> supportedLanguages = {
    'en_US': 'English',
    'en': 'English',
    'hi_IN': 'Hindi',
    'hi': 'Hindi',
    'ta_IN': 'Tamil',
    'ta': 'Tamil',
    'te_IN': 'Telugu',
    'te': 'Telugu',
    'kn_IN': 'Kannada',
    'kn': 'Kannada',
    'ml_IN': 'Malayalam',
    'ml': 'Malayalam',
    'gu_IN': 'Gujarati',
    'gu': 'Gujarati',
  };

  // Getters
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String get recognizedText => _recognizedText;
  String get currentLanguage => _currentLanguage;

  List<String> get availableLanguages => supportedLanguages.keys.toList();
  String getLanguageName(String code) => supportedLanguages[code] ?? code;

  // Speech recognition result handler
  void _onSpeechResult(String text) {
    _recognizedText = text;
    notifyListeners();
  }

  /// Initialize the service
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission denied');
        return false;
      }

      // Initialize speech recognition
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isRecording = false;
            _isProcessing = false;
            notifyListeners();
          }
        },
        onError: (error) {
          print('Speech recognition error: $error');
          _isRecording = false;
          _isProcessing = false;
          notifyListeners();
        },
      );

      if (!available) {
        print('Speech recognition not available on this device');
        return false;
      }

      print('✅ Speech recognition service initialized successfully');
      return true;
    } catch (e) {
      print('❌ Error initializing speech recognition: $e');
      return false;
    }
  }

  /// Start recording audio
  Future<bool> startRecording() async {
    if (_isRecording || _isProcessing) return false;

    // Ensure we start fresh by stopping any existing recognition
    try {
      await _speech.stop();
      await _speech.cancel();
      print('🔄 Cleaned up previous recognition');
    } catch (e) {
      print('🔄 Cleanup warning: $e');
    }

    // Wait a bit to ensure cleanup is complete
    await Future.delayed(const Duration(milliseconds: 200));

    // List of languages to try in order of preference
    final languagesToTry = [
      _currentLanguage,
      'en_US', // English with country code
      'en', // English without country code
    ];

    for (int i = 0; i < languagesToTry.length; i++) {
      final languageToTry = languagesToTry[i];

      try {
        // Reset state for each attempt
        _isRecording = false;
        _isProcessing = false;
        _recognizedText = '';
        notifyListeners();

        print(
            '🎤 Attempt ${i + 1}: Starting speech recognition with language: $languageToTry');

        bool? started;
        try {
          started = await _speech.listen(
            onResult: (result) {
              if (result.finalResult) {
                _onSpeechResult(result.recognizedWords);
              }
            },
            localeId: languageToTry,
            listenMode: stt.ListenMode.dictation,
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 5),
          );
          print('🎤 Listen result: $started (type: ${started.runtimeType})');
        } catch (listenError) {
          print('❌ Error in _speech.listen(): $listenError');
          started = false;
        }

        // Check if speech recognition actually started by checking the status
        await Future.delayed(const Duration(milliseconds: 500));
        final isActuallyListening = _speech.isListening;

        if (started == true || isActuallyListening) {
          _isRecording = true;
          _isProcessing = false;
          notifyListeners();

          // Update current language if we had to fallback
          if (languageToTry != _currentLanguage) {
            _currentLanguage = languageToTry;
            notifyListeners();
            print('🔄 Language changed to: $languageToTry');
          }

          print(
              '✅ Speech recognition started successfully with language: $languageToTry');
          return true;
        } else {
          print(
              '❌ Speech recognition failed for language: $languageToTry (started: $started, isListening: $isActuallyListening)');

          // If this was the last language to try, return false
          if (i == languagesToTry.length - 1) {
            print('❌ All language attempts failed');
            return false;
          }
        }
      } catch (e) {
        print('❌ Error with language $languageToTry: $e');

        // If this was the last language to try, return false
        if (i == languagesToTry.length - 1) {
          print('❌ All language attempts failed with errors');
          return false;
        }
      }

      // Small delay between attempts
      if (i < languagesToTry.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    return false;
  }

  /// Stop recording and process audio
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      await _speech.stop();
      _isRecording = false;
      _isProcessing = false;
      notifyListeners();

      final text = _recognizedText;
      print('🎵 Speech recognized: $text');

      return text.isNotEmpty ? text : null;
    } catch (e) {
      print('❌ Error stopping speech recognition: $e');
      _isRecording = false;
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _speech.cancel();
      _isRecording = false;
      _isProcessing = false;
      _recognizedText = '';
      notifyListeners();
      print('🚫 Speech recognition cancelled');
    } catch (e) {
      print('❌ Error cancelling speech recognition: $e');
    }
  }

  /// Reset speech recognition to clean state
  Future<void> resetSpeechRecognition() async {
    try {
      await _speech.stop();
      await _speech.cancel();
      _isRecording = false;
      _isProcessing = false;
      _recognizedText = '';
      notifyListeners();
      print('🔄 Speech recognition reset');
    } catch (e) {
      print('❌ Error resetting speech recognition: $e');
    }
  }

  /// Set the language for speech recognition
  void setLanguage(String languageCode) {
    // Convert from our language code format to the format expected by the speech recognition package
    String localeCode = languageCode;

    // If the language code doesn't have a country code, add one
    if (!languageCode.contains('_')) {
      // Map 2-letter codes to proper locale codes
      switch (languageCode.toLowerCase()) {
        case 'en':
          localeCode = 'en_US';
          break;
        case 'hi':
          localeCode = 'hi_IN';
          break;
        case 'ta':
          localeCode = 'ta_IN';
          break;
        case 'te':
          localeCode = 'te_IN';
          break;
        case 'kn':
          localeCode = 'kn_IN';
          break;
        case 'ml':
          localeCode = 'ml_IN';
          break;
        case 'gu':
          localeCode = 'gu_IN';
          break;
        default:
          localeCode = 'en_US'; // Default fallback
      }
    }

    if (supportedLanguages.containsKey(localeCode)) {
      _currentLanguage = localeCode;
      notifyListeners();
      print('🌐 Language set to: ${getLanguageName(localeCode)}');
    } else {
      print(
          '⚠️ Unsupported language code: $languageCode, using default: en_US');
      _currentLanguage = 'en_US';
      notifyListeners();
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Get suggested language based on device locale
  String getSuggestedLanguage() {
    // Get device locale and return the best match from supported languages
    final deviceLocale = WidgetsBinding.instance.window.locale;
    final languageCode = deviceLocale.languageCode;

    // Try to find an exact match first
    final exactMatch = supportedLanguages.keys.firstWhere(
      (key) => key.startsWith('${languageCode}_'),
      orElse: () => 'en_US', // Default to English if no match found
    );

    return exactMatch;
  }

  /// Check if a specific language is supported by the device
  Future<bool> isLanguageSupported(String languageCode) async {
    try {
      // For now, assume all our supported languages work
      // The actual validation will happen when we try to start recording
      return supportedLanguages.containsKey(languageCode);
    } catch (e) {
      print('Error checking language support: $e');
      return false;
    }
  }

  /// Get available languages that are actually supported by the device
  Future<List<String>> getAvailableLanguages() async {
    try {
      final testSpeech = stt.SpeechToText();
      final available = await testSpeech.initialize(
        onStatus: (status) {},
        onError: (error) {},
      );

      if (!available) return ['en_US']; // Fallback to English

      // Return our supported languages (we'll validate them when used)
      return supportedLanguages.keys.toList();
    } catch (e) {
      print('Error getting available languages: $e');
      return ['en_US']; // Fallback to English
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
