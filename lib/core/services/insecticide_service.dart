// lib/core/services/insecticide_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/insecticide_model.dart';

class InsecticideService {
  static const String _baseUrl = 'https://your-api-endpoint.com/api';

  // Demo insecticide data (replace with actual API calls)
  static final List<Map<String, dynamic>> _demoInsecticides = [
    {
      'id': '1',
      'name': 'Bayer Confidor Super - Imidacloprid',
      'description':
          'Broad spectrum systemic insecticide for effective control of sucking pests. Long-lasting protection against aphids, jassids, and whiteflies.',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS4Q_T3iPRulltf7iAWggGdxPbV8eXR6sOAJQ&s',
      'price': 485.0,
      'rating': 4.3,
      'reviewCount': 287,
      'category': 'systemic',
      'brand': 'Bayer',
      'activeIngredient': 'Imidacloprid 17.8% SL',
      'targetInsects': 'Aphids, Jassids, Whitefly, Thrips, Brown Plant Hopper',
      'suitableCrops': 'Cotton, Rice, Wheat, Vegetables, Fruits',
      'modeOfAction': 'Systemic and Contact',
      'dosage': '0.3-0.5 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Bayer CropScience India',
      'productUrl': 'https://amazon.in/bayer-confidor-insecticide',
      'platform': 'amazon',
      'deliveryInfo': 'Free delivery in 2-3 days',
      'safetyPrecautions': [
        'Wear protective clothing and gloves',
        'Do not spray during flowering period',
        'Keep away from children and pets',
        'Avoid contamination of water sources',
        'Do not eat, drink or smoke during application'
      ],
      'specifications': {
        'Pack Size': '100ml',
        'Formulation': 'Soluble Liquid',
        'Toxicity': 'Moderately Toxic',
        'Application Rate': '0.5-1 L per acre'
      },
      'packSize': '100ml',
      'isOrganic': false,
      'phi': '7-14 days'
    },
    {
      'id': '2',
      'name': 'Chlorpyriphos 50% + Cypermethrin 5% EC',
      'description':
          'Combination insecticide providing dual action against a wide range of chewing and sucking insects. Effective control with residual action.',
      'imageUrl':
          'https://agriplexindia.com/cdn/shop/files/Hamla.png?v=1743241460',
      'price': 320.0,
      'rating': 4.1,
      'reviewCount': 198,
      'category': 'contact',
      'brand': 'Dhanuka',
      'activeIngredient': 'Chlorpyriphos 50% + Cypermethrin 5% EC',
      'targetInsects': 'Bollworm, Stem Borer, Leaf Folder, Aphids, Termites',
      'suitableCrops': 'Cotton, Rice, Sugarcane, Vegetables, Pulses',
      'modeOfAction': 'Contact and Stomach Poison',
      'dosage': '2-2.5 ml per liter of water',
      'applicationMethod': 'Foliar spray or soil application',
      'seller': 'Dhanuka Agritech Ltd',
      'productUrl': 'https://flipkart.com/chlorpyriphos-cypermethrin',
      'platform': 'flipkart',
      'deliveryInfo': 'Standard delivery in 3-5 days',
      'safetyPrecautions': [
        'Highly toxic - use extreme caution',
        'Use complete protective equipment',
        'Do not apply during bee activity hours',
        'Maintain buffer zone from water bodies',
        'Wash thoroughly after handling'
      ],
      'specifications': {
        'Pack Size': '250ml',
        'Formulation': 'Emulsifiable Concentrate',
        'Toxicity': 'Highly Toxic',
        'Application Rate': '1-1.25 L per acre'
      },
      'packSize': '250ml',
      'isOrganic': false,
      'phi': '15-21 days'
    },
    {
      'id': '3',
      'name': 'Neem Oil Based Bio-Insecticide',
      'description':
          'Natural broad spectrum bio-insecticide extracted from neem seeds. Safe for beneficial insects and environmentally friendly pest control.',
      'imageUrl':
          'https://5.imimg.com/data5/SELLER/Default/2022/5/WT/GQ/TY/67673073/organic-neem-oil-for-plants-organic-pesticide-for-plants-plants-insects-pesticides-250-ml.jpg',
      'price': 280.0,
      'rating': 4.4,
      'reviewCount': 356,
      'category': 'biological',
      'brand': 'Neemazal',
      'activeIngredient': 'Azadirachtin 1500 ppm',
      'targetInsects': 'Aphids, Caterpillars, Leaf Miners, Mites, Whitefly',
      'suitableCrops': 'All crops including fruits and vegetables',
      'modeOfAction': 'Antifeedant, Growth Regulator, Repellent',
      'dosage': '2-3 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Organic Solutions India',
      'productUrl': 'https://amazon.in/neem-oil-bio-insecticide',
      'platform': 'amazon',
      'deliveryInfo': 'Free delivery in 2-4 days',
      'safetyPrecautions': [
        'Safe for beneficial insects when used as directed',
        'May cause mild skin irritation in sensitive individuals',
        'Store away from direct sunlight',
        'Safe for organic farming certification',
        'Non-toxic to birds and mammals'
      ],
      'specifications': {
        'Pack Size': '250ml',
        'Formulation': 'Emulsifiable Concentrate',
        'Toxicity': 'Practically Non-toxic',
        'Application Rate': '500-750 ml per acre'
      },
      'packSize': '250ml',
      'isOrganic': true,
      'phi': '1 day'
    },
    {
      'id': '4',
      'name': 'Tata Rallis Tafgor - Dimethoate',
      'description':
          'Systemic insecticide with contact action. Highly effective against bollworm, fruit borer and other lepidopterous pests.',
      'imageUrl':
          'https://dujjhct8zer0r.cloudfront.net/media/prod_image/thumb/thumb222255_3240923431754047886.webp',
      'price': 890.0,
      'rating': 4.0,
      'reviewCount': 145,
      'category': 'systemic',
      'brand': 'Tata Rallis',
      'activeIngredient': 'Dimethoate 30% EC',
      'targetInsects': 'Bollworm, Fruit Borer, Stem Borer, Leaf Hopper, Aphids',
      'suitableCrops': 'Cotton, Rice, Fruits, Vegetables, Oilseeds',
      'modeOfAction': 'Systemic and Contact',
      'dosage': '1.5-2 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Tata Rallis India Ltd',
      'productUrl': 'https://flipkart.com/tata-rallis-tafgor',
      'platform': 'flipkart',
      'deliveryInfo': 'Express delivery in 2-4 days',
      'safetyPrecautions': [
        'Highly toxic to humans and animals',
        'Use complete protective gear including respirator',
        'Do not apply during flowering period',
        'Maintain strict buffer zones',
        'Store in locked, secure location'
      ],
      'specifications': {
        'Pack Size': '500ml',
        'Formulation': 'Emulsifiable Concentrate',
        'Toxicity': 'Highly Toxic',
        'Application Rate': '1-1.25 L per acre'
      },
      'packSize': '500ml',
      'isOrganic': false,
      'phi': '14-21 days'
    },
    {
      'id': '5',
      'name': 'Lambda Cyhalothrin 5% EC',
      'description':
          'Fast-acting pyrethroid insecticide for immediate knockdown of insects. Effective against wide range of pests with long residual activity.',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRcz_Eg_OwroeAC20kvHV4aKaM25ob44Qzd4Q&s',
      'price': 650.0,
      'rating': 4.2,
      'reviewCount': 234,
      'category': 'contact',
      'brand': 'Gharda Chemicals',
      'activeIngredient': 'Lambda Cyhalothrin 5% EC',
      'targetInsects': 'Bollworm, Pod Borer, Fruit Borer, Aphids, Jassids',
      'suitableCrops': 'Cotton, Chilli, Tomato, Cabbage, Okra',
      'modeOfAction': 'Contact and Stomach Action',
      'dosage': '0.5-1 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Gharda Chemicals Ltd',
      'productUrl': 'https://amazon.in/lambda-cyhalothrin-insecticide',
      'platform': 'amazon',
      'deliveryInfo': 'Same day delivery available',
      'safetyPrecautions': [
        'Moderately toxic - handle with care',
        'Use protective clothing and masks',
        'Avoid spray drift to non-target areas',
        'Do not contaminate water sources',
        'Keep away from food and feed'
      ],
      'specifications': {
        'Pack Size': '100ml',
        'Formulation': 'Emulsifiable Concentrate',
        'Toxicity': 'Moderately Toxic',
        'Application Rate': '0.25-0.5 L per acre'
      },
      'packSize': '100ml',
      'isOrganic': false,
      'phi': '7-10 days'
    },
    {
      'id': '6',
      'name': 'Bt (Bacillus thuringiensis) Bio-Insecticide',
      'description':
          'Biological insecticide containing beneficial bacteria. Specifically targets caterpillars while being safe for beneficial insects.',
      'imageUrl': 'https://m.media-amazon.com/images/I/41b90Whzd0L.jpg',
      'price': 380.0,
      'rating': 4.5,
      'reviewCount': 167,
      'category': 'biological',
      'brand': 'Biostadt',
      'activeIngredient': 'Bacillus thuringiensis var. kurstaki',
      'targetInsects':
          'Bollworm, Fruit Borer, Diamondback Moth, Cabbage Looper',
      'suitableCrops': 'Cotton, Vegetables, Fruits, Pulses',
      'modeOfAction': 'Stomach Poison (Bacterial Toxin)',
      'dosage': '1-2 grams per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Biostadt India Ltd',
      'productUrl': 'https://flipkart.com/bt-bio-insecticide',
      'platform': 'flipkart',
      'deliveryInfo': 'Cold chain delivery in 3-5 days',
      'safetyPrecautions': [
        'Safe for humans, animals, and environment',
        'Store in cool, dry place below 25°C',
        'Use within expiry date for best results',
        'Compatible with organic farming',
        'Safe for beneficial insects and pollinators'
      ],
      'specifications': {
        'Pack Size': '500gm',
        'Formulation': 'Wettable Powder',
        'Toxicity': 'Practically Non-toxic',
        'Application Rate': '1-2 kg per acre'
      },
      'packSize': '500gm',
      'isOrganic': true,
      'phi': '0 days'
    },
    {
      'id': '7',
      'name': 'Coragen - Chlorantraniliprole',
      'description':
          'Advanced insecticide with novel mode of action. Provides excellent control of lepidopterous pests with long-lasting protection.',
      'imageUrl':
          'https://agroshopy.com/image/cache/catalog/coragen-500x500.jpg',
      'price': 1250.0,
      'rating': 4.6,
      'reviewCount': 89,
      'category': 'systemic',
      'brand': 'DuPont',
      'activeIngredient': 'Chlorantraniliprole 18.5% SC',
      'targetInsects': 'Bollworm, Fruit Borer, Stem Borer, Diamondback Moth',
      'suitableCrops': 'Cotton, Rice, Vegetables, Fruits, Sugarcane',
      'modeOfAction': 'Systemic Translaminar',
      'dosage': '0.4 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'DuPont India Pvt Ltd',
      'productUrl': 'https://amazon.in/dupont-coragen-insecticide',
      'platform': 'amazon',
      'deliveryInfo': 'Express delivery in 1-2 days',
      'safetyPrecautions': [
        'Use as per label instructions only',
        'Avoid contact with skin and eyes',
        'Use protective equipment during application',
        'Do not contaminate water sources',
        'Follow resistance management guidelines'
      ],
      'specifications': {
        'Pack Size': '100ml',
        'Formulation': 'Suspension Concentrate',
        'Toxicity': 'Slightly Toxic',
        'Application Rate': '200-250 ml per acre'
      },
      'packSize': '100ml',
      'isOrganic': false,
      'phi': '3-7 days'
    },
    {
      'id': '8',
      'name': 'Malathion 50% EC Classic Insecticide',
      'description':
          'Broad spectrum organophosphate insecticide. Effective against various sucking and chewing insects with good residual activity.',
      'imageUrl':
          'https://cdn.shopify.com/s/files/1/0722/2059/files/malathion-50-e-c-insecticide-file-2532.jpg?v=17374266660',
      'price': 420.0,
      'rating': 3.9,
      'reviewCount': 278,
      'category': 'contact',
      'brand': 'UPL',
      'activeIngredient': 'Malathion 50% EC',
      'targetInsects': 'Aphids, Thrips, Mites, Fruit Flies, Scale Insects',
      'suitableCrops': 'Fruits, Vegetables, Cotton, Rice, Wheat',
      'modeOfAction': 'Contact and Fumigant Action',
      'dosage': '2-3 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'UPL Limited',
      'productUrl': 'https://flipkart.com/malathion-insecticide-upl',
      'platform': 'flipkart',
      'deliveryInfo': 'Standard delivery in 4-6 days',
      'safetyPrecautions': [
        'Toxic by inhalation and skin contact',
        'Use complete protective equipment',
        'Avoid application during hot weather',
        'Do not apply near beehives',
        'Ensure proper ventilation during application'
      ],
      'specifications': {
        'Pack Size': '500ml',
        'Formulation': 'Emulsifiable Concentrate',
        'Toxicity': 'Moderately Toxic',
        'Application Rate': '1-1.5 L per acre'
      },
      'packSize': '500ml',
      'isOrganic': false,
      'phi': '7-14 days'
    }
  ];

