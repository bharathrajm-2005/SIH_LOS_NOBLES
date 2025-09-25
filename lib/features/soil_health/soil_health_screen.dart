// lib/features/soil_health/soil_health_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/mistral_service.dart';
import '../../core/utils/app_colors.dart';
import '../../l10n/app_localizations.dart';

class SoilHealthScreen extends StatefulWidget {
  const SoilHealthScreen({super.key});

  @override
  State<SoilHealthScreen> createState() => _SoilHealthScreenState();
}

class _SoilHealthScreenState extends State<SoilHealthScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  File? _soilImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  // Form data for manual input
  String _soilColor = 'brown';
  String _soilTexture = 'loamy';
  String _drainage = 'good';
  String _cropHistory = '';
  String _fertilizers = '';
  String _location = '';
  double _ph = 7.0;
  bool _hasWaterlogging = false;
  bool _hasSaltDeposits = false;
  
  // Additional soil analysis variables
  String? _soilPh;
  String? _organicMatter;
  String? _nitrogenLevel;
  String? _phosphorusLevel;
  String? _potassiumLevel;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final List<String> _steps = [
    'Choose Method',
    'Soil Image',
    'Basic Info',
    'Soil Conditions',
    'Analysis Results'
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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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

  Future<void> _pickSoilImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _soilImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _analyzeSoilHealth() async {
    setState(() {
      _isAnalyzing = true;
      _animationController.repeat();
    });

    try {
      String analysisPrompt;

      if (_soilImage != null) {
        // Inform user that image analysis isn't supported with Mistral
        setState(() {
          _isAnalyzing = false;
          _animationController.stop();
          _showErrorSnackBar(
            'Image analysis not supported. Please provide text description instead.',
          );
        });
        return;
      }
      
      // Text-based analysis
      analysisPrompt = '''
      Please provide a comprehensive soil health assessment based on the following details:
      
      **Location:** $_location
      **Crop History:** $_cropHistory
      **Previous Fertilizers Used:** $_fertilizers
      **Observed Drainage:** $_drainage
      **Waterlogging Issues:** ${_hasWaterlogging ? 'Yes' : 'No'}
      **Salt Deposits Observed:** ${_hasSaltDeposits ? 'Yes' : 'No'}
      **Soil Texture:** ${_soilTexture ?? 'Not specified'}
      **Soil pH:** ${_soilPh ?? 'Not specified'}
      **Organic Matter:** ${_organicMatter ?? 'Not specified'}
      **Nutrient Levels:**
      - Nitrogen: ${_nitrogenLevel ?? 'Not specified'}
      - Phosphorus: ${_phosphorusLevel ?? 'Not specified'}
      - Potassium: ${_potassiumLevel ?? 'Not specified'}
      
      Please provide a detailed analysis including:
      1. Soil health assessment
      2. Nutrient status
      3. Recommendations for improvement
      4. Suitable crops for this soil type
      5. Any other relevant observations
      
      Format your response in the following JSON structure:
      {
        "overall_health": "good/fair/poor",
        "health_score": 0-100,
        "soil_type": "type of soil",
        "color_analysis": "description of soil color",
        "texture": "${_soilTexture ?? 'Not specified'}",
        "organic_matter": "high/medium/low",
        "moisture_level": "optimal/too_dry/too_wet",
        "ph_estimate": ${_ph},
        "nutrient_analysis": {
          "nitrogen": "high/medium/low",
          "phosphorus": "high/medium/low",
          "potassium": "high/medium/low",
          "organic_carbon": "high/medium/low"
        },
        "issues_detected": ["list", "of", "issues"],
        "recommendations": {
          "immediate_actions": ["action1", "action2"],
          "soil_amendments": ["list", "of", "amendments"],
          "fertilizer_recommendations": "specific NPK recommendations",
          "irrigation_advice": "watering guidelines",
          "crop_suitability": ["list", "of", "suitable", "crops"]
        },
        "seasonal_care": {
          "pre_monsoon": "preparation steps",
          "monsoon": "care during rains", 
          "post_monsoon": "recovery steps",
          "winter": "winter care"
        },
        "improvement_timeline": "expected time for soil improvement",
        "cost_estimate": "approximate cost for recommended treatments"
      }
      
      Be specific and practical in recommendations for Indian farming conditions.
      ''';

      try {
        final response = await MistralService.generateResponse(analysisPrompt);
        _processAnalysisResponse(response);
      } catch (e) {
        // If there's an error with Mistral, use fallback
        final fallbackResponse = _createFallbackAnalysis(analysisPrompt);
        _processAnalysisResponse(jsonEncode(fallbackResponse));
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisResult = {
          'error': 'Analysis failed: ${e.toString()}',
          'overall_health': 'unknown',
          'health_score': 0,
        };
      });
      _animationController.stop();
    }
  }

  void _processAnalysisResponse(String response) {
    try {
      Map<String, dynamic> analysisData = jsonDecode(response);

      // Add timestamp and method
      analysisData['analysis_time'] = DateTime.now().toIso8601String();
      analysisData['analysis_method'] =
          _soilImage != null ? 'image_based' : 'manual_input';
      analysisData['image_path'] = _soilImage?.path;

      setState(() {
        _analysisResult = analysisData;
        _isAnalyzing = false;
      });

      _animationController.stop();
      _nextStep();
    } catch (e) {
      // Fallback if JSON parsing fails
      setState(() {
        _analysisResult = _createFallbackAnalysis(response);
        _isAnalyzing = false;
      });
      _animationController.stop();
      _nextStep();
    }
  }

  Map<String, dynamic> _createFallbackAnalysis(String response) {
    return {
      'overall_health': 'fair',
      'health_score': 70,
      'soil_type': _soilTexture,
      'color_analysis': 'Based on $_soilColor color',
      'texture': _soilTexture,
      'organic_matter': 'medium',
      'moisture_level': _drainage == 'good' ? 'optimal' : 'needs_attention',
      'ph_estimate': _ph,
      'nutrient_analysis': {
        'nitrogen': 'medium',
        'phosphorus': 'medium',
        'potassium': 'medium',
        'organic_carbon': 'medium'
      },
      'issues_detected': _hasWaterlogging ? ['waterlogging'] : [],
      'recommendations': {
        'immediate_actions': ['Soil testing', 'Organic matter addition'],
        'soil_amendments': ['Compost', 'Organic fertilizer'],
        'fertilizer_recommendations': 'NPK 10:26:26 for balanced nutrition',
        'irrigation_advice': 'Maintain proper drainage',
        'crop_suitability': ['Vegetables', 'Cereals']
      },
      'full_analysis':
          response.length > 500 ? response.substring(0, 500) + '...' : response,
      'analysis_time': DateTime.now().toIso8601String(),
      'analysis_method': _soilImage != null ? 'image_based' : 'manual_input',
    };
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Soil Health Detector',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF8D6E63),
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
                colors: [Color(0xFF8D6E63), Color(0xFFA1887F)],
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
                _buildMethodSelectionStep(),
                _buildImageCaptureStep(),
                _buildBasicInfoStep(),
                _buildSoilConditionsStep(),
                _buildResultsStep(),
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
                          side: const BorderSide(color: Color(0xFF8D6E63)),
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
                        backgroundColor: const Color(0xFF8D6E63),
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
      return _analyzeSoilHealth;
    }
    return _nextStep;
  }

  String _getNextButtonText() {
    if (_currentStep == _steps.length - 2) {
      return 'Analyze Soil Health';
    }
    return 'Next';
  }

  Widget _buildMethodSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How would you like to analyze your soil?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the method that works best for you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          _buildMethodCard(
            Icons.camera_alt,
            'Camera Analysis',
            'Take a photo of your soil for AI-powered analysis',
            '🔬 Advanced AI Detection',
            true,
            () {
              setState(() {
                // Skip image step if not using camera
              });
            },
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            Icons.edit,
            'Manual Input',
            'Provide soil details manually for analysis',
            '📝 Traditional Method',
            false,
            () {
              setState(() {
                _soilImage = null; // Clear any selected image
                _currentStep = 2; // Skip image step
              });
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(IconData icon, String title, String description,
      String tag, bool isRecommended, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isRecommended ? const Color(0xFF8D6E63) : Colors.grey.shade200,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D6E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF8D6E63),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A42),
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
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
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isRecommended
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isRecommended
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
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
            'Capture Soil Sample',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a clear photo of your soil for AI analysis',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Tips for good soil photo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Tips for Best Results',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('• Take photo in natural daylight'),
                const Text('• Clear the surface of debris and plants'),
                const Text('• Hold camera 1-2 feet above soil'),
                const Text('• Ensure soil surface is visible and focused'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_soilImage == null)
            // Image capture area
            GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6E63).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8D6E63).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Color(0xFF8D6E63),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tap to Capture Soil Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A42),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Camera or Gallery',
                      style: TextStyle(
                        fontSize: 14,
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
                    _soilImage!,
                    height: 300,
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
                          foregroundColor: const Color(0xFF8D6E63),
                          side: const BorderSide(color: Color(0xFF8D6E63)),
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
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Soil Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your soil and farming practices',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Location
          const Text(
            'Farm Location',
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
                  const Icon(Icons.location_on, color: Color(0xFF8D6E63)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Soil Color
          const Text(
            'Soil Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'dark_brown',
              'brown',
              'light_brown',
              'red',
              'black',
              'gray'
            ].map((color) {
              final isSelected = _soilColor == color;
              return GestureDetector(
                onTap: () => setState(() => _soilColor = color),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF8D6E63) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8D6E63)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    color.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Soil Texture
          const Text(
            'Soil Texture (Feel)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: ['clay', 'sandy', 'loamy', 'silt'].map((texture) {
              final isSelected = _soilTexture == texture;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _soilTexture = texture),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8D6E63).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8D6E63)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getTextureIcon(texture),
                          color: isSelected
                              ? const Color(0xFF8D6E63)
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                texture.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF8D6E63)
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                _getTextureDescription(texture),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF8D6E63)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // pH Level
          const Text(
            'Soil pH Level (if known)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
                    const Icon(Icons.science, color: Color(0xFF8D6E63)),
                    const SizedBox(width: 8),
                    Text(
                      'pH: ${_ph.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getPhDescription(_ph),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getPhColor(_ph),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _ph,
                  min: 4.0,
                  max: 10.0,
                  divisions: 60,
                  activeColor: const Color(0xFF8D6E63),
                  onChanged: (value) => setState(() => _ph = value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('4.0 (Acidic)',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 10)),
                    Text('7.0 (Neutral)',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 10)),
                    Text('10.0 (Alkaline)',
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

  Widget _buildSoilConditionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soil Conditions & History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your soil\'s current state',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Drainage
          const Text(
            'How is the drainage in your field?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['excellent', 'good', 'poor'].map((drainage) {
              final isSelected = _drainage == drainage;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _drainage = drainage),
                  child: Container(
                    margin: EdgeInsets.only(right: drainage != 'poor' ? 8 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF8D6E63) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8D6E63)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getDrainageIcon(drainage),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF8D6E63),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          drainage.toUpperCase(),
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

          // Issues Checkboxes
          const Text(
            'Have you noticed any of these issues?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          CheckboxListTile(
            title: const Text('Waterlogging during rains'),
            subtitle:
                const Text('Water stands in field for more than 24 hours'),
            value: _hasWaterlogging,
            onChanged: (value) =>
                setState(() => _hasWaterlogging = value ?? false),
            activeColor: const Color(0xFF8D6E63),
          ),

          CheckboxListTile(
            title: const Text('White salt deposits'),
            subtitle: const Text('White crusty layer visible on soil surface'),
            value: _hasSaltDeposits,
            onChanged: (value) =>
                setState(() => _hasSaltDeposits = value ?? false),
            activeColor: const Color(0xFF8D6E63),
          ),

          const SizedBox(height: 20),

          // Crop History
          const Text(
            'What crops have you grown recently?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => _cropHistory = value,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g., Rice last season, wheat before that...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Fertilizers Used
          const Text(
            'Fertilizers used in last 6 months',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => _fertilizers = value,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g., NPK 10:26:26, Urea, DAP, organic compost...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsStep() {
    if (_analysisResult == null) {
      return const Center(
        child: Text('No analysis results available'),
      );
    }

    if (_analysisResult!.containsKey('error')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _analysisResult!['error'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                  _analysisResult = null;
                  _soilImage = null;
                });
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Start Over'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with health score
          _buildHealthScoreCard(),

          const SizedBox(height: 20),

          // Soil Analysis Summary
          _buildAnalysisSummary(),

          const SizedBox(height: 20),

          // Nutrient Analysis
          _buildNutrientAnalysis(),

          const SizedBox(height: 20),

          // Issues & Recommendations
          _buildRecommendations(),

          const SizedBox(height: 20),

          // Seasonal Care Guide
          if (_analysisResult!.containsKey('seasonal_care'))
            _buildSeasonalCare(),

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final healthScore = (_analysisResult!['health_score'] ?? 0).toDouble();
    final overallHealth = _analysisResult!['overall_health'] ?? 'unknown';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getHealthGradientColors(healthScore),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getHealthColor(healthScore).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.terrain,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Soil Health Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      overallHealth.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              '${healthScore.round()}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'out of 100',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSummary() {
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
              Icon(Icons.analytics, color: Color(0xFF8D6E63)),
              SizedBox(width: 8),
              Text(
                'Soil Analysis Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_analysisResult!.containsKey('soil_type'))
            _buildSummaryItem('Soil Type', _analysisResult!['soil_type']),
          if (_analysisResult!.containsKey('texture'))
            _buildSummaryItem('Texture', _analysisResult!['texture']),
          if (_analysisResult!.containsKey('ph_estimate'))
            _buildSummaryItem('pH Level',
                '${_analysisResult!['ph_estimate']} ${_getPhDescription(_analysisResult!['ph_estimate'])}'),
          if (_analysisResult!.containsKey('organic_matter'))
            _buildSummaryItem(
                'Organic Matter', _analysisResult!['organic_matter']),
          if (_analysisResult!.containsKey('moisture_level'))
            _buildSummaryItem(
                'Moisture Level', _analysisResult!['moisture_level']),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientAnalysis() {
    if (!_analysisResult!.containsKey('nutrient_analysis')) {
      return const SizedBox.shrink();
    }

    final nutrients =
        _analysisResult!['nutrient_analysis'] as Map<String, dynamic>;

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
              Icon(Icons.eco, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'Nutrient Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: nutrients.entries.map((entry) {
              return _buildNutrientCard(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(String nutrient, String level) {
    final color = _getNutrientColor(level);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nutrient.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            level.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    if (!_analysisResult!.containsKey('recommendations')) {
      return const SizedBox.shrink();
    }

    final recommendations =
        _analysisResult!['recommendations'] as Map<String, dynamic>;

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
              Icon(Icons.recommend, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recommendations.containsKey('immediate_actions'))
            _buildRecommendationSection(
              'Immediate Actions',
              recommendations['immediate_actions'],
              Icons.flash_on,
              const Color(0xFFFF9800),
            ),
          if (recommendations.containsKey('soil_amendments'))
            _buildRecommendationSection(
              'Soil Amendments',
              recommendations['soil_amendments'],
              Icons.grass,
              const Color(0xFF4CAF50),
            ),
          if (recommendations.containsKey('fertilizer_recommendations'))
            _buildTextRecommendation(
              'Fertilizer Recommendations',
              recommendations['fertilizer_recommendations'],
              Icons.scatter_plot,
              const Color(0xFF8BC34A),
            ),
          if (recommendations.containsKey('crop_suitability'))
            _buildRecommendationSection(
              'Suitable Crops',
              recommendations['crop_suitability'],
              Icons.eco,
              const Color(0xFF66BB6A),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(
      String title, dynamic content, IconData icon, Color color) {
    List<String> items = [];
    if (content is List) {
      items = content.cast<String>();
    } else if (content is String) {
      items = [content];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextRecommendation(
      String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            content,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSeasonalCare() {
    final seasonalCare =
        _analysisResult!['seasonal_care'] as Map<String, dynamic>;

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
              Icon(Icons.calendar_today, color: Color(0xFF8D6E63)),
              SizedBox(width: 8),
              Text(
                'Seasonal Care Guide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...seasonalCare.entries
              .map(
                (entry) => _buildSeasonalCareItem(entry.key, entry.value),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSeasonalCareItem(String season, String advice) {
    final seasonIcons = {
      'pre_monsoon': Icons.wb_sunny,
      'monsoon': Icons.grain,
      'post_monsoon': Icons.water_drop,
      'winter': Icons.ac_unit,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            seasonIcons[season] ?? Icons.calendar_today,
            color: const Color(0xFF8D6E63),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
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
                    _analysisResult = null;
                    _soilImage = null;
                  });
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Analyze Again'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF8D6E63)),
                  foregroundColor: const Color(0xFF8D6E63),
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/crop-recommendation');
            },
            icon: const Icon(Icons.eco),
            label: const Text('Get Crop Recommendations'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6E63),
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
                      _pickSoilImage(ImageSource.camera);
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
                      _pickSoilImage(ImageSource.gallery);
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
          color: const Color(0xFF8D6E63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8D6E63).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63).withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF8D6E63),
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

  // Helper methods
  IconData _getTextureIcon(String texture) {
    switch (texture) {
      case 'clay':
        return Icons.layers;
      case 'sandy':
        return Icons.grain;
      case 'loamy':
        return Icons.eco;
      case 'silt':
        return Icons.water;
      default:
        return Icons.terrain;
    }
  }

  String _getTextureDescription(String texture) {
    switch (texture) {
      case 'clay':
        return 'Sticky when wet, hard when dry';
      case 'sandy':
        return 'Gritty feel, drains quickly';
      case 'loamy':
        return 'Smooth feel, good for crops';
      case 'silt':
        return 'Smooth and floury feel';
      default:
        return '';
    }
  }

  IconData _getDrainageIcon(String drainage) {
    switch (drainage) {
      case 'excellent':
        return Icons.water_drop_outlined;
      case 'good':
        return Icons.water_drop;
      case 'poor':
        return Icons.water;
      default:
        return Icons.help;
    }
  }

  String _getPhDescription(double ph) {
    if (ph < 6.0) return 'Acidic';
    if (ph > 8.0) return 'Alkaline';
    return 'Neutral';
  }

  Color _getPhColor(double ph) {
    if (ph < 6.0 || ph > 8.0) return Colors.orange;
    return const Color(0xFF4CAF50);
  }

  List<Color> _getHealthGradientColors(double score) {
    if (score >= 80) return [const Color(0xFF4CAF50), const Color(0xFF66BB6A)];
    if (score >= 60) return [const Color(0xFFFF9800), const Color(0xFFFFB74D)];
    return [const Color(0xFFFF5722), const Color(0xFFFF8A65)];
  }

  Color _getHealthColor(double score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFFF5722);
  }

  Color _getNutrientColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'low':
        return const Color(0xFFFF5722);
      default:
        return Colors.grey;
    }
  }
}
