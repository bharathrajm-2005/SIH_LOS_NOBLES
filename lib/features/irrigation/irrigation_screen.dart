// lib/features/irrigation/irrigation_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/mistral_service.dart';
import '../../core/utils/app_colors.dart';
import '../../l10n/app_localizations.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  File? _cropImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _irrigationPlan;

  // Form data
  String _cropType = 'vegetables';
  String _soilType = 'loamy';
  double _farmSize = 1.0;
  String _irrigationMethod = 'sprinkler';
  String _waterSource = 'borewell';
  String _season = 'kharif';
  String _location = '';
  int _cropAge = 30; // days
  String _growthStage = 'vegetative';
  bool _hasRainfall = false;
  double _lastRainfall = 0.0; // mm
  int _daysSinceRain = 0;
  String _soilMoisture = 'moderate';

  late AnimationController _animationController;
  late AnimationController _pulseController;

  final List<String> _steps = [
    'Crop Details',
    'Farm Setup',
    'Current Status',
    'Capture Image',
    'Irrigation Plan'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
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

  Future<void> _pickCropImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _cropImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _generateIrrigationPlan() async {
    if (_location.isEmpty) {
      _showErrorSnackBar('Please enter your location');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _animationController.repeat();
    });

    try {
      final prompt = '''
      Create a comprehensive irrigation plan based on the following farm details:
      
      **Crop Information:**
      - Crop Type: $_cropType
      - Growth Stage: $_growthStage
      - Crop Age: $_cropAge days
      - Season: $_season
      
      **Farm Setup:**
      - Location: $_location (India)
      - Farm Size: $_farmSize acres
      - Soil Type: $_soilType
      - Irrigation Method: $_irrigationMethod
      - Water Source: $_waterSource
      
      **Current Conditions:**
      - Soil Moisture: $_soilMoisture
      - Recent Rainfall: ${_hasRainfall ? "${_lastRainfall}mm, $_daysSinceRain days ago" : "No recent rainfall"}
      
      Please provide a detailed irrigation plan including:
      1. Recommended watering schedule (daily/weekly)
      2. Optimal timing for irrigation
      3. Water quantity recommendations
      4. Any adjustments needed for the current season
      5. Water conservation tips
      6. Signs of over/under watering to watch for
      
      Format your response in clear, well-structured markdown with appropriate headings.
      
      Please provide detailed irrigation recommendations for Indian farming conditions.
      Include frequency, duration, timing, water amounts, and efficiency tips.
      ''';

      final response = await MistralService.generateResponse(prompt);
      
      setState(() {
        _irrigationPlan = _createFallbackPlan(response);
        _isAnalyzing = false;
      });

      _animationController.stop();
      _nextStep();
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _irrigationPlan = _createFallbackPlan('Error generating plan');
      });
      _animationController.stop();
      _nextStep();
    }
  }

  Map<String, dynamic> _createFallbackPlan(String aiResponse) {
    // Create irrigation plan based on user inputs
    int frequency = 3; // Default: every 3 days
    int duration = 30; // Default: 30 minutes
    String bestTime = 'early_morning';

    // Adjust based on crop type and growth stage
    if (_cropType == 'vegetables') {
      frequency = 2; // More frequent for vegetables
      duration = 25;
    } else if (_cropType == 'cereals') {
      frequency = 3;
      duration = 35;
    }

    // Adjust for growth stage
    if (_growthStage == 'flowering' || _growthStage == 'fruiting') {
      frequency = 1; // Daily watering during critical stages
      duration += 10;
    }

    // Adjust for soil type
    if (_soilType == 'sandy') {
      frequency = 1; // More frequent for sandy soil
      duration -= 5;
    } else if (_soilType == 'clay') {
      frequency = 4; // Less frequent for clay soil
      duration += 10;
    }

    // Create weekly schedule
    List<Map<String, dynamic>> weeklyPlan = [];
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    for (int i = 0; i < days.length; i++) {
      bool shouldIrrigate =
          (i % frequency == 0) || (_growthStage == 'flowering' && i % 2 == 0);

      weeklyPlan.add({
        'day': days[i],
        'irrigate': shouldIrrigate,
        'duration': shouldIrrigate ? duration : 0,
        'time': shouldIrrigate
            ? (bestTime == 'early_morning' ? '6:00 AM' : '6:00 PM')
            : 'No irrigation',
        'water_amount': shouldIrrigate ? '${(duration * 0.8).round()}mm' : '0mm'
      });
    }

    return {
      'irrigation_schedule': {
        'frequency': frequency == 1
            ? 'daily'
            : frequency == 2
                ? 'alternate'
                : 'every_${frequency}_days',
        'duration_minutes': duration,
        'best_time': bestTime,
        'water_amount_per_session': '${(duration * 0.8).round()}mm'
      },
      'weekly_plan': weeklyPlan,
      'water_requirements': {
        'daily_requirement': _getDailyRequirement() + 'mm',
        'weekly_total': '${_getWeeklyTotal()}mm',
        'efficiency_rating': _getEfficiencyRating()
      },
      'soil_moisture_management': {
        'optimal_moisture': _getOptimalMoisture(),
        'monitoring_frequency': frequency <= 2 ? 'daily' : 'alternate',
        'indicators': _getMoistureIndicators()
      },
      'seasonal_adjustments': {
        'current_season_advice': _getSeasonalAdvice(),
        'next_month_changes': _getNextMonthChanges()
      },
      'efficiency_tips': _getEfficiencyTips(),
      'warning_signs': _getWarningSigns(),
      'cost_estimation': {
        'daily_water_cost': '₹${_getDailyCost()}',
        'monthly_cost': '₹${_getMonthlyCost()}'
      },
      'ai_response': aiResponse,
      'plan_method': 'intelligent_calculation',
      'analysis_time': DateTime.now().toIso8601String(),
    };
  }

  String _getDailyRequirement() {
    if (_cropType == 'vegetables') return '15-25';
    if (_cropType == 'cereals') return '20-30';
    if (_cropType == 'fruits') return '25-35';
    return '20-25';
  }

  int _getWeeklyTotal() {
    int daily = 20; // Average
    if (_cropType == 'vegetables') daily = 20;
    if (_cropType == 'cereals') daily = 25;
    if (_cropType == 'fruits') daily = 30;
    return daily * 7;
  }

  String _getEfficiencyRating() {
    if (_irrigationMethod == 'drip') return 'high';
    if (_irrigationMethod == 'sprinkler') return 'medium';
    return 'medium';
  }

  String _getOptimalMoisture() {
    if (_soilType == 'sandy') return '60-70%';
    if (_soilType == 'clay') return '70-80%';
    return '65-75%';
  }

  List<String> _getMoistureIndicators() {
    return [
      'Soil feels moist 2-3 inches deep',
      'Plants look turgid and healthy',
      'No wilting during midday heat',
      'Soil surface not cracked or dusty'
    ];
  }

  String _getSeasonalAdvice() {
    switch (_season) {
      case 'kharif':
        return 'Monsoon season - reduce irrigation frequency, focus on drainage';
      case 'rabi':
        return 'Winter season - moderate irrigation, morning watering preferred';
      case 'summer':
        return 'Hot season - increase frequency, early morning/evening irrigation';
      default:
        return 'Monitor weather conditions and adjust accordingly';
    }
  }

  String _getNextMonthChanges() {
    return 'Monitor crop development stage and adjust water requirements accordingly. Weather patterns may change seasonal needs.';
  }

  List<String> _getEfficiencyTips() {
    return [
      'Use mulching to reduce water evaporation',
      'Water during early morning (5-7 AM) for best absorption',
      'Check soil moisture before watering',
      'Maintain proper drainage to prevent waterlogging',
      'Group plants with similar water needs together'
    ];
  }

  List<String> _getWarningSigns() {
    return [
      'Overwatering: Yellowing leaves, fungal growth, waterlogged soil',
      'Underwatering: Wilting, dry soil, stunted growth, leaf drop',
      'Poor drainage: Standing water, foul smell, root rot signs'
    ];
  }

  int _getDailyCost() {
    double waterCostPerLiter = 0.02; // ₹0.02 per liter
    int dailyRequirement = 500; // liters for 1 acre average
    return (dailyRequirement * waterCostPerLiter * _farmSize).round();
  }

  int _getMonthlyCost() {
    return _getDailyCost() * 30;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Smart Irrigation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF29B6F6),
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
                colors: [Color(0xFF29B6F6), Color(0xFF42A5F5)],
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
                _buildCropDetailsStep(),
                _buildFarmSetupStep(),
                _buildCurrentStatusStep(),
                _buildImageCaptureStep(),
                _buildIrrigationPlanStep(),
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
                          side: const BorderSide(color: Color(0xFF29B6F6)),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _getNextAction(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF29B6F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isAnalyzing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _getNextButtonText(),
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

  VoidCallback? _getNextAction() {
    if (_currentStep == _steps.length - 2) {
      return _generateIrrigationPlan;
    }
    return _nextStep;
  }

  String _getNextButtonText() {
    if (_currentStep == _steps.length - 2) {
      return 'Generate Irrigation Plan';
    }
    return 'Next';
  }

  Widget _buildCropDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your crop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us create the perfect irrigation schedule',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Crop Type
          const Text(
            'What type of crop are you growing?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'vegetables',
              'cereals',
              'fruits',
              'cash_crops',
              'pulses'
            ].map((type) {
              final isSelected = _cropType == type;
              return GestureDetector(
                onTap: () => setState(() => _cropType = type),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF29B6F6) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF29B6F6)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    type.replaceAll('_', ' ').toUpperCase(),
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

          const SizedBox(height: 24),

          // Growth Stage
          const Text(
            'Current growth stage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              'seedling',
              'vegetative',
              'flowering',
              'fruiting',
              'maturity'
            ].map((stage) {
              final isSelected = _growthStage == stage;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _growthStage = stage),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF29B6F6).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF29B6F6)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStageIcon(stage),
                          color: isSelected
                              ? const Color(0xFF29B6F6)
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stage.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF29B6F6)
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                _getStageDescription(stage),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF29B6F6)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Crop Age
          const Text(
            'How old is your crop?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF29B6F6)),
                    const SizedBox(width: 8),
                    Text(
                      '$_cropAge days old',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _cropAge.toDouble(),
                  min: 1,
                  max: 200,
                  divisions: 199,
                  activeColor: const Color(0xFF29B6F6),
                  onChanged: (value) =>
                      setState(() => _cropAge = value.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1 day',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 10)),
                    Text('200 days',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmSetupStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Setup Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your irrigation infrastructure',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Location
          const Text(
            'Farm Location *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => _location = value,
            decoration: InputDecoration(
              hintText: 'Enter your location (city, state)',
              prefixIcon:
                  const Icon(Icons.location_on, color: Color(0xFF29B6F6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF29B6F6)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Farm Size
          const Text(
            'Farm Size',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.landscape, color: Color(0xFF29B6F6)),
                    const SizedBox(width: 8),
                    Text(
                      '${_farmSize.toStringAsFixed(1)} acres',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _farmSize,
                  min: 0.1,
                  max: 50.0,
                  divisions: 499,
                  activeColor: const Color(0xFF29B6F6),
                  onChanged: (value) => setState(() => _farmSize = value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0.1 acres',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 10)),
                    Text('50+ acres',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Soil Type
          const Text(
            'Soil Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'clay',
              'sandy',
              'loamy',
              'silt',
              'black_soil',
              'red_soil'
            ].map((soil) {
              final isSelected = _soilType == soil;
              return GestureDetector(
                onTap: () => setState(() => _soilType = soil),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF29B6F6) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF29B6F6)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    soil.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Irrigation Method
          const Text(
            'Current irrigation method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: ['drip', 'sprinkler', 'flood', 'furrow', 'manual']
                .map((method) {
              final isSelected = _irrigationMethod == method;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _irrigationMethod = method),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF29B6F6).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF29B6F6)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIrrigationIcon(method),
                          color: isSelected
                              ? const Color(0xFF29B6F6)
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF29B6F6)
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                _getIrrigationDescription(method),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF29B6F6)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Water Source
          const Text(
            'Water Source',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'borewell',
              'canal',
              'pond',
              'river',
              'rainwater',
              'municipal'
            ].map((source) {
              final isSelected = _waterSource == source;
              return GestureDetector(
                onTap: () => setState(() => _waterSource = source),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF29B6F6) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF29B6F6)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    source.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
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

  Widget _buildCurrentStatusStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Field Status',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about current conditions for optimal scheduling',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Season
          const Text(
            'Current growing season',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['kharif', 'rabi', 'summer'].map((season) {
              final isSelected = _season == season;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _season = season),
                  child: Container(
                    margin: EdgeInsets.only(right: season != 'summer' ? 8 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF29B6F6) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF29B6F6)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getSeasonIcon(season),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF29B6F6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          season.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Soil Moisture
          const Text(
            'Current soil moisture level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['dry', 'moderate', 'moist', 'wet'].map((moisture) {
              final isSelected = _soilMoisture == moisture;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _soilMoisture = moisture),
                  child: Container(
                    margin: EdgeInsets.only(right: moisture != 'wet' ? 8 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF29B6F6) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF29B6F6)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getMoistureIcon(moisture),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF29B6F6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          moisture.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Recent Rainfall
          const Text(
            'Recent rainfall information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          CheckboxListTile(
            title: const Text('Recent rainfall in your area'),
            subtitle: const Text('Check if it rained in the last 7 days'),
            value: _hasRainfall,
            onChanged: (value) => setState(() => _hasRainfall = value ?? false),
            activeColor: const Color(0xFF29B6F6),
          ),

          if (_hasRainfall) ...[
            const SizedBox(height: 16),
            const Text(
              'Rainfall details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        _lastRainfall = double.tryParse(value) ?? 0.0,
                    decoration: InputDecoration(
                      labelText: 'Amount (mm)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF29B6F6)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        _daysSinceRain = int.tryParse(value) ?? 0,
                    decoration: InputDecoration(
                      labelText: 'Days ago',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF29B6F6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageCaptureStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crop Visual Assessment (Optional)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo of your crop for better irrigation recommendations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Tips for good crop photo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF29B6F6).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Photo Tips for Best Results',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('• Take photo during daylight hours'),
                const Text('• Show overall crop condition'),
                const Text('• Include soil visibility around plants'),
                const Text('• Capture any stress signs (wilting, yellowing)'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_cropImage == null)
            // Image capture area
            GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF29B6F6).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 48,
                      color: Color(0xFF29B6F6),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tap to Capture Crop Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A42),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Optional - helps improve recommendations',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Selected image preview
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _cropImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showImageSourceDialog(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF29B6F6),
                          side: const BorderSide(color: Color(0xFF29B6F6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check),
                        label: const Text('Use This Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Skip option
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600),
                const SizedBox(height: 8),
                Text(
                  'Photo is optional',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  'You can proceed without a photo. We\'ll use the information you provided to create your irrigation plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIrrigationPlanStep() {
    if (_irrigationPlan == null) {
      return const Center(
        child: Text('No irrigation plan available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFF29B6F6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Smart Irrigation Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A42),
                      ),
                    ),
                    Text(
                      'Customized for your crop and conditions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Schedule Summary
          _buildScheduleSummary(),

          const SizedBox(height: 20),

          // Weekly Plan
          _buildWeeklyPlan(),

          const SizedBox(height: 20),

          // Water Requirements
          _buildWaterRequirements(),

          const SizedBox(height: 20),

          // Efficiency Tips
          _buildEfficiencyTips(),

          const SizedBox(height: 20),

          // Cost Estimation
          _buildCostEstimation(),

          const SizedBox(height: 20),

          // Warning Signs
          _buildWarningSigns(),

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildScheduleSummary() {
    final schedule =
        _irrigationPlan!['irrigation_schedule'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Irrigation Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScheduleItem(
                  Icons.schedule,
                  'Frequency',
                  schedule['frequency'].toString().replaceAll('_', ' '),
                ),
              ),
              Expanded(
                child: _buildScheduleItem(
                  Icons.timer,
                  'Duration',
                  '${schedule['duration_minutes']} min',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScheduleItem(
                  Icons.wb_sunny,
                  'Best Time',
                  schedule['best_time'].toString().replaceAll('_', ' '),
                ),
              ),
              Expanded(
                child: _buildScheduleItem(
                  Icons.opacity,
                  'Water Amount',
                  schedule['water_amount_per_session'].toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPlan() {
    final weeklyPlan = _irrigationPlan!['weekly_plan'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.calendar_view_week, color: Color(0xFF29B6F6)),
              SizedBox(width: 8),
              Text(
                'Weekly Irrigation Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...weeklyPlan
              .map(
                (day) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: day['irrigate']
                        ? const Color(0xFF29B6F6).withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: day['irrigate']
                          ? const Color(0xFF29B6F6).withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: day['irrigate']
                              ? const Color(0xFF29B6F6)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          day['irrigate']
                              ? Icons.water_drop
                              : Icons.water_drop_outlined,
                          color: day['irrigate']
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day['day'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: day['irrigate']
                                    ? const Color(0xFF29B6F6)
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  day['time'],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                if (day['irrigate']) ...[
                                  const Text(' • ',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                    '${day['duration']} min',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const Text(' • ',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                    day['water_amount'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildWaterRequirements() {
    final waterReqs =
        _irrigationPlan!['water_requirements'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.assessment, color: Color(0xFF29B6F6)),
              SizedBox(width: 8),
              Text(
                'Water Requirements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRequirementCard(
                  'Daily Need',
                  waterReqs['daily_requirement'].toString(),
                  Icons.today,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRequirementCard(
                  'Weekly Total',
                  waterReqs['weekly_total'].toString(),
                  Icons.view_week,
                  const Color(0xFF29B6F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRequirementCard(
                  'Efficiency',
                  waterReqs['efficiency_rating'].toString(),
                  Icons.eco,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyTips() {
    final tips = _irrigationPlan!['efficiency_tips'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Text(
                'Efficiency Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips
              .map((tip) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9800),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCostEstimation() {
    final cost = _irrigationPlan!['cost_estimation'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.currency_rupee, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'Cost Estimation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Daily Water Cost',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cost['daily_water_cost'].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29B6F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Monthly Cost',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF29B6F6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cost['monthly_cost'].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningSigns() {
    final warnings = _irrigationPlan!['warning_signs'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Color(0xFFFF5722)),
              SizedBox(width: 8),
              Text(
                'Warning Signs to Watch',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...warnings
              .map((warning) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFFF5722).withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Color(0xFFFF5722),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning.toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _irrigationPlan = null;
                    _cropImage = null;
                  });
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Create New Plan'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF29B6F6)),
                  foregroundColor: const Color(0xFF29B6F6),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/crop-ai');
            },
            icon: const Icon(Icons.chat),
            label: const Text('Get More AI Advice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF29B6F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    Icons.camera_alt,
                    'Camera',
                    'Take a photo',
                    () {
                      Navigator.pop(context);
                      _pickCropImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceOption(
                    Icons.photo_library,
                    'Gallery',
                    'Choose photo',
                    () {
                      Navigator.pop(context);
                      _pickCropImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF29B6F6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF29B6F6).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF29B6F6),
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for icons and descriptions
  IconData _getStageIcon(String stage) {
    switch (stage) {
      case 'seedling':
        return Icons.eco_outlined;
      case 'vegetative':
        return Icons.grass;
      case 'flowering':
        return Icons.local_florist;
      case 'fruiting':
        return Icons.emoji_nature;
      case 'maturity':
        return Icons.agriculture;
      default:
        return Icons.help;
    }
  }

  String _getStageDescription(String stage) {
    switch (stage) {
      case 'seedling':
        return 'Young plants, tender stage';
      case 'vegetative':
        return 'Active growth, leaf development';
      case 'flowering':
        return 'Flower formation, critical stage';
      case 'fruiting':
        return 'Fruit/grain development';
      case 'maturity':
        return 'Ready for harvest';
      default:
        return '';
    }
  }

  IconData _getIrrigationIcon(String method) {
    switch (method) {
      case 'drip':
        return Icons.water_drop;
      case 'sprinkler':
        return Icons.shower;
      case 'flood':
        return Icons.water;
      case 'furrow':
        return Icons.landscape;
      case 'manual':
        return Icons.pan_tool;
      default:
        return Icons.water_drop;
    }
  }

  String _getIrrigationDescription(String method) {
    switch (method) {
      case 'drip':
        return 'Most efficient, targeted watering';
      case 'sprinkler':
        return 'Good coverage, moderate efficiency';
      case 'flood':
        return 'Traditional method, high water use';
      case 'furrow':
        return 'Row-based watering system';
      case 'manual':
        return 'Hand watering with hose/bucket';
      default:
        return '';
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

  IconData _getMoistureIcon(String moisture) {
    switch (moisture) {
      case 'dry':
        return Icons.water_drop_outlined;
      case 'moderate':
        return Icons.water_drop;
      case 'moist':
        return Icons.opacity;
      case 'wet':
        return Icons.water;
      default:
        return Icons.water_drop;
    }
  }
}