  Future<List<InsecticideModel>> getInsecticidesByCategory(
      String category) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final filteredInsecticides = _demoInsecticides
          .where((insecticide) => insecticide['category'] == category)
          .map((insecticide) => InsecticideModel.fromJson(insecticide))
          .toList();

      return filteredInsecticides;
    } catch (e) {
      throw Exception('Failed to fetch insecticides: $e');
    }
  }

  Future<List<InsecticideModel>> getAllInsecticides() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return _demoInsecticides
          .map((insecticide) => InsecticideModel.fromJson(insecticide))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch insecticides: $e');
    }
  }

  Future<List<InsecticideModel>> searchInsecticides(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final searchResults = _demoInsecticides
          .where((insecticide) =>
              insecticide['name'].toLowerCase().contains(query.toLowerCase()) ||
              insecticide['description']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              insecticide['brand']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              insecticide['targetInsects']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              insecticide['suitableCrops']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              insecticide['activeIngredient']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .map((insecticide) => InsecticideModel.fromJson(insecticide))
          .toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search insecticides: $e');
    }
  }

  Future<List<InsecticideModel>> getInsecticidesByPlatform(
      String platform) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final platformInsecticides = _demoInsecticides
          .where((insecticide) => insecticide['platform'] == platform)
          .map((insecticide) => InsecticideModel.fromJson(insecticide))
          .toList();

      return platformInsecticides;
    } catch (e) {
      throw Exception('Failed to fetch insecticides by platform: $e');
    }
  }

  static List<String> getCategories() {
    return [
      'systemic',
      'contact',
      'biological',
    ];
  }

  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'systemic':
        return 'Systemic Insecticides';
      case 'contact':
        return 'Contact Insecticides';
      case 'biological':
        return 'Bio-Insecticides';
      default:
        return category;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'systemic':
        return Icons.timeline;
      case 'contact':
        return Icons.touch_app;
      case 'biological':
        return Icons.eco;
      default:
        return Icons.bug_report;
    }
  }

  static List<String> getPlatforms() {
    return ['amazon', 'flipkart'];
  }
}
