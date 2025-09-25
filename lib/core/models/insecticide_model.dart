// lib/core/models/insecticide_model.dart
class InsecticideModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String category; // contact, systemic, biological, etc.
  final String brand;
  final String activeIngredient;
  final String targetInsects;
  final String suitableCrops;
  final String modeOfAction;
  final String dosage;
  final String applicationMethod;
  final String seller;
  final String productUrl;
  final String platform;
  final bool isAvailable;
  final String deliveryInfo;
  final List<String> safetyPrecautions;
  final Map<String, dynamic> specifications;
  final String packSize;
  final bool isOrganic;
  final String phi; // Pre-harvest interval

  InsecticideModel({
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
    this.targetInsects = '',
    this.suitableCrops = '',
    this.modeOfAction = '',
    this.dosage = '',
    this.applicationMethod = '',
    this.seller = '',
    required this.productUrl,
    required this.platform,
    this.isAvailable = true,
    this.deliveryInfo = '',
    this.safetyPrecautions = const [],
    this.specifications = const {},
    this.packSize = '',
    this.isOrganic = false,
    this.phi = '',
  });

  factory InsecticideModel.fromJson(Map<String, dynamic> json) {
    return InsecticideModel(
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
      targetInsects: json['targetInsects'] ?? '',
      suitableCrops: json['suitableCrops'] ?? '',
      modeOfAction: json['modeOfAction'] ?? '',
      dosage: json['dosage'] ?? '',
      applicationMethod: json['applicationMethod'] ?? '',
      seller: json['seller'] ?? '',
      productUrl: json['productUrl'] ?? '',
      platform: json['platform'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      deliveryInfo: json['deliveryInfo'] ?? '',
      safetyPrecautions: List<String>.from(json['safetyPrecautions'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      packSize: json['packSize'] ?? '',
      isOrganic: json['isOrganic'] ?? false,
      phi: json['phi'] ?? '',
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
      'targetInsects': targetInsects,
      'suitableCrops': suitableCrops,
      'modeOfAction': modeOfAction,
      'dosage': dosage,
      'applicationMethod': applicationMethod,
      'seller': seller,
      'productUrl': productUrl,
      'platform': platform,
      'isAvailable': isAvailable,
      'deliveryInfo': deliveryInfo,
      'safetyPrecautions': safetyPrecautions,
      'specifications': specifications,
      'packSize': packSize,
      'isOrganic': isOrganic,
      'phi': phi,
    };
  }
}
