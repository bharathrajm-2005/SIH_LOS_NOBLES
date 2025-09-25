// lib/core/models/pesticide_model.dart
class PesticideModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String category; // insecticide, fungicide, herbicide, etc.
  final String brand;
  final String activeIngredient;
  final String targetPests;
  final String suitableCrops;
  final String dosage;
  final String applicationMethod;
  final String seller;
  final String productUrl;
  final String platform;
  final bool isAvailable;
  final String deliveryInfo;
  final List<String> safetyWarnings;
  final Map<String, dynamic> specifications;
  final String packSize;
  final bool isOrganic;

  PesticideModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.currency = 'INR',
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.category,
    this.brand = '',
    this.activeIngredient = '',
    this.targetPests = '',
    this.suitableCrops = '',
    this.dosage = '',
    this.applicationMethod = '',
    this.seller = '',
    required this.productUrl,
    required this.platform,
    this.isAvailable = true,
    this.deliveryInfo = '',
    this.safetyWarnings = const [],
    this.specifications = const {},
    this.packSize = '',
    this.isOrganic = false,
  });

  factory PesticideModel.fromJson(Map<String, dynamic> json) {
    return PesticideModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      activeIngredient: json['activeIngredient'] ?? '',
      targetPests: json['targetPests'] ?? '',
      suitableCrops: json['suitableCrops'] ?? '',
      dosage: json['dosage'] ?? '',
      applicationMethod: json['applicationMethod'] ?? '',
      seller: json['seller'] ?? '',
      productUrl: json['productUrl'] ?? '',
      platform: json['platform'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      deliveryInfo: json['deliveryInfo'] ?? '',
      safetyWarnings: List<String>.from(json['safetyWarnings'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      packSize: json['packSize'] ?? '',
      isOrganic: json['isOrganic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'currency': currency,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'brand': brand,
      'activeIngredient': activeIngredient,
      'targetPests': targetPests,
      'suitableCrops': suitableCrops,
      'dosage': dosage,
      'applicationMethod': applicationMethod,
      'seller': seller,
      'productUrl': productUrl,
      'platform': platform,
      'isAvailable': isAvailable,
      'deliveryInfo': deliveryInfo,
      'safetyWarnings': safetyWarnings,
      'specifications': specifications,
      'packSize': packSize,
      'isOrganic': isOrganic,
    };
  }
}
