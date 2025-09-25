class AppConstants {
  // App Information
  static const String appName = 'CropAdvisor';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered crop advisory application';

  // Shared Preferences Keys
  static const String keyUserProfile = 'user_profile';
  static const String keyLocationPermission = 'location_permission';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyWeatherCache = 'weather_cache';
  static const String keyLastWeatherUpdate = 'last_weather_update';

  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultLocation = 'Delhi, India';
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;

  // Crop Categories
  static const List<String> cropCategories = [
    'Cereals',
    'Pulses',
    'Oilseeds',
    'Vegetables',
    'Fruits',
    'Spices',
    'Cash Crops',
    'Fodder Crops',
  ];

  // Season Types
  static const List<String> seasons = [
    'Kharif',
    'Rabi',
    'Zaid',
    'Perennial',
  ];

  // Soil Types
  static const List<String> soilTypes = [
    'Alluvial',
    'Black',
    'Red',
    'Laterite',
    'Desert',
    'Mountain',
    'Saline',
    'Peaty',
  ];

  // Weather Conditions
  static const List<String> weatherConditions = [
    'Clear',
    'Clouds',
    'Rain',
    'Drizzle',
    'Thunderstorm',
    'Snow',
    'Mist',
    'Fog',
  ];

  // Pest Categories
  static const List<String> pestCategories = [
    'Insects',
    'Diseases',
    'Weeds',
    'Nematodes',
    'Rodents',
    'Birds',
  ];

  // Fertilizer Types
  static const List<String> fertilizerTypes = [
    'Nitrogen',
    'Phosphorus',
    'Potassium',
    'Organic',
    'Bio-fertilizer',
    'Micronutrients',
  ];

  // Government Scheme Categories
  static const List<String> schemeCategories = [
    'Subsidy',
    'Insurance',
    'Credit',
    'Technology',
    'Training',
    'Market Support',
    'Infrastructure',
  ];

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['.jpg', '.jpeg', '.png'];
  static const double imageCompressionQuality = 0.8;

  // Location Configuration
  static const double locationAccuracyThreshold = 100.0; // meters
  static const Duration locationTimeout = Duration(seconds: 30);

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Error Messages
  static const String networkErrorMessage =
      'Network connection failed. Please check your internet connection.';
  static const String locationErrorMessage =
      'Unable to get your location. Please enable location services.';
  static const String imagePickerErrorMessage =
      'Unable to capture or select image. Please try again.';
  static const String apiErrorMessage =
      'Service temporarily unavailable. Please try again later.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
}
