// lib/core/services/fertilizer_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/fertilizer_model.dart';

class FertilizerService {
  static const String _baseUrl = 'https://your-api-endpoint.com/api';

  // Demo fertilizer data (replace with actual API calls)
  static final List<Map<String, dynamic>> _demoFertilizers = [
    {
      'id': '1',
      'name': 'NPK 19:19:19 Water Soluble Fertilizer',
      'description':
          'Balanced water-soluble fertilizer for all crops. Provides equal nutrients for healthy plant growth.',
      'imageUrl':
          'https://agribegri.com/productimage/20300656101732183372.webp',
      'price': 280.0,
      'rating': 4.3,
      'reviewCount': 245,
      'category': 'chemical',
      'brand': 'Iffco',
      'npkRatio': '19:19:19',
      'nutrients': 'Nitrogen, Phosphorus, Potassium',
      'suitableCrops': 'All crops, Vegetables, Fruits, Cereals',
      'applicationMethod': 'Foliar spray or soil application',
      'dosage': '2-3 grams per liter of water',
      'seller': 'Iffco Official Store',
      'productUrl': 'https://amazon.in/npk-19-19-19-fertilizer',
      'platform': 'amazon',
      'deliveryInfo': 'Free delivery in 2-4 days',
      'benefits': [
        'Balanced nutrition for all growth stages',
        'Quick absorption and results',
        'Improves flowering and fruiting',
        'Enhances overall plant health'
      ],
      'specifications': {
        'Pack Size': '1 kg',
        'Solubility': '100% Water Soluble',
        'Form': 'Crystalline Powder',
        'Application Rate': '2-5 kg per acre'
      },
      'packSize': '1kg',
      'isOrganic': false,
      'soilType': 'All soil types'
    },
    {
      'id': '2',
      'name': 'Vermicompost Organic Fertilizer',
      'description':
          'Premium quality vermicompost rich in organic matter. 100% natural and eco-friendly fertilizer.',
      'imageUrl':
          'https://www.mudfingers.com/cdn/shop/products/01_c02c3219-5661-42ba-ae29-c29cf6be715a_525x700.jpg?v=1622011919',
      'price': 180.0,
      'rating': 4.5,
      'reviewCount': 389,
      'category': 'organic',
      'brand': 'OrganicKart',
      'npkRatio': '1.5:1.0:1.2',
      'nutrients': 'NPK, Organic Matter, Micronutrients',
      'suitableCrops': 'All crops, Vegetables, Fruits, Flowers',
      'applicationMethod': 'Soil mixing or top dressing',
      'dosage': '500-1000 grams per plant',
      'seller': 'Organic Solutions India',
      'productUrl': 'https://flipkart.com/vermicompost-organic-fertilizer',
      'platform': 'flipkart',
      'deliveryInfo': 'Standard delivery in 3-5 days',
      'benefits': [
        'Improves soil structure and fertility',
        'Enhances water retention capacity',
        'Provides slow-release nutrients',
        'Promotes beneficial soil microorganisms'
      ],
      'specifications': {
        'Pack Size': '5 kg',
        'Organic Content': '25-35%',
        'Moisture': '35-45%',
        'pH': '6.5-7.5'
      },
      'packSize': '5kg',
      'isOrganic': true,
      'soilType': 'All soil types'
    },
    {
      'id': '3',
      'name': 'DAP (Diammonium Phosphate) Fertilizer',
      'description':
          'High phosphorus fertilizer ideal for root development and flowering. Essential for crop establishment.',
      'imageUrl':
          'https://5.imimg.com/data5/SELLER/Default/2024/11/469046972/BQ/KY/YS/76947463/diammonium-phosphate-fertilizer.jpg',
      'price': 1250.0,
      'rating': 4.1,
      'reviewCount': 156,
      'category': 'chemical',
      'brand': 'IFFCO',
      'npkRatio': '18:46:0',
      'nutrients': 'Nitrogen (18%), Phosphorus (46%)',
      'suitableCrops': 'Rice, Wheat, Cotton, Sugarcane, Vegetables',
      'applicationMethod': 'Basal application before sowing',
      'dosage': '50-100 kg per acre',
      'seller': 'IFFCO Authorized Dealer',
      'productUrl': 'https://amazon.in/dap-fertilizer-iffco',
      'platform': 'amazon',
      'deliveryInfo': 'Free delivery in 5-7 days',
      'benefits': [
        'Promotes strong root development',
        'Enhances flowering and fruit setting',
        'Improves seed formation',
        'Boosts early plant growth'
      ],
      'specifications': {
        'Pack Size': '50 kg',
        'Nitrogen': '18%',
        'Phosphorus': '46%',
        'Form': 'Granules'
      },
      'packSize': '50kg',
      'isOrganic': false,
      'soilType': 'All soil types'
    },
    {
      'id': '4',
      'name': 'Urea Fertilizer - High Nitrogen',
      'description':
          'Pure urea fertilizer with 46% nitrogen content. Best for vegetative growth and green foliage.',
      'imageUrl': 'https://m.media-amazon.com/images/I/81elt76R8YL.jpg',
      'price': 1100.0,
      'rating': 4.0,
      'reviewCount': 298,
      'category': 'chemical',
      'brand': 'NFL',
      'npkRatio': '46:0:0',
      'nutrients': 'Nitrogen (46%)',
      'suitableCrops': 'Rice, Wheat, Maize, Sugarcane, Vegetables',
      'applicationMethod': 'Top dressing or basal application',
      'dosage': '25-50 kg per acre',
      'seller': 'NFL Official Store',
      'productUrl': 'https://flipkart.com/urea-fertilizer-nfl',
      'platform': 'flipkart',
      'deliveryInfo': 'Express delivery in 2-3 days',
      'benefits': [
        'Promotes lush green growth',
        'Increases leaf area and photosynthesis',
        'Improves protein content in grains',
        'Cost-effective nitrogen source'
      ],
      'specifications': {
        'Pack Size': '45 kg',
        'Nitrogen': '46%',
        'Purity': '99.5%',
        'Form': 'Prilled Granules'
      },
      'packSize': '45kg',
      'isOrganic': false,
      'soilType': 'All soil types'
    },
    {
      'id': '5',
      'name': 'Liquid Seaweed Extract Fertilizer',
      'description':
          'Natural liquid fertilizer made from seaweed. Rich in micronutrients and plant growth hormones.',
      'imageUrl':
          'https://cdn.shopify.com/s/files/1/0722/2059/files/katyayani-seaweed-extract-liquid-for-plants-vegetables-flowers-fruits-promotes-plant-growth-flowering-fruiting-keeps-plant-healthy-and-greenish-100-organic-file-7842.jpg?v=1737438954',
      'price': 450.0,
      'rating': 4.4,
      'reviewCount': 127,
      'category': 'organic',
      'brand': 'SeaGrow',
      'npkRatio': '2:1:3',
      'nutrients': 'NPK, Micronutrients, Growth Hormones',
      'suitableCrops': 'Fruits, Vegetables, Flowers, Ornamentals',
      'applicationMethod': 'Foliar spray or fertigation',
      'dosage': '2-3 ml per liter of water',
      'seller': 'Natural Fertilizers Co.',
      'productUrl': 'https://amazon.in/liquid-seaweed-fertilizer',
      'platform': 'amazon',
      'deliveryInfo': 'Next day delivery available',
      'benefits': [
        'Enhances plant immunity and stress tolerance',
        'Improves fruit quality and shelf life',
        'Promotes root development',
        'Increases crop yield naturally'
      ],
      'specifications': {
        'Pack Size': '500 ml',
        'Concentration': '1:500 dilution',
        'pH': '4.5-5.5',
        'Shelf Life': '2 years'
      },
      'packSize': '500ml',
      'isOrganic': true,
      'soilType': 'All soil types'
    },
    {
      'id': '6',
      'name': 'Potash (MOP) Muriate of Potash',
      'description':
          'High potassium fertilizer for improving fruit quality and plant disease resistance.',
      'imageUrl':
          'https://images-cdn.ubuy.co.in/649fa1939aa2e87efc03d1b3-muriate-of-potash-0-0-60-fertilizer-made.jpg',
      'price': 1350.0,
      'rating': 4.2,
      'reviewCount': 198,
      'category': 'chemical',
      'brand': 'ICL',
      'npkRatio': '0:0:60',
      'nutrients': 'Potassium (60%)',
      'suitableCrops': 'Fruits, Vegetables, Cotton, Sugarcane',
      'applicationMethod': 'Soil application before planting',
      'dosage': '30-60 kg per acre',
      'seller': 'ICL India Ltd',
      'productUrl': 'https://flipkart.com/potash-mop-fertilizer',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 4-6 days',
      'benefits': [
        'Improves fruit size and quality',
        'Enhances disease resistance',
        'Increases water use efficiency',
        'Strengthens plant stems'
      ],
      'specifications': {
        'Pack Size': '50 kg',
        'Potassium': '60%',
        'Chlorine': '47%',
        'Form': 'Crystalline'
      },
      'packSize': '50kg',
      'isOrganic': false,
      'soilType': 'All soil types except saline'
    },
    {
      'id': '7',
      'name': 'Micronutrient Mixture - Chelated',
      'description':
          'Complete micronutrient fertilizer containing zinc, iron, manganese, and other essential elements.',
      'imageUrl':
          'https://5.imimg.com/data5/ANDROID/Default/2022/5/GI/PK/YV/5610246/product-jpeg-500x500.jpg',
      'price': 380.0,
      'rating': 4.6,
      'reviewCount': 89,
      'category': 'micronutrient',
      'brand': 'Zuari',
      'npkRatio': '0:0:0',
      'nutrients': 'Zn, Fe, Mn, Cu, B, Mo',
      'suitableCrops': 'All crops showing micronutrient deficiency',
      'applicationMethod': 'Foliar spray or soil application',
      'dosage': '1-2 grams per liter of water',
      'seller': 'Zuari Agro Chemicals',
      'productUrl': 'https://amazon.in/micronutrient-mixture-chelated',
      'platform': 'amazon',
      'deliveryInfo': 'Standard delivery in 3-4 days',
      'benefits': [
        'Corrects micronutrient deficiencies',
        'Improves chlorophyll formation',
        'Enhances enzyme activity',
        'Increases crop productivity'
      ],
      'specifications': {
        'Pack Size': '1 kg',
        'Zinc': '12%',
        'Iron': '6%',
        'Manganese': '3%',
        'Form': 'Chelated Powder'
      },
      'packSize': '1kg',
      'isOrganic': false,
      'soilType': 'Alkaline and calcareous soils'
    },
    {
      'id': '8',
      'name': 'Bone Meal Organic Fertilizer',
      'description':
          'Natural phosphorus-rich fertilizer made from ground bones. Slow-release organic nutrition.',
      'imageUrl':
          'https://gogarden.co.in/cdn/shop/files/2_445cdee7-8ff1-48a5-94ab-894433d5f9f0.jpg?v=1741857991',
      'price': 220.0,
      'rating': 4.3,
      'reviewCount': 167,
      'category': 'organic',
      'brand': 'EcoGrow',
      'npkRatio': '4:12:0',
      'nutrients': 'Phosphorus, Calcium, Nitrogen',
      'suitableCrops': 'Flowering plants, Fruits, Root vegetables',
      'applicationMethod': 'Soil mixing at planting time',
      'dosage': '100-200 grams per plant',
      'seller': 'Organic Garden Store',
      'productUrl': 'https://flipkart.com/bone-meal-organic-fertilizer',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 2-4 days',
      'benefits': [
        'Promotes strong root development',
        'Long-lasting nutrient release',
        'Improves soil structure',
        'Enhances flowering and fruiting'
      ],
      'specifications': {
        'Pack Size': '2 kg',
        'Phosphorus': '12%',
        'Calcium': '24%',
        'Organic Matter': '85%'
      },
      'packSize': '2kg',
      'isOrganic': true,
      'soilType': 'Acidic to neutral soils'
    }
  ];

