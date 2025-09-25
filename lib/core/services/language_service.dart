import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  // Supported languages with their details
  static final Map<String, LanguageModel> supportedLanguages = {
    'en': LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    'hi': LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    'ta': LanguageModel(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
    ),
    'te': LanguageModel(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
    ),
    'pa': LanguageModel(
      code: 'pa',
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      flag: '🇮🇳',
    ),
    'mr': LanguageModel(
      code: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      flag: '🇮🇳',
    ),
    'ml': LanguageModel(
      code: 'ml',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      flag: '🇮🇳',
    ),
  };

  /// Get current language code
  static Future<String> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? _defaultLanguage;
    } catch (e) {
      return _defaultLanguage;
    }
  }

  /// Save selected language
  static Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  /// Get current language model
  static Future<LanguageModel> getCurrentLanguageModel() async {
    final code = await getCurrentLanguage();
    return supportedLanguages[code] ?? supportedLanguages[_defaultLanguage]!;
  }

  /// Get locale from language code
  static Locale getLocaleFromCode(String code) {
    return Locale(code);
  }

  /// Get all supported locales
  static List<Locale> get supportedLocales {
    return supportedLanguages.keys.map((code) => Locale(code)).toList();
  }
}

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  @override
  String toString() => '$flag $nativeName';
}
