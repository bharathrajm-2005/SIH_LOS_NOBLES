class ApiConstants {
  // OpenAI Configuration with your API key
  static const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY',
      defaultValue: '');
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String openAIChatCompletionsEndpoint = '/chat/completions';
  static const String openAIModel = 'gpt-3.5-turbo';
  static const String openAIVisionModel = 'gpt-4o-mini';

  // WeatherAPI.com Configuration
  static const String weatherApiKey = String.fromEnvironment('WEATHER_API_KEY',
      defaultValue: '471c40da64334faa95384058251309');
  static const String weatherBaseUrl = 'https://api.weatherapi.com/v1';
  static const String currentWeatherEndpoint = '/current.json';
  static const String forecastEndpoint = '/forecast.json';
  static const String historyEndpoint = '/history.json';
  static const String astronomyEndpoint = '/astronomy.json';
  static const String alertsEndpoint = '/alerts.json';

  // Crop Recommendation API Configuration
  static const String cropRecommendationBaseUrl =
      'https://api.croprecommendation.com';
  static const String recommendationEndpoint = '/v1/recommend';

  // Government Schemes API Configuration
  static const String governmentSchemesBaseUrl = 'https://api.data.gov.in';
  static const String schemesEndpoint = '/resource/schemes';
  static const String governmentApiKey = String.fromEnvironment(
      'GOVERNMENT_API_KEY',
      defaultValue: 'demo_government_key');

  // Agriculture APIs
  static const String soilApiBaseUrl = 'https://api.soilgrids.org';
  static const String soilEndpoint = '/v2.0/properties/query';

  // Plant Disease Database
  static const String plantNetBaseUrl = 'https://my-api.plantnet.org/v1';
  static const String plantNetApiKey = String.fromEnvironment(
      'PLANTNET_API_KEY',
      defaultValue: 'demo_plantnet_key');

  // App Configuration
  static const String appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const bool debugMode =
      bool.fromEnvironment('DEBUG_MODE', defaultValue: true);
  static const String appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  // API Rate Limits
  static const int openAIRateLimit =
      3500; // tokens per minute for gpt-3.5-turbo
  static const int weatherAPIRateLimit = 1000; // requests per day for free tier
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 45);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Image Processing Configuration
  static const int maxImageSizeBytes = 20 * 1024 * 1024; // 20MB
  static const double imageCompressionQuality = 0.8;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];

  // Cache Configuration
  static const Duration cacheValidityDuration = Duration(minutes: 30);
  static const Duration weatherCacheValidity = Duration(minutes: 15);
  static const Duration aiResponseCacheValidity = Duration(hours: 1);
  static const int maxCacheSize = 100;
  static const int maxWeatherCacheSize = 50;

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Location Configuration
  static const double defaultLatitude = 28.6139; // Delhi
  static const double defaultLongitude = 77.2090; // Delhi
  static const double locationAccuracyRadius = 1000.0; // meters

  // Common Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'CropAdvisor/$appVersion (Flutter)',
      };

  static Map<String, String> get openAIHeaders => {
        ...defaultHeaders,
        'Authorization': 'Bearer $openAIApiKey',
      };

  static Map<String, String> get weatherHeaders => {
        ...defaultHeaders,
      };

  static Map<String, String> get multipartHeaders => {
        'Accept': 'application/json',
        'User-Agent': 'CropAdvisor/$appVersion (Flutter)',
      };

  // OpenAI Configuration
  static Map<String, dynamic> get openAIChatConfig => {
        'model': openAIModel,
        'max_tokens': 1500,
        'temperature': 0.7,
        'top_p': 1.0,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      };

  static Map<String, dynamic> get openAIVisionConfig => {
        'model': openAIVisionModel,
        'max_tokens': 1000,
        'temperature': 0.5,
      };

  // Weather API Configuration
  static Map<String, String> get weatherApiParams => {
        'key': weatherApiKey,
        'aqi': 'yes',
        'alerts': 'yes',
      };

  // API Endpoints Builder Methods
  static String buildWeatherCurrentUrl(String location) {
    return '$weatherBaseUrl$currentWeatherEndpoint?key=$weatherApiKey&q=$location&aqi=yes';
  }

  static String buildWeatherForecastUrl(String location, int days) {
    return '$weatherBaseUrl$forecastEndpoint?key=$weatherApiKey&q=$location&days=$days&aqi=yes&alerts=yes';
  }

  static String buildWeatherHistoryUrl(String location, String date) {
    return '$weatherBaseUrl$historyEndpoint?key=$weatherApiKey&q=$location&dt=$date';
  }

  static String buildWeatherAstronomyUrl(String location, String date) {
    return '$weatherBaseUrl$astronomyEndpoint?key=$weatherApiKey&q=$location&dt=$date';
  }

  static String buildWeatherSearchUrl(String query) {
    return '$weatherBaseUrl/search.json?key=$weatherApiKey&q=$query';
  }

  static String buildOpenAIChatUrl() {
    return '$openAIBaseUrl$openAIChatCompletionsEndpoint';
  }

  static String buildOpenAIModelsUrl() {
    return '$openAIBaseUrl/models';
  }

  // API Key Validation
  static bool get hasValidOpenAIKey =>
      openAIApiKey.startsWith('sk-') && openAIApiKey.length > 40;

  static bool get hasValidWeatherKey =>
      weatherApiKey.length == 32 && weatherApiKey != 'demo_weather_key';

  static bool get hasValidGovernmentKey =>
      governmentApiKey != 'demo_government_key' && governmentApiKey.isNotEmpty;

  static bool get hasValidPlantNetKey =>
      plantNetApiKey != 'demo_plantnet_key' && plantNetApiKey.isNotEmpty;

  // Environment Checks
  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
  static bool get isDebug => debugMode;

  // Feature Flags
  static bool get enableAIFeatures => hasValidOpenAIKey;
  static bool get enableWeatherFeatures => hasValidWeatherKey;
  static bool get enableGovernmentSchemes => hasValidGovernmentKey;
  static bool get enableAdvancedImageAnalysis =>
      hasValidOpenAIKey && hasValidPlantNetKey;

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error':
        'Network connection failed. Please check your internet connection.',
    'location_error':
        'Unable to get your location. Please enable location services.',
    'image_picker_error':
        'Unable to capture or select image. Please try again.',
    'api_error': 'Service temporarily unavailable. Please try again later.',
    'unknown_error': 'An unexpected error occurred. Please try again.',
    'openai_limit_error':
        'AI service rate limit reached. Please try again in a few minutes.',
    'weather_limit_error':
        'Weather service limit reached. Please try again tomorrow.',
    'invalid_api_key': 'Invalid API key. Please check your configuration.',
    'image_too_large':
        'Image file is too large. Please select a smaller image.',
    'unsupported_format':
        'Unsupported image format. Please use JPG, PNG, or WebP.',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'data_loaded': 'Data loaded successfully',
    'image_analyzed': 'Image analyzed successfully',
    'weather_updated': 'Weather information updated',
    'recommendation_generated': 'Crop recommendation generated',
    'pest_identified': 'Pest/disease identified successfully',
  };

  // System Prompts for AI
  static const String cropAdvisorSystemPrompt = '''
You are an expert agricultural advisor with deep knowledge of crop science, soil management, pest control, and sustainable farming practices. 

Your role is to provide practical, actionable advice to farmers based on:
- Current weather conditions
- Soil characteristics
- Crop type and growth stage
- Local farming practices
- Seasonal considerations

Always provide:
1. Clear, specific recommendations
2. Reasoning behind your advice
3. Risk assessments and mitigation strategies
4. Best practices for sustainable farming
5. Cost-effective solutions

Keep responses concise but comprehensive, focusing on practical implementation.
''';

  static const String pestDetectionSystemPrompt = '''
You are an expert plant pathologist specializing in crop disease and pest identification. 

Analyze the provided plant image and identify:
1. Any visible pests, diseases, or health issues
2. Severity level (Low/Medium/High/Critical)
3. Specific treatment recommendations
4. Prevention measures for future occurrences
5. Expected timeline for recovery

Provide accurate, actionable advice that farmers can implement immediately. 
If the image quality is poor or identification is uncertain, acknowledge limitations and suggest next steps.
''';

  static const String cropRecommendationSystemPrompt = '''
You are an agricultural expert specializing in crop selection and farming optimization.

Based on the provided information about:
- Geographic location and climate
- Soil conditions
- Available resources
- Market considerations
- Seasonal timing

Recommend the most suitable crops with:
1. Suitability score and reasoning
2. Expected yield and profitability
3. Resource requirements (water, fertilizer, labor)
4. Market demand and pricing trends
5. Risk factors and mitigation strategies

Prioritize sustainable, profitable, and locally appropriate recommendations.
''';

  // Logging Configuration
  static bool get enableDetailedLogging => isDebug;
  static bool get enableAPILogging => isDebug;
  static bool get enablePerformanceLogging => isDebug;

  // Database Configuration
  static const String databaseName = 'cropadvisor.db';
  static const int databaseVersion = 1;

  // Notification Configuration
  static const String notificationChannelId = 'cropadvisor_notifications';
  static const String notificationChannelName = 'CropAdvisor Notifications';
  static const String notificationChannelDescription =
      'Notifications for weather alerts and farming reminders';

  // Backup and Sync Configuration
  static const Duration syncInterval = Duration(hours: 6);
  static const Duration backupInterval = Duration(days: 1);
  static const int maxBackupFiles = 7;

  // Performance Monitoring
  static const Duration performanceThreshold = Duration(seconds: 3);
  static const int maxConcurrentRequests = 5;

  // Security Configuration
  static const Duration sessionTimeout = Duration(hours: 24);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 30);

  // Analytics Configuration
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => true;
  static bool get enableUserTracking => false; // Privacy-focused

  // URL Builders for different services
  static String buildCropRecommendationUrl(Map<String, dynamic> params) {
    final queryParams = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return '$cropRecommendationBaseUrl$recommendationEndpoint?$queryParams';
  }

  static String buildGovernmentSchemeUrl({
    String? category,
    String? state,
    int? limit,
  }) {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (state != null) params['state'] = state;
    if (limit != null) params['limit'] = limit.toString();

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$governmentSchemesBaseUrl$schemesEndpoint${queryString.isNotEmpty ? '?$queryString' : ''}';
  }

  // Validation methods
  static bool isValidLatitude(double? lat) {
    return lat != null && lat >= -90.0 && lat <= 90.0;
  }

  static bool isValidLongitude(double? lon) {
    return lon != null && lon >= -180.0 && lon <= 180.0;
  }

  static bool isValidImageFile(String? path) {
    if (path == null || path.isEmpty) return false;
    final extension = path.split('.').last.toLowerCase();
    return supportedImageFormats.contains(extension);
  }

  // Helper methods for API responses
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  // Rate limiting helpers
  static Duration getRateLimitDelay(int attemptNumber) {
    return Duration(seconds: (attemptNumber * attemptNumber * 2).clamp(1, 30));
  }

  // Cache key generators
  static String generateWeatherCacheKey(String location, String type) {
    return 'weather_${type}_${location.toLowerCase().replaceAll(' ', '_')}';
  }

  static String generateAICacheKey(String prompt) {
    return 'ai_${prompt.hashCode.abs()}';
  }
}
