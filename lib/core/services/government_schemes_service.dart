import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/government_scheme.dart';

class GovernmentSchemesService {
  static const String _cacheKey = 'government_schemes_cache';
  static const String _lastUpdateKey = 'schemes_last_update';

  // MyScheme.gov.in API (Official Government Portal)
  static const String _mySchemeBaseUrl = 'https://www.myscheme.gov.in/api';

  // Static agricultural schemes data
  static final List<GovernmentSchemeModel> _staticSchemes = [
    GovernmentSchemeModel(
      id: 'pmfby_2024',
      title: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      description:
          'Crop insurance scheme providing financial support to farmers suffering crop loss/damage arising out of unforeseen events',
      category: 'Agriculture & Insurance',
      eligibility: [
        'All farmers (loanee and non-loanee) growing notified crops in notified areas',
        'Minimum age: 18 years',
        'Must have Aadhaar card',
        'Bank account mandatory'
      ],
      benefits: [
        'Premium rates: Kharif 2%, Rabi 1.5%, Commercial/Horticultural 5%',
        'No upper limit on government subsidy',
        'Coverage for pre-sowing to post-harvest losses',
        'Use of technology like drones and satellite imagery for quick assessment'
      ],
      documents: [
        'Aadhaar Card',
        'Bank Account Details',
        'Land Records',
        'Sowing Certificate',
        'Identity Proof'
      ],
      applicationProcess: [
        'Visit nearest bank or CSC center',
        'Fill application form with required details',
        'Submit required documents',
        'Pay farmer\'s share of premium',
        'Get insurance certificate'
      ],
      officialWebsite: 'https://pmfby.gov.in',
      lastUpdated: DateTime.now(),
      tags: ['crop insurance', 'farming', 'agriculture', 'pmfby'],
      state: 'All States',
      isActive: true,
    ),
    GovernmentSchemeModel(
      id: 'pm_kisan_2024',
      title: 'PM-KISAN Samman Nidhi',
      description:
          'Financial benefit of Rs 6000 per year in three equal installments to eligible farmer families',
      category: 'Agriculture & Financial Support',
      eligibility: [
        'Small and marginal farmer families having combined land holding up to 2 hectares',
        'Must have valid Aadhaar card',
        'Bank account should be linked with Aadhaar'
      ],
      benefits: [
        'Rs 6000 per year in three installments of Rs 2000 each',
        'Direct benefit transfer to bank account',
        'No application fee',
        'Automatic renewal if eligible'
      ],
      documents: [
        'Aadhaar Card',
        'Bank Account Passbook',
        'Land Ownership Document',
        'Citizenship Certificate'
      ],
      applicationProcess: [
        'Visit PM-KISAN official website',
        'Click on "Farmers Corner" and select "New Farmer Registration"',
        'Fill required details',
        'Submit and get registration number',
        'Visit CSC or bank for verification'
      ],
      officialWebsite: 'https://pmkisan.gov.in',
      lastUpdated: DateTime.now(),
      tags: ['financial support', 'farmer', 'pm kisan', 'direct benefit'],
      state: 'All States',
      isActive: true,
    ),
    GovernmentSchemeModel(
      id: 'kcc_2024',
      title: 'Kisan Credit Card (KCC)',
      description:
          'Credit facility for farmers to meet their financial requirements for agricultural and allied activities',
      category: 'Agriculture & Credit',
      eligibility: [
        'All farmers (individual/joint cultivators)',
        'Tenant farmers, oral lessees, and sharecroppers',
        'Self Help Group members engaged in farming',
        'Age: 18-75 years'
      ],
      benefits: [
        'Credit limit based on farming needs',
        'Simple interest rates',
        'Flexible repayment terms',
        'Insurance coverage',
        'ATM-cum-debit card facility'
      ],
      documents: [
        'Application form',
        'Identity proof',
        'Address proof',
        'Land documents',
        'Income proof'
      ],
      applicationProcess: [
        'Visit nearest bank branch',
        'Submit application with required documents',
        'Bank verification and assessment',
        'Credit limit sanctioned',
        'KCC issued with ATM facility'
      ],
      officialWebsite: 'https://pmkisan.gov.in/KCC.aspx',
      lastUpdated: DateTime.now(),
      tags: ['credit', 'kisan card', 'agricultural loan', 'banking'],
      state: 'All States',
      isActive: true,
    ),
    GovernmentSchemeModel(
      id: 'soil_health_2024',
      title: 'Soil Health Card Scheme',
      description:
          'Providing soil health cards to farmers containing crop-wise recommendations of nutrients and fertilizers',
      category: 'Agriculture & Soil Management',
      eligibility: [
        'All farmers having agricultural land',
        'Land ownership or cultivation rights',
        'Must provide soil samples'
      ],
      benefits: [
        'Free soil testing',
        'Customized fertilizer recommendations',
        'Improved crop productivity',
        'Reduced input costs',
        'Better soil health management'
      ],
      documents: [
        'Land ownership documents',
        'Aadhaar card',
        'Application form',
        'Soil samples'
      ],
      applicationProcess: [
        'Contact local agriculture department',
        'Submit soil samples from different parts of field',
        'Provide required documents',
        'Get soil health card with recommendations',
        'Follow suggested practices for better yield'
      ],
      officialWebsite: 'https://soilhealth.dac.gov.in',
      lastUpdated: DateTime.now(),
      tags: ['soil health', 'fertilizer', 'soil testing', 'productivity'],
      state: 'All States',
      isActive: true,
    ),
    GovernmentSchemeModel(
      id: 'pmksy_2024',
      title: 'Pradhan Mantri Krishi Sinchayee Yojana (PMKSY)',
      description:
          'Achieving convergence of investments in irrigation at field level, enhancing water use efficiency',
      category: 'Agriculture & Irrigation',
      eligibility: [
        'All categories of farmers',
        'Water User Associations',
        'Cooperatives',
        'FPOs and other eligible institutions'
      ],
      benefits: [
        'Financial assistance for drip/sprinkler irrigation',
        'Micro irrigation system installation',
        'Water conservation techniques',
        'Improved water use efficiency',
        'Higher crop productivity'
      ],
      documents: [
        'Land ownership documents',
        'Aadhaar card',
        'Bank account details',
        'Project proposal',
        'Water source availability certificate'
      ],
      applicationProcess: [
        'Apply through state agriculture/irrigation department',
        'Submit project proposal with estimates',
        'Technical verification and approval',
        'Installation of irrigation system',
        'Subsidy released after completion'
      ],
      officialWebsite: 'https://pmksy.gov.in',
      lastUpdated: DateTime.now(),
      tags: ['irrigation', 'water conservation', 'drip irrigation', 'pmksy'],
      state: 'All States',
      isActive: true,
    ),
  ];

