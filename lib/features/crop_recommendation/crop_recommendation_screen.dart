// lib/features/crop_recommendation/crop_recommendation_screen.dart
import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';
import '../../l10n/app_localizations.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _recommendations = [];

  // Form data
  String _farmType = 'vegetable';
  double _farmSize = 1.0;
  String _soilType = 'loamy';
  String _location = '';
  String _season = 'kharif';
  String _waterAvailability = 'moderate';
  double _budget = 25000;
  String _experience = 'intermediate';
  String _primaryGoal = 'maximum_profit';

  final List<String> _steps = [
    'Farm Type',
    'Farm Size & Soil',
    'Location & Season',
    'Budget & Experience',
    'Your Goals',
    'Recommendations'
  ];

  // Crop database
  static final Map<String, List<Map<String, dynamic>>> _cropDatabase = {
    'vegetable': [
      {
        'cropName': 'Tomato',
        'description':
            'High-demand vegetable crop suitable for various climates',
        'growthDuration': 90,
        'expectedYield': 15000.0,
        'investmentRequired': 25000.0,
        'expectedProfit': 40000.0,
        'difficulty': 'Medium',
        'requirements': [
          'Well-drained soil',
          'Regular watering',
          'Support structures'
        ],
        'benefits': [
          'High market demand',
          'Multiple harvests',
          'Good profit margin'
        ],
        'bestSeason': 'Winter',
        'marketDemand': 'High',
        'suitabilityScore': 95.0,
      },
      {
        'cropName': 'Onion',
        'description':
            'Essential cooking ingredient with consistent market demand',
        'growthDuration': 120,
        'expectedYield': 12000.0,
        'investmentRequired': 20000.0,
        'expectedProfit': 35000.0,
        'difficulty': 'Easy',
        'requirements': ['Well-drained soil', 'Moderate watering'],
        'benefits': [
          'Long storage life',
          'Consistent demand',
          'Low maintenance'
        ],
        'bestSeason': 'Rabi',
        'marketDemand': 'High',
        'suitabilityScore': 90.0,
      },
      {
        'cropName': 'Potato',
        'description': 'Staple food crop with good market value',
        'growthDuration': 100,
        'expectedYield': 20000.0,
        'investmentRequired': 30000.0,
        'expectedProfit': 45000.0,
        'difficulty': 'Medium',
        'requirements': [
          'Cool climate',
          'Well-drained soil',
          'Regular irrigation'
        ],
        'benefits': ['High yield', 'Multiple uses', 'Good storage'],
        'bestSeason': 'Winter',
        'marketDemand': 'High',
        'suitabilityScore': 85.0,
      },
      {
        'cropName': 'Cauliflower',
        'description': 'Premium vegetable with excellent market price',
        'growthDuration': 80,
        'expectedYield': 18000.0,
        'investmentRequired': 22000.0,
        'expectedProfit': 38000.0,
        'difficulty': 'Medium',
        'requirements': ['Cool weather', 'Rich soil', 'Regular care'],
        'benefits': ['High price', 'Quick growth', 'Export potential'],
        'bestSeason': 'Winter',
        'marketDemand': 'High',
        'suitabilityScore': 82.0,
      },
    ],
    'grain': [
      {
        'cropName': 'Rice',
        'description': 'Primary staple food crop suitable for irrigated land',
        'growthDuration': 130,
        'expectedYield': 2500.0,
        'investmentRequired': 35000.0,
        'expectedProfit': 25000.0,
        'difficulty': 'Medium',
        'requirements': ['Flooded fields', 'Clay soil', 'Abundant water'],
        'benefits': ['Government support', 'MSP available', 'Food security'],
        'bestSeason': 'Kharif',
        'marketDemand': 'High',
        'suitabilityScore': 80.0,
      },
      {
        'cropName': 'Wheat',
        'description': 'Major cereal crop suitable for dry land farming',
        'growthDuration': 140,
        'expectedYield': 2000.0,
        'investmentRequired': 30000.0,
        'expectedProfit': 20000.0,
        'difficulty': 'Easy',
        'requirements': ['Well-drained soil', 'Cool climate', 'Moderate water'],
        'benefits': ['MSP guaranteed', 'Low risk', 'Easy to grow'],
        'bestSeason': 'Rabi',
        'marketDemand': 'High',
        'suitabilityScore': 88.0,
      },
      {
        'cropName': 'Corn (Maize)',
        'description': 'Versatile crop with multiple uses and good market',
        'growthDuration': 110,
        'expectedYield': 3000.0,
        'investmentRequired': 28000.0,
        'expectedProfit': 32000.0,
        'difficulty': 'Easy',
        'requirements': [
          'Well-drained soil',
          'Moderate rainfall',
          'Sunny weather'
        ],
        'benefits': ['Multiple uses', 'Good yield', 'Industrial demand'],
        'bestSeason': 'Kharif',
        'marketDemand': 'Medium',
        'suitabilityScore': 75.0,
      },
    ],
    'fruit': [
      {
        'cropName': 'Mango',
        'description': 'High-value fruit crop suitable for warm climates',
        'growthDuration': 1095, // 3 years
        'expectedYield': 5000.0,
        'investmentRequired': 100000.0,
        'expectedProfit': 200000.0,
        'difficulty': 'Hard',
        'requirements': [
          'Well-drained soil',
          'Hot climate',
          'Long-term investment'
        ],
        'benefits': ['Very high profit', 'Premium market', 'Long-term income'],
        'bestSeason': 'Summer',
        'marketDemand': 'High',
        'suitabilityScore': 70.0,
      },
      {
        'cropName': 'Banana',
        'description': 'Year-round fruit crop with consistent income',
        'growthDuration': 365,
        'expectedYield': 25000.0,
        'investmentRequired': 60000.0,
        'expectedProfit': 80000.0,
        'difficulty': 'Medium',
        'requirements': ['Rich soil', 'Regular water', 'Warm climate'],
        'benefits': ['Year-round income', 'High demand', 'Multiple varieties'],
        'bestSeason': 'Year Round',
        'marketDemand': 'High',
        'suitabilityScore': 85.0,
      },
      {
        'cropName': 'Papaya',
        'description': 'Fast-growing fruit with medicinal properties',
        'growthDuration': 300,
        'expectedYield': 15000.0,
        'investmentRequired': 40000.0,
        'expectedProfit': 60000.0,
        'difficulty': 'Easy',
        'requirements': [
          'Well-drained soil',
          'Warm climate',
          'Protection from wind'
        ],
        'benefits': ['Quick returns', 'Medicinal value', 'Export potential'],
        'bestSeason': 'Year Round',
        'marketDemand': 'Medium',
        'suitabilityScore': 78.0,
      },
    ],
    'cash_crop': [
      {
        'cropName': 'Cotton',
        'description': 'Major cash crop with good export potential',
        'growthDuration': 180,
        'expectedYield': 800.0,
        'investmentRequired': 40000.0,
        'expectedProfit': 35000.0,
        'difficulty': 'Hard',
        'requirements': [
          'Black cotton soil',
          'Moderate rainfall',
          'Pest management'
        ],
        'benefits': [
          'Export market',
          'Government support',
          'Industrial demand'
        ],
        'bestSeason': 'Kharif',
        'marketDemand': 'Medium',
        'suitabilityScore': 65.0,
      },
      {
        'cropName': 'Sugarcane',
        'description': 'Long-duration cash crop with guaranteed market',
        'growthDuration': 365,
        'expectedYield': 50000.0,
        'investmentRequired': 80000.0,
        'expectedProfit': 60000.0,
        'difficulty': 'Medium',
        'requirements': ['Rich soil', 'Abundant water', 'Hot climate'],
        'benefits': [
          'Guaranteed market',
          'Government support',
          'Multiple products'
        ],
        'bestSeason': 'Year Round',
        'marketDemand': 'High',
        'suitabilityScore': 75.0,
      },
      {
        'cropName': 'Soybean',
        'description': 'Protein-rich oilseed crop with export potential',
        'growthDuration': 120,
        'expectedYield': 1500.0,
        'investmentRequired': 25000.0,
        'expectedProfit': 28000.0,
        'difficulty': 'Easy',
        'requirements': [
          'Well-drained soil',
          'Moderate rainfall',
          'Sunny weather'
        ],
        'benefits': ['Export market', 'Protein source', 'Soil improvement'],
        'bestSeason': 'Kharif',
        'marketDemand': 'High',
        'suitabilityScore': 80.0,
      },
    ],
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _generateRecommendations() {
    if (_location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your location')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      // Get crops from database based on farm type
      final crops = _cropDatabase[_farmType] ?? [];

      // Score and filter based on input parameters
      List<Map<String, dynamic>> scoredCrops = crops
          .map((crop) {
            double score = crop['suitabilityScore'].toDouble();

            // Adjust score based on budget
            if (crop['investmentRequired'] <= _budget) {
              score += 15;
            } else if (crop['investmentRequired'] > _budget * 1.5) {
              score -= 25;
            }

            // Adjust score based on farm size
            if (_farmSize >= 2.0) {
              score += 10;
            } else if (_farmSize < 0.5) {
              // Reduce score for crops that need large areas
              if (crop['cropName'] == 'Rice' ||
                  crop['cropName'] == 'Wheat' ||
                  crop['cropName'] == 'Cotton') {
                score -= 15;
              }
            }

            // Adjust score based on experience
            if (_experience == 'beginner' && crop['difficulty'] == 'Easy') {
              score += 20;
            } else if (_experience == 'beginner' &&
                crop['difficulty'] == 'Hard') {
              score -= 30;
            } else if (_experience == 'experienced' &&
                crop['difficulty'] == 'Hard') {
              score += 10;
            }

            // Adjust score based on season matching
            if (crop['bestSeason'].toLowerCase().contains(_season) ||
                crop['bestSeason'].toLowerCase() == 'year round') {
              score += 15;
            } else {
              score -= 10;
            }

            // Adjust score based on primary goal
            if (_primaryGoal == 'maximum_profit' &&
                crop['expectedProfit'] > 50000) {
              score += 15;
            } else if (_primaryGoal == 'low_risk' &&
                crop['difficulty'] == 'Easy') {
              score += 15;
            } else if (_primaryGoal == 'quick_returns' &&
                crop['growthDuration'] < 120) {
              score += 15;
            }

            // Create new crop map with updated score
            Map<String, dynamic> scoredCrop = Map<String, dynamic>.from(crop);
            scoredCrop['suitabilityScore'] = score.clamp(0, 100);
            return scoredCrop;
          })
          .where((crop) => crop['suitabilityScore'] >= 40)
          .toList();

      // Sort by suitability score
      scoredCrops.sort(
          (a, b) => b['suitabilityScore'].compareTo(a['suitabilityScore']));

      setState(() {
        _recommendations = scoredCrops.take(5).toList();
        _isLoading = false;
      });

      _nextStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Crop Recommendation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((_currentStep + 1) / _steps.length * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
                const SizedBox(height: 8),
                Text(
                  _steps[_currentStep],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFarmTypeStep(),
                _buildFarmSizeAndSoilStep(),
                _buildLocationAndSeasonStep(),
                _buildBudgetAndExperienceStep(),
                _buildGoalsStep(),
                _buildRecommendationsStep(),
              ],
            ),
          ),

          // Navigation Buttons
          if (_currentStep < _steps.length - 1)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _currentStep == _steps.length - 2
                          ? _generateRecommendations
                          : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == _steps.length - 2
                                  ? 'Get Recommendations'
                                  : 'Next',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFarmTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What type of farming are you interested in?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type that matches your goals and experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          _buildFarmTypeCard(
            'vegetable',
            'Vegetable Farming',
            'Grow vegetables like tomato, onion, potato',
            '🥕',
            'Quick returns, high market demand',
          ),
          const SizedBox(height: 16),
          _buildFarmTypeCard(
            'grain',
            'Grain Farming',
            'Grow staple crops like rice, wheat',
            '🌾',
            'Food security, government support',
          ),
          const SizedBox(height: 16),
          _buildFarmTypeCard(
            'fruit',
            'Fruit Farming',
            'Grow fruits like mango, banana, papaya',
            '🍎',
            'High profits, premium market',
          ),
          const SizedBox(height: 16),
          _buildFarmTypeCard(
            'cash_crop',
            'Cash Crops',
            'Grow cotton, sugarcane, soybean',
            '🌿',
            'Export potential, industrial use',
          ),
        ],
      ),
    );
  }

  Widget _buildFarmTypeCard(String value, String title, String description,
      String emoji, String benefit) {
    final isSelected = _farmType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _farmType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2E3A42),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmSizeAndSoilStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your farm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us recommend the right crops for your land',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Farm Size
          const Text(
            'How much land do you have?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.landscape, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    Text(
                      '${_farmSize.toStringAsFixed(1)} acres',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _farmSize,
                  min: 0.1,
                  max: 10.0,
                  divisions: 99,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) {
                    setState(() {
                      _farmSize = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0.1 acres',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    Text('10+ acres',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Soil Type
          const Text(
            'What type of soil do you have?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'clay',
              'sandy',
              'loamy',
              'black_soil',
              'red_soil',
              'alluvial'
            ].map((soil) {
              final isSelected = _soilType == soil;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _soilType = soil;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    soil.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF2E3A42),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndSeasonStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location & Farming Season',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your local conditions',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Location
          const Text(
            'Where is your farm located?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            onChanged: (value) {
              _location = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter your city/district (e.g., Pune, Maharashtra)',
              prefixIcon:
                  const Icon(Icons.location_on, color: Color(0xFF4CAF50)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Season
          const Text(
            'Which season are you planning to farm?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 16),

          ...['kharif', 'rabi', 'summer', 'year_round'].map((season) {
            final isSelected = _season == season;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _season = season;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getSeasonIcon(season),
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSeasonName(season),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF2E3A42),
                              ),
                            ),
                            Text(
                              _getSeasonDescription(season),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 32),

          // Water Availability
          const Text(
            'Water availability on your farm?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['abundant', 'moderate', 'limited', 'rainfed_only']
                .map((water) {
              final isSelected = _waterAvailability == water;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _waterAvailability = water;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    water.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF2E3A42),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetAndExperienceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget & Experience',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us recommend crops within your means',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Budget
          const Text(
            'What\'s your budget for farming?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    Text(
                      '₹${_budget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _budget,
                  min: 5000,
                  max: 200000,
                  divisions: 39,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) {
                    setState(() {
                      _budget = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹5,000',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    Text('₹2,00,000+',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Experience Level
          const Text(
            'What\'s your farming experience?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 16),

          ...['beginner', 'intermediate', 'experienced'].map((exp) {
            final isSelected = _experience == exp;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _experience = exp;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getExperienceIcon(exp),
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getExperienceName(exp),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF2E3A42),
                              ),
                            ),
                            Text(
                              _getExperienceDescription(exp),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your primary goal?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us prioritize the right crops for you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ...[
            'maximum_profit',
            'food_security',
            'low_risk',
            'quick_returns',
            'sustainable_farming'
          ].map((goal) {
            final isSelected = _primaryGoal == goal;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _primaryGoal = goal;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4CAF50).withOpacity(0.2)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getGoalIcon(goal),
                          color: isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGoalName(goal),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF2E3A42),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGoalDescription(goal),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFF4CAF50),
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your Crop Recommendations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A42),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your farm profile, here are the best crops for you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          if (_recommendations.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations available.\nPlease check your inputs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final crop = _recommendations[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildCropRecommendationCard(crop, index + 1),
                );
              },
            ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                      _recommendations = [];
                    });
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Start Over'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    foregroundColor: const Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/crop-ai');
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Get AI Advice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropRecommendationCard(Map<String, dynamic> crop, int rank) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: rank == 1
            ? Border.all(color: const Color(0xFF4CAF50), width: 2)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: rank == 1 ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop['cropName'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A42),
                      ),
                    ),
                    Text(
                      crop['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSuitabilityColor(crop['suitabilityScore'])
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${crop['suitabilityScore'].round()}% match',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getSuitabilityColor(crop['suitabilityScore']),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Key Information
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.schedule,
                  'Duration',
                  '${crop['growthDuration']} days',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.currency_rupee,
                  'Investment',
                  '₹${(crop['investmentRequired'] / 1000).toStringAsFixed(0)}K',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.trending_up,
                  'Profit',
                  '₹${(crop['expectedProfit'] / 1000).toStringAsFixed(0)}K',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Difficulty and Season
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      _getDifficultyColor(crop['difficulty']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  crop['difficulty'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getDifficultyColor(crop['difficulty']),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  crop['bestSeason'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Benefits
          const Text(
            'Key Benefits:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: (crop['benefits'] as List<String>)
                .take(3)
                .map((benefit) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A42),
          ),
        ),
      ],
    );
  }

  Color _getSuitabilityColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFFF5722);
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getSeasonIcon(String season) {
    switch (season) {
      case 'kharif':
        return Icons.wb_sunny;
      case 'rabi':
        return Icons.ac_unit;
      case 'summer':
        return Icons.wb_sunny;
      default:
        return Icons.calendar_today;
    }
  }

  String _getSeasonName(String season) {
    switch (season) {
      case 'kharif':
        return 'Kharif Season';
      case 'rabi':
        return 'Rabi Season';
      case 'summer':
        return 'Summer Season';
      case 'year_round':
        return 'Year Round';
      default:
        return season;
    }
  }

  String _getSeasonDescription(String season) {
    switch (season) {
      case 'kharif':
        return 'June-October (Monsoon season)';
      case 'rabi':
        return 'November-April (Winter season)';
      case 'summer':
        return 'March-June (Hot season)';
      case 'year_round':
        return 'Can be grown throughout the year';
      default:
        return '';
    }
  }

  IconData _getExperienceIcon(String experience) {
    switch (experience) {
      case 'beginner':
        return Icons.school;
      case 'intermediate':
        return Icons.trending_up;
      case 'experienced':
        return Icons.emoji_events;
      default:
        return Icons.person;
    }
  }

  String _getExperienceName(String experience) {
    switch (experience) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'experienced':
        return 'Experienced';
      default:
        return experience;
    }
  }

  String _getExperienceDescription(String experience) {
    switch (experience) {
      case 'beginner':
        return 'New to farming, prefer easy crops';
      case 'intermediate':
        return 'Some farming experience, moderate complexity';
      case 'experienced':
        return 'Expert farmer, comfortable with any crop';
      default:
        return '';
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'maximum_profit':
        return Icons.trending_up;
      case 'food_security':
        return Icons.security;
      case 'low_risk':
        return Icons.shield;
      case 'quick_returns':
        return Icons.flash_on;
      case 'sustainable_farming':
        return Icons.eco;
      default:
        return Icons.flag;
    }
  }

  String _getGoalName(String goal) {
    switch (goal) {
      case 'maximum_profit':
        return 'Maximum Profit';
      case 'food_security':
        return 'Food Security';
      case 'low_risk':
        return 'Low Risk';
      case 'quick_returns':
        return 'Quick Returns';
      case 'sustainable_farming':
        return 'Sustainable Farming';
      default:
        return goal;
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'maximum_profit':
        return 'Focus on high-value crops with best profit margins';
      case 'food_security':
        return 'Grow staple crops for family consumption';
      case 'low_risk':
        return 'Prefer safe, traditional crops with guaranteed market';
      case 'quick_returns':
        return 'Fast-growing crops with quick harvest cycles';
      case 'sustainable_farming':
        return 'Environment-friendly and organic farming practices';
      default:
        return '';
    }
  }
}