  Future<List<FertilizerModel>> getFertilizersByCategory(
      String category) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final filteredFertilizers = _demoFertilizers
          .where((fertilizer) => fertilizer['category'] == category)
          .map((fertilizer) => FertilizerModel.fromJson(fertilizer))
          .toList();

      return filteredFertilizers;
    } catch (e) {
      throw Exception('Failed to fetch fertilizers: $e');
    }
  }

  Future<List<FertilizerModel>> getAllFertilizers() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return _demoFertilizers
          .map((fertilizer) => FertilizerModel.fromJson(fertilizer))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch fertilizers: $e');
    }
  }

  Future<List<FertilizerModel>> searchFertilizers(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final searchResults = _demoFertilizers
          .where((fertilizer) =>
              fertilizer['name'].toLowerCase().contains(query.toLowerCase()) ||
              fertilizer['description']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              fertilizer['brand'].toLowerCase().contains(query.toLowerCase()) ||
              fertilizer['nutrients']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              fertilizer['suitableCrops']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .map((fertilizer) => FertilizerModel.fromJson(fertilizer))
          .toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search fertilizers: $e');
    }
  }

  Future<List<FertilizerModel>> getFertilizersByPlatform(
      String platform) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final platformFertilizers = _demoFertilizers
          .where((fertilizer) => fertilizer['platform'] == platform)
          .map((fertilizer) => FertilizerModel.fromJson(fertilizer))
          .toList();

      return platformFertilizers;
    } catch (e) {
      throw Exception('Failed to fetch fertilizers by platform: $e');
    }
  }

  static List<String> getCategories() {
    return [
      'chemical',
      'organic',
      'micronutrient',
      'liquid',
    ];
  }

  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'chemical':
        return 'Chemical Fertilizers';
      case 'organic':
        return 'Organic Fertilizers';
      case 'micronutrient':
        return 'Micronutrients';
      case 'liquid':
        return 'Liquid Fertilizers';
      default:
        return category;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'chemical':
        return Icons.science;
      case 'organic':
        return Icons.eco;
      case 'micronutrient':
        return Icons.grain;
      case 'liquid':
        return Icons.water_drop;
      default:
        return Icons.grass;
    }
  }

  static List<String> getPlatforms() {
    return ['amazon', 'flipkart'];
  }
}
