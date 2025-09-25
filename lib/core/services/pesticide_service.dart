// lib/core/services/pesticide_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pesticide_model.dart';

class PesticideService {
  static const String _baseUrl = 'https://your-api-endpoint.com/api';

  // Demo pesticide data (replace with actual API calls)
  static final List<Map<String, dynamic>> _demoPesticides = [
    {
      'id': '1',
      'name': 'Bayer Confidor',
      'description':
          'Broad spectrum systemic insecticide for sucking pests control. Effective against aphids, jassids, and whiteflies.',
      'imageUrl':
          'https://5.imimg.com/data5/SELLER/Default/2021/1/QE/RQ/VC/5111461/bayer-confidor-super-500-ml-insecticide.jpg',
      'price': 485.0,
      'rating': 4.2,
      'reviewCount': 187,
      'category': 'insecticide',
      'brand': 'Bayer',
      'activeIngredient': 'Imidacloprid 17.8% SL',
      'targetPests': 'Aphids, Jassids, Whitefly, Thrips',
      'suitableCrops': 'Cotton, Vegetables, Fruits, Cereals',
      'dosage': '0.3-0.5 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Bayer CropScience',
      'productUrl': 'https://amazon.in/bayer-confidor-insecticide',
      'platform': 'amazon',
      'deliveryInfo': 'Free delivery in 2-3 days',
      'safetyWarnings': [
        'Wear protective clothing during application',
        'Do not spray during flowering period',
        'Keep away from children and pets',
        'Do not contaminate water bodies'
      ],
      'specifications': {
        'Pack Size': '100ml',
        'Formulation': 'Systemic Liquid',
        'PHI': '7-14 days',
        'Mode of Action': 'Contact and Systemic'
      },
      'packSize': '100ml',
      'isOrganic': false
    },
    {
      'id': '2',
      'name': 'Dhanuka M-45 Fungicide',
      'description':
          'Contact fungicide for prevention and control of fungal diseases in various crops. Effective against blight and rust.',
      'imageUrl':
          'https://5.imimg.com/data5/VS/GZ/JO/GLADMIN-3061/dhanuka-m-45-fungicide.png',
      'price': 320.0,
      'rating': 4.4,
      'reviewCount': 156,
      'category': 'fungicide',
      'brand': 'Dhanuka',
      'activeIngredient': 'Mancozeb 75% WP',
      'targetPests': 'Late Blight, Early Blight, Downy Mildew, Rust',
      'suitableCrops': 'Potato, Tomato, Grapes, Wheat, Rice',
      'dosage': '2-2.5 grams per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Dhanuka Agritech',
      'productUrl': 'https://flipkart.com/dhanuka-m45-fungicide',
      'platform': 'flipkart',
      'deliveryInfo': 'Standard delivery in 3-5 days',
      'safetyWarnings': [
        'Use protective mask and gloves',
        'Avoid contact with skin and eyes',
        'Do not eat, drink or smoke during application',
        'Store in cool, dry place'
      ],
      'specifications': {
        'Pack Size': '250gm',
        'Formulation': 'Wettable Powder',
        'PHI': '15 days',
        'Mode of Action': 'Contact'
      },
      'packSize': '250gm',
      'isOrganic': false
    },
    {
      'id': '3',
      'name': 'Roundup Herbicide - Glyphosate',
      'description':
          'Non-selective systemic herbicide for control of annual and perennial weeds. Fast and effective weed killer.',
      'imageUrl':
          'https://cdn.dotpe.in/longtail/store-items/6792607/q3ZepXRR.webp',
      'price': 750.0,
      'rating': 4.0,
      'reviewCount': 298,
      'category': 'herbicide',
      'brand': 'Monsanto',
      'activeIngredient': 'Glyphosate 41% SL',
      'targetPests': 'Broad spectrum weeds, Grasses',
      'suitableCrops': 'Non-crop areas, Pre-emergence in crops',
      'dosage': '2-3 ml per liter of water',
      'applicationMethod': 'Directed spray',
      'seller': 'Monsanto India',
      'productUrl': 'https://amazon.in/roundup-glyphosate-herbicide',
      'platform': 'amazon',
      'deliveryInfo': 'Express delivery in 1-2 days',
      'safetyWarnings': [
        'Highly toxic - handle with extreme care',
        'Use full protective equipment',
        'Avoid drift to desirable plants',
        'Do not apply on windy days'
      ],
      'specifications': {
        'Pack Size': '500ml',
        'Formulation': 'Soluble Liquid',
        'PHI': 'Not applicable',
        'Mode of Action': 'Systemic'
      },
      'packSize': '500ml',
      'isOrganic': false
    },
    {
      'id': '4',
      'name': 'Neem Oil Organic Pesticide',
      'description':
          'Organic broad spectrum biopesticide extracted from neem seeds. Safe for beneficial insects and environment.',
      'imageUrl': 'https://m.media-amazon.com/images/I/71qSKV9deLL.jpg',
      'price': 280.0,
      'rating': 4.3,
      'reviewCount': 324,
      'category': 'organic',
      'brand': 'Neemazal',
      'activeIngredient': 'Azadirachtin 1500 ppm',
      'targetPests': 'Aphids, Caterpillars, Mites, Whitefly',
      'suitableCrops': 'All crops including fruits and vegetables',
      'dosage': '2-3 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Organic Solutions',
      'productUrl': 'https://flipkart.com/neem-oil-organic-pesticide',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 2-4 days',
      'safetyWarnings': [
        'Safe for beneficial insects when used as directed',
        'May cause skin irritation in sensitive individuals',
        'Store away from direct sunlight',
        'Safe for organic farming'
      ],
      'specifications': {
        'Pack Size': '250ml',
        'Formulation': 'Emulsifiable Concentrate',
        'PHI': '1 day',
        'Mode of Action': 'Contact and Antifeedant'
      },
      'packSize': '250ml',
      'isOrganic': true
    },
    {
      'id': '5',
      'name': 'Tata Rallis Tafgor Insecticide',
      'description':
          'Systemic insecticide with contact action. Effective against bollworm, fruit borer and other lepidopterous pests.',
      'imageUrl':
          'https://agribegri.com/productimage/12094601561747919006.webp',
      'price': 890.0,
      'rating': 4.1,
      'reviewCount': 145,
      'category': 'insecticide',
      'brand': 'Tata Rallis',
      'activeIngredient': 'Dimethoate 30% EC',
      'targetPests': 'Bollworm, Fruit Borer, Stem Borer, Leaf Hopper',
      'suitableCrops': 'Cotton, Rice, Fruits, Vegetables',
      'dosage': '1.5-2 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'Tata Rallis India',
      'productUrl': 'https://amazon.in/tata-rallis-tafgor',
      'platform': 'amazon',
      'deliveryInfo': 'Standard delivery in 3-6 days',
      'safetyWarnings': [
        'Highly toxic to humans and animals',
        'Use complete protective gear',
        'Do not apply during bee activity hours',
        'Maintain buffer zone near water bodies'
      ],
      'specifications': {
        'Pack Size': '500ml',
        'Formulation': 'Emulsifiable Concentrate',
        'PHI': '14-21 days',
        'Mode of Action': 'Systemic and Contact'
      },
      'packSize': '500ml',
      'isOrganic': false
    },
    {
      'id': '6',
      'name': 'UPL Saaf Fungicide',
      'description':
          'Combination fungicide for broad spectrum disease control. Contains two active ingredients for enhanced efficacy.',
      'imageUrl':
          'https://agriplexindia.com/cdn/shop/products/Saaf.png?v=1743242025',
      'price': 420.0,
      'rating': 4.5,
      'reviewCount': 201,
      'category': 'fungicide',
      'brand': 'UPL',
      'activeIngredient': 'Carbendazim 12% + Mancozeb 63% WP',
      'targetPests': 'Anthracnose, Leaf Spot, Powdery Mildew, Rust',
      'suitableCrops': 'Fruits, Vegetables, Cereals, Pulses',
      'dosage': '2 grams per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'UPL Limited',
      'productUrl': 'https://flipkart.com/upl-saaf-fungicide',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 2-3 days',
      'safetyWarnings': [
        'Wear protective clothing and mask',
        'Wash hands thoroughly after use',
        'Do not spray against wind direction',
        'Keep containers tightly sealed'
      ],
      'specifications': {
        'Pack Size': '500gm',
        'Formulation': 'Wettable Powder',
        'PHI': '10-15 days',
        'Mode of Action': 'Systemic + Contact'
      },
      'packSize': '500gm',
      'isOrganic': false
    },
    {
      'id': '7',
      'name': 'Biological Trichoderma Fungicide',
      'description':
          'Biological fungicide containing beneficial Trichoderma fungi. Eco-friendly and safe for soil health.',
      'imageUrl':
          'https://www.katyayaniorganics.com/wp-content/uploads/2022/06/Hattrick-liquid_11zon.webp',
      'price': 180.0,
      'rating': 4.2,
      'reviewCount': 89,
      'category': 'biological',
      'brand': 'BioControl',
      'activeIngredient': 'Trichoderma viride 1x10^8 CFU/gm',
      'targetPests': 'Soil-borne fungal diseases, Root rot, Damping off',
      'suitableCrops': 'All crops, Seedling treatment',
      'dosage': '5-10 grams per liter for seed treatment',
      'applicationMethod': 'Seed treatment, Soil application',
      'seller': 'Bio Pesticides India',
      'productUrl': 'https://amazon.in/trichoderma-biological-fungicide',
      'platform': 'amazon',
      'deliveryInfo': 'Cold chain delivery in 2-4 days',
      'safetyWarnings': [
        'Store in cool, dry place below 25°C',
        'Do not mix with chemical fungicides',
        'Use within expiry date for best results',
        'Safe for environment and beneficial insects'
      ],
      'specifications': {
        'Pack Size': '100gm',
        'Formulation': 'Wettable Powder',
        'PHI': '0 days',
        'Mode of Action': 'Biological Control'
      },
      'packSize': '100gm',
      'isOrganic': true
    },
    {
      'id': '8',
      'name': 'Coragen Insecticide - DuPont',
      'description':
          'Advanced insecticide with novel mode of action against lepidopterous pests. Long-lasting protection.',
      'imageUrl':
          'https://cdn.shopify.com/s/files/1/0722/2059/files/coragen-dupont-file-1135.jpg?v=1737429360',
      'price': 1250.0,
      'rating': 4.6,
      'reviewCount': 78,
      'category': 'insecticide',
      'brand': 'DuPont',
      'activeIngredient': 'Chlorantraniliprole 18.5% SC',
      'targetPests': 'Bollworm, Fruit Borer, Stem Borer, Diamondback Moth',
      'suitableCrops': 'Cotton, Rice, Vegetables, Fruits',
      'dosage': '0.4 ml per liter of water',
      'applicationMethod': 'Foliar spray',
      'seller': 'DuPont India',
      'productUrl': 'https://flipkart.com/dupont-coragen-insecticide',
      'platform': 'flipkart',
      'deliveryInfo': 'Express delivery in 1-3 days',
      'safetyWarnings': [
        'Use as per label instructions only',
        'Avoid contact with skin and eyes',
        'Do not contaminate water sources',
        'Use integrated pest management'
      ],
      'specifications': {
        'Pack Size': '100ml',
        'Formulation': 'Suspension Concentrate',
        'PHI': '3-7 days',
        'Mode of Action': 'Systemic'
      },
      'packSize': '100ml',
      'isOrganic': false
    }
  ];

