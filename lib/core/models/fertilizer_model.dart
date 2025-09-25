// lib/core/models/fertilizer_model.dart
class FertilizerModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String category; // organic, chemical, micronutrient, etc.
  final String brand;
  final String npkRatio;
  final String nutrients;
  final String suitableCrops;
  final String applicationMethod;
  final String dosage;
  final String seller;
  final String productUrl;
  final String platform;
  final bool isAvailable;
  final String deliveryInfo;
  final List<String> benefits;
  final Map<String, dynamic> specifications;
  final String packSize;
  final bool isOrganic;
  final String soilType;

  FertilizerModel({
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
    this.npkRatio = '',
    this.nutrients = '',
    this.suitableCrops = '',
    this.applicationMethod = '',
    this.dosage = '',
    this.seller = '',
    required this.productUrl,
    required this.platform,
    this.isAvailable = true,
    this.deliveryInfo = '',
    this.benefits = const [],
    this.specifications = const {},
    this.packSize = '',
    this.isOrganic = false,
    this.soilType = '',
  });

  factory FertilizerModel.fromJson(Map<String, dynamic> json) {
    return FertilizerModel(
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
      npkRatio: json['npkRatio'] ?? '',
      nutrients: json['nutrients'] ?? '',
      suitableCrops: json['suitableCrops'] ?? '',
      applicationMethod: json['applicationMethod'] ?? '',
      dosage: json['dosage'] ?? '',
      seller: json['seller'] ?? '',
      productUrl: json['productUrl'] ?? '',
      platform: json['platform'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      deliveryInfo: json['deliveryInfo'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      packSize: json['packSize'] ?? '',
      isOrganic: json['isOrganic'] ?? false,
      soilType: json['soilType'] ?? '',
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
      'npkRatio': npkRatio,
      'nutrients': nutrients,
      'suitableCrops': suitableCrops,
      'applicationMethod': applicationMethod,
      'dosage': dosage,
      'seller': seller,
      'productUrl': productUrl,
      'platform': platform,
      'isAvailable': isAvailable,
      'deliveryInfo': deliveryInfo,
      'benefits': benefits,
      'specifications': specifications,
      'packSize': packSize,
      'isOrganic': isOrganic,
      'soilType': soilType,
    };
  }
}
