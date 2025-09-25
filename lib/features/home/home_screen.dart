import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../../core/services/weather_service.dart';
import '../../core/services/government_schemes_service.dart';
import '../../core/models/weather_model.dart';
import '../../core/models/government_scheme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_selector.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const HomeScreen({super.key, this.onLanguageChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  WeatherModel? _currentWeather;
  List<GovernmentSchemeModel> _featuredSchemes = [];
  bool _isLoadingWeather = false;
  bool _isLoadingSchemes = false;
  String? _weatherError;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadWeatherData();
    _loadFeaturedSchemes();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      final weatherService =
          Provider.of<WeatherService>(context, listen: false);
      final weather = await weatherService.getWeatherByLocation();

      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherError = e.toString();
          _isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> _loadFeaturedSchemes() async {
    setState(() {
      _isLoadingSchemes = true;
    });

    try {
      final schemesService =
          Provider.of<GovernmentSchemesService>(context, listen: false);
      final schemes = await schemesService.getFeaturedSchemes();

      if (mounted) {
        setState(() {
          _featuredSchemes = schemes.take(3).toList();
          _isLoadingSchemes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSchemes = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: CustomScrollView(
        slivers: [
          // Enhanced Farmer-themed App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.leafGreen,
                    AppColors.skyBlue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements - repositioned to avoid overlap
                  Positioned(
                    top: 30,
                    right: 80,
                    child: Icon(
                      Icons.wb_sunny,
                      color: AppColors.sunYellow.withOpacity(0.25),
                      size: 32,
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 40,
                    child: Icon(
                      Icons.grass,
                      color: Colors.white.withOpacity(0.2),
                      size: 28,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Icon(
                      Icons.agriculture,
                      color: Colors.white.withOpacity(0.15),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            title: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localizations.appName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '🌾 Your Smart Farming Partner',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Language selector
              if (widget.onLanguageChanged != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: LanguageSelector(
                    onLanguageChanged: widget.onLanguageChanged!,
                  ),
                ),
              
              // Profile icon
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showProfileMenu(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    _buildWelcomeCard(localizations),

                    const SizedBox(height: 20),

                    // Quick Actions
                    _buildQuickActionsGrid(localizations),

                    const SizedBox(height: 20),

                    // Today's Weather
                    _buildModernWeatherCard(localizations),

                    const SizedBox(height: 20),

                    // Farming Tips
                    _buildFarmingTipsCard(localizations),

                    const SizedBox(height: 32),

                    // Smart Farming Tools
                    _buildModernSmartToolsSection(localizations),

                    const SizedBox(height: 32),

                    // Farm Equipments
                    _buildModernEquipmentSection(localizations),

                    const SizedBox(height: 32),

                    // Government Schemes
                    _buildModernSchemesSection(localizations),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernWeatherCard(AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF64B5F6),
            Color(0xFF42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42A5F5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                localizations.todaysWeather, // Using localization
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingWeather)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentWeather != null
                          ? '${_currentWeather!.temperature.round()}°C'
                          : '25°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentWeather?.description ?? 'Partly Sunny',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentWeather?.cityName ?? 'Your Location',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.wb_cloudy_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildModernSmartToolsSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Farming Tools', // You can add this to localization files
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A42),
          ),
        ),
        const SizedBox(height: 30),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildModernToolCard(
              Icons.psychology_outlined,
              localizations.aiAssistant, // Using localization
              'Smart farming advice',
              const Color(0xFF4CAF50),
              () => Navigator.pushNamed(context, '/crop-ai'),
            ),
            _buildModernToolCard(
              Icons.bug_report_outlined,
              localizations.pestDetection, // Using localization
              'Identify crop diseases',
              const Color(0xFFFF7043),
              () => Navigator.pushNamed(context, '/pest-detection'),
            ),
            _buildModernToolCard(
              Icons.eco_outlined,
              'Crop Recommendation',
              'Best crops for you',
              const Color(0xFF66BB6A),
              () => Navigator.pushNamed(context, '/crop-recommendation'),
            ),
            _buildModernToolCard(
              Icons.cloud_outlined,
              localizations.weather,
              'Weather forecasts',
              const Color(0xFF42A5F5),
              () => Navigator.pushNamed(context, '/weather'),
            ),
            _buildModernToolCard(
              Icons.water_drop_outlined,
              localizations.irrigation, // Using localization
              'Smart watering tips',
              const Color(0xFF29B6F6),
              () => Navigator.pushNamed(context, '/irrigation'),
            ),
            _buildModernToolCard(
              Icons.terrain_outlined,
              localizations.soilHealth,
              'Monitor soil quality',
              const Color(0xFF8D6E63),
              () => Navigator.pushNamed(context, '/soil-health'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernToolCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 34,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A42),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEquipmentSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Equipments', // You can add this to localization files
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A42),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildModernEquipmentCard(
                Icons.agriculture,
                'Equipments',
                const Color(0xFF4CAF50),
                () => Navigator.pushNamed(context, '/equipment'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModernEquipmentCard(
                Icons.scatter_plot,
                'Pesticides',
                const Color(0xFFFF7043),
                () => Navigator.pushNamed(context, '/pesticides'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModernEquipmentCard(
                Icons.grass,
                'Fertilizers',
                const Color(0xFF66BB6A),
                () => Navigator.pushNamed(context, '/fertizilers'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModernEquipmentCard(
                Icons.pest_control,
                'Insecticides',
                const Color(0xFF29B6F6),
                () => Navigator.pushNamed(context, '/insecticides'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernEquipmentCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSchemesSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.featuredSchemes, // Using localization
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A42),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/government-schemes'),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildModernSchemeCard(
                'PM-KISAN',
                'Financial support for farmers',
                const Color(0xFF4CAF50),
                Icons.account_balance,
                localizations,
              ),
              const SizedBox(width: 16),
              _buildModernSchemeCard(
                'Pradhan Mantri Krishi Sinchayee Yojana',
                'Irrigation support scheme',
                const Color(0xFF2196F3),
                Icons.water_drop,
                localizations,
              ),
              const SizedBox(width: 16),
              _buildModernSchemeCard(
                'Farm Loan Waiver',
                'Agricultural loan relief',
                const Color(0xFFFF9800),
                Icons.money_off,
                localizations,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernSchemeCard(
    String title,
    String description,
    Color color,
    IconData icon,
    AppLocalizations localizations,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/government-schemes'),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A42),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFF4CAF50),
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.profile, // Using localization
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.welcomeMessage, // Using localization
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildProfileMenuItem(
                Icons.settings_outlined, localizations.settings, localizations),
            _buildProfileMenuItem(
                Icons.help_outline, 'Help & Support', localizations),
            _buildProfileMenuItem(Icons.info_outline, 'About', localizations),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
      IconData icon, String title, AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pop(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showComingSoonDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch_outlined,
                color: Color(0xFF4CAF50), size: 24),
            SizedBox(width: 12),
            Text('Coming Soon!', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'This amazing feature is under development and will be available in the next update.\n\nStay tuned for exciting farming tools!',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Awesome!',
              style: TextStyle(
                  color: Color(0xFF4CAF50), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Welcome Card
  Widget _buildWelcomeCard(AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.farmGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, Farmer! 🌾',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to grow something amazing today?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Quick Actions Grid
  Widget _buildQuickActionsGrid(AppLocalizations localizations) {
    final actions = [
      {
        'title': 'AI Assistant',
        'subtitle': 'Ask farming questions',
        'icon': Icons.smart_toy,
        'color': AppColors.primaryColor,
        'route': '/crop-ai',
      },
      {
        'title': 'Pest Detection',
        'subtitle': 'Identify crop issues',
        'icon': Icons.pest_control,
        'color': Colors.orange,
        'route': '/pest-detection',
      },
      {
        'title': 'Weather',
        'subtitle': 'Check conditions',
        'icon': Icons.wb_sunny,
        'color': Colors.blue,
        'route': '/weather',
      },
      {
        'title': 'Soil Health',
        'subtitle': 'Test your soil',
        'icon': Icons.grass,
        'color': Colors.brown,
        'route': '/soil-health',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.3,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, action['route'] as String),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (action['color'] as Color).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: (action['color'] as Color).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      action['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Farming Tips Card
  Widget _buildFarmingTipsCard(AppLocalizations localizations) {
    final tips = [
      '🌱 Water plants early morning for best absorption',
      '🌿 Rotate crops to maintain soil health',
      '🐛 Check plants daily for pest signs',
      '🌧️ Prepare drainage before monsoon season',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Today\'s Farming Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...tips
              .map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
