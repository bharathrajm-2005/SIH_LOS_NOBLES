import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/whisper_service.dart';
import 'core/utils/app_colors.dart';
import 'features/home/home_screen.dart';
import 'features/crop_ai/crop_ai_screen.dart';
import 'features/pest_detection/pest_detection_screen.dart';
import 'features/crop_recommendation/crop_recommendation_screen.dart';
import 'features/weather/weather_screen.dart';
import 'features/government_schemes/government_schemes_screen.dart';

class CropAdvisorApp extends StatelessWidget {
  const CropAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WhisperService()),
      ],
      child: MaterialApp(
      title: 'CropAdvisor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Better readability for farmers
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
            letterSpacing: 0.5,
          ),
          shadowColor: AppColors.primaryDark.withOpacity(0.3),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: AppColors.backgroundColor,
        ),
      ),
      home: const MainNavigationScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/crop-ai': (context) => const CropAIScreen(),
        '/pest-detection': (context) => const PestDetectionScreen(),
        '/crop-recommendation': (context) => const CropRecommendationScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/government-schemes': (context) => const GovernmentSchemesScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final whisperService = Provider.of<WhisperService>(context, listen: false);
      await whisperService.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-initialize if needed when app comes to foreground
      _initializeApp();
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CropAIScreen(),
    const PestDetectionScreen(),
    const WeatherScreen(),
    const GovernmentSchemesScreen(),
  ];

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized 
          ? MouseRegion(
              cursor: SystemMouseCursors.basic,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                children: _screens,
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.textSecondary,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.agriculture, size: 24),
                activeIcon: Icon(Icons.agriculture, size: 28),
                label: 'Farm',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy, size: 24),
                activeIcon: Icon(Icons.smart_toy, size: 28),
                label: 'AI Helper',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pest_control, size: 24),
                activeIcon: Icon(Icons.pest_control, size: 28),
                label: 'Pest Care',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny, size: 24),
                activeIcon: Icon(Icons.wb_sunny, size: 28),
                label: 'Weather',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on, size: 24),
                activeIcon: Icon(Icons.monetization_on, size: 28),
                label: 'Schemes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