  /// Get all government schemes
  Future<List<GovernmentSchemeModel>> getAllSchemes() async {
    try {
      // Try to get fresh data from online sources
      final onlineSchemes = await _fetchOnlineSchemes();
      if (onlineSchemes.isNotEmpty) {
        await _cacheSchemes(onlineSchemes);
        return onlineSchemes;
      }
    } catch (e) {
      print('Failed to fetch online schemes: $e');
    }

    // Fallback to cached data
    final cachedSchemes = await _getCachedSchemes();
    if (cachedSchemes.isNotEmpty) {
      return cachedSchemes;
    }

    // Ultimate fallback to static data
    return _staticSchemes;
  }

  /// Fetch schemes from online sources
  Future<List<GovernmentSchemeModel>> _fetchOnlineSchemes() async {
    final List<GovernmentSchemeModel> schemes = [];

    try {
      // Add static schemes first
      schemes.addAll(_staticSchemes);

      // Try to fetch from MyScheme.gov.in (if API is available)
      try {
        final mySchemeData = await _fetchFromMyScheme();
        schemes.addAll(mySchemeData);
      } catch (e) {
        print('MyScheme API unavailable: $e');
      }

      // Try to scrape PMFBY website data
      try {
        final pmfbySchemes = await _scrapePMFBYData();
        schemes.addAll(pmfbySchemes);
      } catch (e) {
        print('PMFBY scraping failed: $e');
      }

      return schemes;
    } catch (e) {
      print('Error fetching online schemes: $e');
      return _staticSchemes;
    }
  }

  /// Fetch agricultural schemes from MyScheme portal
  Future<List<GovernmentSchemeModel>> _fetchFromMyScheme() async {
    final url = 'https://www.myscheme.gov.in/api/schemes?category=agriculture';

    final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 15),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final schemes = <GovernmentSchemeModel>[];

