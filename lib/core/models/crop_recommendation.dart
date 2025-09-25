class CropRecommendation {
  final String cropName;
  final String cropType;
  final String season;
  final double suitabilityScore;
  final List<String> soilTypes;
  final Map<String, double> climateRequirements;
  final List<String> advantages;
  final List<String> challenges;
  final int growthPeriod; // days
  final double expectedYield; // tons per hectare
  final Map<String, String> fertilizerRequirements;
  final List<String> pestManagement;
  final double marketPrice; // per kg
  final String imageUrl;

  const CropRecommendation({
    required this.cropName,
    required this.cropType,
    required this.season,
    required this.suitabilityScore,
    required this.soilTypes,
    required this.climateRequirements,
    required this.advantages,
    required this.challenges,
    required this.growthPeriod,
    required this.expectedYield,
    required this.fertilizerRequirements,
    required this.pestManagement,
    required this.marketPrice,
    required this.imageUrl,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropName: json['cropName'] as String? ?? '',
      cropType: json['cropType'] as String? ?? '',
      season: json['season'] as String? ?? '',
      suitabilityScore: (json['suitabilityScore'] as num?)?.toDouble() ?? 0.0,
      soilTypes: List<String>.from(json['soilTypes'] ?? []),
      climateRequirements: Map<String, double>.from(
        (json['climateRequirements'] ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      advantages: List<String>.from(json['advantages'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
      growthPeriod: json['growthPeriod'] as int? ?? 0,
      expectedYield: (json['expectedYield'] as num?)?.toDouble() ?? 0.0,
      fertilizerRequirements: Map<String, String>.from(
        json['fertilizerRequirements'] ?? {},
      ),
      pestManagement: List<String>.from(json['pestManagement'] ?? []),
      marketPrice: (json['marketPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'cropType': cropType,
      'season': season,
      'suitabilityScore': suitabilityScore,
      'soilTypes': soilTypes,
      'climateRequirements': climateRequirements,
      'advantages': advantages,
      'challenges': challenges,
      'growthPeriod': growthPeriod,
      'expectedYield': expectedYield,
      'fertilizerRequirements': fertilizerRequirements,
      'pestManagement': pestManagement,
      'marketPrice': marketPrice,
      'imageUrl': imageUrl,
    };
  }

  String get suitabilityText {
    if (suitabilityScore >= 0.8) return 'Highly Suitable';
    if (suitabilityScore >= 0.6) return 'Suitable';
    if (suitabilityScore >= 0.4) return 'Moderately Suitable';
    return 'Not Suitable';
  }

  String get profitabilityEstimate {
    final profit = expectedYield * marketPrice;
    if (profit > 100000) return 'High Profitability';
    if (profit > 50000) return 'Moderate Profitability';
    return 'Low Profitability';
  }
}
