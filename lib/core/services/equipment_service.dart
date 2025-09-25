// lib/core/services/equipment_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/equipment_model.dart';

class EquipmentService {
  static const String _baseUrl = 'https://your-api-endpoint.com/api';

  // Static data for demo purposes (replace with actual API calls)
  static final List<Map<String, dynamic>> _demoEquipments = [
    {
      'id': '1',
      'name': 'Tractor - Mahindra 575 DI XP Plus',
      'description':
          '50HP tractor with 4WD, perfect for medium farms. Excellent fuel efficiency and powerful performance.',
      'imageUrl':
          'https://www.mahindratractor.com/sites/default/files/styles/homepage_pslider_472x390_/public/2023-08/275-DI-TU-XP-Plus.png.webp',
      'price': 675000.0,
      'rating': 4.3,
      'reviewCount': 156,
      'category': 'tractors',
      'brand': 'Mahindra',
      'seller': 'Mahindra Official Store',
      'productUrl': 'https://amazon.in/mahindra-tractor-575',
      'platform': 'amazon',
      'deliveryInfo': 'Free delivery in 7-10 days',
      'features': [
        '4WD Drive',
        'Power Steering',
        'Oil Bath Air Cleaner',
        '8F + 2R Gearbox'
      ],
      'specifications': {
        'Engine Power': '50 HP',
        'No. of Cylinders': '3',
        'Fuel Tank': '65 Liter',
        'Weight': '2100 kg'
      }
    },
    {
      'id': '2',
      'name': 'Power Tiller - Honda F220',
      'description':
          'Compact and efficient power tiller ideal for small to medium farms. Easy to operate and maintain.',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9-bWMwYwxAcvHY0mktB2-TfE3OCqB0Mz15g&s',
      'price': 89500.0,
      'rating': 4.5,
      'reviewCount': 89,
      'category': 'tillers',
      'brand': 'Honda',
      'seller': 'Honda Power Equipment',
      'productUrl': 'https://flipkart.com/honda-power-tiller',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 3-5 days',
      'features': [
        'Self Start',
        'Reverse Gear',
        'Adjustable Handle',
        'Multi-purpose'
      ],
      'specifications': {
        'Engine': '5.5 HP',
        'Fuel Tank': '3.1 Liter',
        'Tilling Width': '850mm',
        'Weight': '75 kg'
      }
    },
    {
      'id': '3',
      'name': 'Water Pump - Kirloskar KDS-135',
      'description':
          'High-performance centrifugal water pump suitable for irrigation. Durable and energy efficient.',
      'imageUrl':
          'https://www.kirloskarpumps.com/kirloskar-pumps/wp-content/uploads/2020/07/KDS-Single-Phase-min.jpg',
      'price': 15750.0,
      'rating': 4.2,
      'reviewCount': 234,
      'category': 'pumps',
      'brand': 'Kirloskar',
      'seller': 'Kirloskar Official',
      'productUrl': 'https://amazon.in/kirloskar-water-pump',
      'platform': 'amazon',
      'deliveryInfo': 'Next day delivery available',
      'features': [
        'Self Priming',
        'Corrosion Resistant',
        'Energy Efficient',
        'Low Maintenance'
      ],
      'specifications': {
        'Power': '1 HP',
        'Flow Rate': '135 LPM',
        'Head': '22 meters',
        'Inlet/Outlet': '1.25" x 1"'
      }
    },
    {
      'id': '4',
      'name': 'Spraying Machine - Neptune NS-16',
      'description':
          'Battery operated knapsack sprayer with adjustable nozzle. Perfect for pesticide application.',
      'imageUrl': 'https://m.media-amazon.com/images/I/41nG-oUJLUL.jpg',
      'price': 6850.0,
      'rating': 4.0,
      'reviewCount': 145,
      'category': 'sprayers',
      'brand': 'Neptune',
      'seller': 'AgriTools India',
      'productUrl': 'https://flipkart.com/neptune-sprayer',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 2-4 days',
      'features': [
        '16L Capacity',
        'Rechargeable Battery',
        'Adjustable Pressure',
        'Multiple Nozzles'
      ],
      'specifications': {
        'Tank Capacity': '16 Liters',
        'Battery': '12V 8Ah',
        'Pressure': '0.15-0.4 MPa',
        'Weight': '5.2 kg'
      }
    },
    {
      'id': '5',
      'name': 'Harvester - Mini Combine',
      'description':
          'Compact combine harvester suitable for wheat, rice and other cereals. High efficiency cutting.',
      'imageUrl':
          'https://images.jdmagicbox.com/quickquotes/images_main/mini-combine-harvester-382274157-ynnqw.jpg',
      'price': 285000.0,
      'rating': 4.1,
      'reviewCount': 67,
      'category': 'harvesters',
      'brand': 'Kartar',
      'seller': 'Farm Equipment Store',
      'productUrl': 'https://amazon.in/mini-combine-harvester',
      'platform': 'amazon',
      'deliveryInfo': 'Free installation in 10-15 days',
      'features': [
        'Self Propelled',
        'Grain Tank',
        'Straw Chopper',
        'Easy Operation'
      ],
      'specifications': {
        'Engine Power': '25 HP',
        'Cutting Width': '1.2 meters',
        'Grain Tank': '300 kg',
        'Fuel Tank': '35 Liter'
      }
    },
    {
      'id': '6',
      'name': 'Rotavator - Shaktiman 7 Feet',
      'description':
          'Heavy duty rotavator for soil preparation. Suitable for hard and rocky soils.',
      'imageUrl':
          'https://shaktimanagro.com/wp-content/uploads/2024/08/Shaktiman_Round_Standard_Image_4.png',
      'price': 78900.0,
      'rating': 4.4,
      'reviewCount': 198,
      'category': 'cultivators',
      'brand': 'Shaktiman',
      'seller': 'Shaktiman Implements',
      'productUrl': 'https://flipkart.com/shaktiman-rotavator',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 5-7 days',
      'features': [
        'Heavy Duty Blades',
        '7 Feet Working Width',
        'Adjustable Depth',
        'Durable Frame'
      ],
      'specifications': {
        'Working Width': '7 feet',
        'Tractor HP': '45-65 HP',
        'Blades': '30 Numbers',
        'Weight': '650 kg'
      }
    },
    {
      'id': '7',
      'name': 'Seed Drill - John Deere 1590',
      'description':
          'Precision seed drill for accurate seed placement. Ideal for wheat, barley and other small grains.',
      'imageUrl':
          'https://www.afgri.com.au/media/catalog/product/cache/baba1d06420f28d36e4ff7aaa1cb0d75/1/5/1590_no_till_drill_0086017_large_4295a65fead75d219b72a26bac0da92c409e8357_1.jpg',
      'price': 145000.0,
      'rating': 4.6,
      'reviewCount': 112,
      'category': 'planters',
      'brand': 'John Deere',
      'seller': 'John Deere India',
      'productUrl': 'https://amazon.in/john-deere-seed-drill',
      'platform': 'amazon',
      'deliveryInfo': 'Free delivery in 7-12 days',
      'features': [
        'Precision Metering',
        '15 Rows',
        'Depth Control',
        'Seed Rate Adjustment'
      ],
      'specifications': {
        'Working Width': '3.5 meters',
        'Rows': '15',
        'Seed Box': '180 kg',
        'Tractor HP': '55-75 HP'
      }
    },
    {
      'id': '8',
      'name': 'Thresher - Deluxe Paddy Thresher',
      'description':
          'Multi-crop thresher suitable for paddy, wheat and other grains. High cleaning efficiency.',
      'imageUrl':
          'https://mahindrafarmmachinery.com/sites/default/files/2023-12/Mahindra%20Paddy%20-%20Multi%20Thresher%20P-80%201.png',
      'price': 56700.0,
      'rating': 4.3,
      'reviewCount': 167,
      'category': 'threshers',
      'brand': 'Kisankraft',
      'seller': 'Kisankraft Official',
      'productUrl': 'https://flipkart.com/paddy-thresher',
      'platform': 'flipkart',
      'deliveryInfo': 'Free delivery in 4-6 days',
      'features': [
        'Multi Crop',
        'High Capacity',
        'Low Grain Damage',
        'Easy Cleaning'
      ],
      'specifications': {
        'Capacity': '1000-1200 kg/hr',
        'Motor': '15 HP',
        'Cleaning': '98%',
        'Weight': '450 kg'
      }
    }
  ];