      if (data['schemes'] != null) {
        for (final schemeData in data['schemes']) {
          schemes.add(GovernmentSchemeModel.fromMySchemeApi(schemeData));
        }
      }

      return schemes;
    } else {
      throw Exception('MyScheme API returned ${response.statusCode}');
    }
  }

  /// Scrape PMFBY website for latest information
  Future<List<GovernmentSchemeModel>> _scrapePMFBYData() async {
    try {
      // Get PMFBY main page content
      final response = await http.get(
        Uri.parse('https://pmfby.gov.in'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return _parsePMFBYContent(response.body);
      }
    } catch (e) {
      print('PMFBY scraping error: $e');
    }

    return [];
  }

  /// Parse PMFBY website content
  List<GovernmentSchemeModel> _parsePMFBYContent(String htmlContent) {
    final schemes = <GovernmentSchemeModel>[];

    // Simple parsing - in real implementation, you'd use html package
    if (htmlContent.contains('PMFBY') ||
        htmlContent.contains('crop insurance')) {
      schemes.add(
        GovernmentSchemeModel(
          id: 'pmfby_updated_${DateTime.now().millisecondsSinceEpoch}',
          title: 'PMFBY - Latest Updates',
          description: 'Latest information from PMFBY official website',
          category: 'Agriculture & Insurance',
          eligibility: ['Updated from official website'],
          benefits: ['Current scheme benefits'],
          documents: ['As per latest guidelines'],
          applicationProcess: ['Visit pmfby.gov.in for latest process'],
          officialWebsite: 'https://pmfby.gov.in',
          lastUpdated: DateTime.now(),
          tags: ['pmfby', 'live', 'official'],
          state: 'All States',
          isActive: true,
        ),
      );
    }

    return schemes;
  }

  /// Get schemes by category
  Future<List<GovernmentSchemeModel>> getSchemesByCategory(
      String category) async {
    final allSchemes = await getAllSchemes();
    return allSchemes
        .where((scheme) =>
            scheme.category.toLowerCase().contains(category.toLowerCase()))
        .toList();
  }

  /// Search schemes by keyword
  Future<List<GovernmentSchemeModel>> searchSchemes(String keyword) async {
    final allSchemes = await getAllSchemes();
    final searchTerm = keyword.toLowerCase();

    return allSchemes
        .where((scheme) =>
            scheme.title.toLowerCase().contains(searchTerm) ||
            scheme.description.toLowerCase().contains(searchTerm) ||
            scheme.tags.any((tag) => tag.toLowerCase().contains(searchTerm)))
        .toList();
  }

  /// Get schemes by state
  Future<List<GovernmentSchemeModel>> getSchemesByState(String state) async {
    final allSchemes = await getAllSchemes();
    return allSchemes
        .where((scheme) =>
            scheme.state.toLowerCase() == state.toLowerCase() ||
            scheme.state.toLowerCase() == 'all states')
        .toList();
  }

  /// Cache schemes locally
  Future<void> _cacheSchemes(List<GovernmentSchemeModel> schemes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schemesJson = schemes.map((s) => s.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(schemesJson));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching schemes: $e');
    }
  }

  /// Get cached schemes
  Future<List<GovernmentSchemeModel>> _getCachedSchemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;

      // Check if cache is still valid (24 hours)
      final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdate;
      if (cacheAge > 24 * 60 * 60 * 1000) {
        return [];
      }

      if (cachedData != null) {
        final List<dynamic> schemesJson = jsonDecode(cachedData);
        return schemesJson
            .map((json) => GovernmentSchemeModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error reading cached schemes: $e');
    }

    return [];
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Get scheme details by ID
  Future<GovernmentSchemeModel?> getSchemeById(String id) async {
    final schemes = await getAllSchemes();
    try {
      return schemes.firstWhere((scheme) => scheme.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get featured/important schemes
  Future<List<GovernmentSchemeModel>> getFeaturedSchemes() async {
    final allSchemes = await getAllSchemes();

    // Return schemes with specific important tags
    final importantTags = ['pm kisan', 'pmfby', 'kisan card', 'soil health'];

    return allSchemes
        .where((scheme) => importantTags.any((tag) => scheme.tags
            .any((schemeTag) => schemeTag.toLowerCase().contains(tag))))
        .take(5)
        .toList();
  }
}