  Future<List<PesticideModel>> getPesticidesByCategory(String category) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final filteredPesticides = _demoPesticides
          .where((pesticide) => pesticide['category'] == category)
          .map((pesticide) => PesticideModel.fromJson(pesticide))
          .toList();

      return filteredPesticides;
    } catch (e) {
      throw Exception('Failed to fetch pesticides: $e');
    }
  }

  Future<List<PesticideModel>> getAllPesticides() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return _demoPesticides
          .map((pesticide) => PesticideModel.fromJson(pesticide))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pesticides: $e');
    }
  }

  Future<List<PesticideModel>> searchPesticides(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final searchResults = _demoPesticides
          .where((pesticide) =>
              pesticide['name'].toLowerCase().contains(query.toLowerCase()) ||
              pesticide['description']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              pesticide['brand'].toLowerCase().contains(query.toLowerCase()) ||
              pesticide['targetPests']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              pesticide['suitableCrops']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .map((pesticide) => PesticideModel.fromJson(pesticide))
          .toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search pesticides: $e');
    }
  }

  Future<List<PesticideModel>> getPesticidesByPlatform(String platform) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final platformPesticides = _demoPesticides
          .where((pesticide) => pesticide['platform'] == platform)
          .map((pesticide) => PesticideModel.fromJson(pesticide))
          .toList();

      return platformPesticides;
    } catch (e) {
      throw Exception('Failed to fetch pesticides by platform: $e');
    }
  }

  static List<String> getCategories() {
    return [
      'organic',
      'biological',
    ];
  }

  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'organic':
        return 'Organic Pesticides';
      case 'biological':
        return 'Biological Control';
      default:
        return category;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'insecticide':
        return Icons.bug_report;
      case 'fungicide':
        return Icons.coronavirus;
      case 'herbicide':
        return Icons.grass;
      case 'organic':
        return Icons.eco;
      case 'biological':
        return Icons.science;
      default:
        return Icons.scatter_plot;
    }
  }

  static List<String> getPlatforms() {
    return ['amazon', 'flipkart'];
  }
}