  Future<List<EquipmentModel>> getEquipmentsByCategory(String category) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Filter equipment by category
      final filteredEquipments = _demoEquipments
          .where((equipment) => equipment['category'] == category)
          .map((equipment) => EquipmentModel.fromJson(equipment))
          .toList();

      return filteredEquipments;
    } catch (e) {
      throw Exception('Failed to fetch equipments: $e');
    }
  }

  Future<List<EquipmentModel>> getAllEquipments() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      return _demoEquipments
          .map((equipment) => EquipmentModel.fromJson(equipment))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch equipments: $e');
    }
  }

  Future<List<EquipmentModel>> searchEquipments(String query) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      final searchResults = _demoEquipments
          .where((equipment) =>
              equipment['name'].toLowerCase().contains(query.toLowerCase()) ||
              equipment['description']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              equipment['brand'].toLowerCase().contains(query.toLowerCase()))
          .map((equipment) => EquipmentModel.fromJson(equipment))
          .toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search equipments: $e');
    }
  }

  Future<EquipmentModel?> getEquipmentById(String id) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 300));

      final equipmentData = _demoEquipments.firstWhere(
        (equipment) => equipment['id'] == id,
        orElse: () => {},
      );

      if (equipmentData.isEmpty) return null;

      return EquipmentModel.fromJson(equipmentData);
    } catch (e) {
      throw Exception('Failed to fetch equipment: $e');
    }
  }

  static List<String> getCategories() {
    return [
      'tractors',
      'tillers',
      'pumps',
      'harvesters',
      'cultivators',
      'planters',
      'threshers',
    ];
  }

  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'tractors':
        return 'Tractors';
      case 'tillers':
        return 'Power Tillers';
      case 'pumps':
        return 'Water Pumps';
      case 'harvesters':
        return 'Harvesters';
      case 'cultivators':
        return 'Cultivators';
      case 'planters':
        return 'Planters';
      case 'threshers':
        return 'Threshers';
      default:
        return category;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'tractors':
        return Icons.agriculture;
      case 'tillers':
        return Icons.build;
      case 'pumps':
        return Icons.water_drop;
      case 'sprayers':
        return Icons.scatter_plot;
      case 'harvesters':
        return Icons.grass;
      case 'cultivators':
        return Icons.landscape;
      case 'planters':
        return Icons.eco;
      case 'threshers':
        return Icons.grain;
      default:
        return Icons.category;
    }
  }
}
