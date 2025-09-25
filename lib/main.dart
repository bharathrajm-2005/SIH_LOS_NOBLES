import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/mistral_service.dart';
import 'core/services/weather_service.dart';
import 'core/services/government_schemes_service.dart';
import 'core/services/language_service.dart';
import 'core/services/whisper_service.dart';
import 'core/utils/app_colors.dart';
import 'features/fertilizers/fertilizers_screen.dart';
import 'features/home/home_screen.dart';
import 'features/crop_ai/crop_ai_screen.dart';
import 'features/equipment/equipment_screen.dart';
import 'features/insecticides/insecticides_screen.dart';
import 'features/irrigation/irrigation_screen.dart';
import 'features/pest_detection/pest_detection_screen.dart';
import 'features/crop_recommendation/crop_recommendation_screen.dart';
import 'features/pesticides/pesticides_screen.dart';
import 'features/weather/weather_screen.dart';
import 'features/government_schemes/government_schemes_screen.dart';
import 'l10n/app_localizations.dart';
import 'features/soil_health/soil_health_screen.dart';
import 'test_voice_input.dart';
import 'simple_voice_test.dart';
import 'robust_voice_test.dart';
import 'working_voice_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for API keys
  try {
    await dotenv.load(fileName: "assets/.env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Failed to load .env file: $e');
    print('Continuing with fallback responses...');
  }

  // Initialize Mistral AI service
  // No initialization needed for Mistral service

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Get saved language
  final savedLanguage = await LanguageService.getCurrentLanguage();

  runApp(
    MultiProvider(
      providers: [
        Provider<WeatherService>(create: (_) => WeatherService()),
        Provider<GovernmentSchemesService>(
            create: (_) => GovernmentSchemesService()),
        ChangeNotifierProvider<WhisperService>(create: (_) => WhisperService()),
      ],
      child: MyApp(initialLanguage: savedLanguage),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialLanguage;

  const MyApp({super.key, required this.initialLanguage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.initialLanguage);
  }

  void _changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropAdvisor',
      debugShowCheckedModeBanner: false,

      // Localization - CRITICAL: This must be set for language changes to work
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.supportedLocales,

      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),

      home: MainNavigationScreen(onLanguageChanged: _changeLanguage),

      routes: {
        '/home': (context) => const HomeScreen(),
        '/crop-ai': (context) => const CropAIScreen(),
        '/pest-detection': (context) => const PestDetectionScreen(),
        '/crop-recommendation': (context) => const CropRecommendationScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/government-schemes': (context) => const GovernmentSchemesScreen(),
        '/soil-health': (context) => const SoilHealthScreen(),
        '/irrigation': (context) => const IrrigationScreen(),
        '/equipment': (context) => const EquipmentScreen(),
        '/pesticides': (context) => const PesticidesScreen(),
        '/fertizilers': (context) => const FertilizersScreen(),
        '/insecticides': (context) => const InsecticidesScreen(),
        '/test-voice': (context) => const VoiceInputTestScreen(),
        '/simple-voice': (context) => const SimpleVoiceTest(),
        '/robust-voice': (context) => const RobustVoiceTest(),
        '/working-voice': (context) => const WorkingVoiceTest(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const MainNavigationScreen({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Test Mistral connection on app start
    _testMistralConnection();
  }

  Future<void> _testMistralConnection() async {
    try {
      // Test Mistral connection by making a simple API call
      final response = await MistralService.generateResponse('Test connection');

      if (mounted) {
        if (response.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🤖 AI Assistant is ready!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ AI Assistant using offline mode'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Connection test error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ AI Service error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
        HomeScreen(
            onLanguageChanged: widget.onLanguageChanged), // Pass the callback
        const CropAIScreen(),
        const PestDetectionScreen(),
        const WeatherScreen(),
        const GovernmentSchemesScreen(),
      ];

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology_outlined),
            activeIcon: const Icon(Icons.psychology),
            label: localizations.aiAssistant,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bug_report_outlined),
            activeIcon: const Icon(Icons.bug_report),
            label: localizations.pestDetection,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud_outlined),
            activeIcon: const Icon(Icons.cloud),
            label: localizations.weather,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_outlined),
            activeIcon: const Icon(Icons.account_balance),
            label: localizations.schemes,
          ),
        ],
      ),
    );
  }
}
