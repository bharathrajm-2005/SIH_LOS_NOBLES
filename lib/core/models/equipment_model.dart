// lib/core/models/equipment_model.dart
class EquipmentModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String category;
  final String brand;
  final String seller;
  final String productUrl;
  final String platform; // amazon, flipkart, etc.
  final bool isAvailable;
  final String deliveryInfo;
  final List<String> features;
  final Map<String, dynamic> specifications;

  EquipmentModel({
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
    this.seller = '',
    required this.productUrl,
    required this.platform,
    this.isAvailable = true,
    this.deliveryInfo = '',
    this.features = const [],
    this.specifications = const {},
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
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
      seller: json['seller'] ?? '',
      productUrl: json['productUrl'] ?? '',
      platform: json['platform'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      deliveryInfo: json['deliveryInfo'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
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
      'seller': seller,
      'productUrl': productUrl,
      'platform': platform,
      'isAvailable': isAvailable,
      'deliveryInfo': deliveryInfo,
      'features': features,
      'specifications': specifications,
    };
  }
}
