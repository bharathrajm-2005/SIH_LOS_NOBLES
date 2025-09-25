class GovernmentSchemeModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> eligibility;
  final List<String> benefits;
  final List<String> documents;
  final List<String> applicationProcess;
  final String officialWebsite;
  final DateTime lastUpdated;
  final List<String> tags;
  final String state;
  final bool isActive;
  final String? contactNumber;
  final String? email;

  const GovernmentSchemeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.eligibility,
    required this.benefits,
    required this.documents,
    required this.applicationProcess,
    required this.officialWebsite,
    required this.lastUpdated,
    required this.tags,
    required this.state,
    required this.isActive,
    this.contactNumber,
    this.email,
  });

  /// Create from JSON
  factory GovernmentSchemeModel.fromJson(Map<String, dynamic> json) {
    return GovernmentSchemeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      eligibility: List<String>.from(json['eligibility'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      documents: List<String>.from(json['documents'] ?? []),
      applicationProcess: List<String>.from(json['applicationProcess'] ?? []),
      officialWebsite: json['officialWebsite'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      tags: List<String>.from(json['tags'] ?? []),
      state: json['state'] as String,
      isActive: json['isActive'] as bool? ?? true,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
    );
  }

  /// Create from MyScheme API response
  factory GovernmentSchemeModel.fromMySchemeApi(Map<String, dynamic> json) {
    return GovernmentSchemeModel(
      id: json['schemeId'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['schemeName'] as String? ?? 'Unknown Scheme',
      description:
          json['schemeDescription'] as String? ?? 'No description available',
      category: json['category'] as String? ?? 'General',
      eligibility: _parseStringList(json['eligibility']),
      benefits: _parseStringList(json['benefits']),
      documents: _parseStringList(json['documentsRequired']),
      applicationProcess: _parseStringList(json['applicationProcess']),
      officialWebsite:
          json['officialUrl'] as String? ?? 'https://myscheme.gov.in',
      lastUpdated: DateTime.now(),
      tags: _parseStringList(json['tags']),
      state: json['state'] as String? ?? 'All States',
      isActive: json['isActive'] as bool? ?? true,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'eligibility': eligibility,
      'benefits': benefits,
      'documents': documents,
      'applicationProcess': applicationProcess,
      'officialWebsite': officialWebsite,
      'lastUpdated': lastUpdated.toIso8601String(),
      'tags': tags,
      'state': state,
      'isActive': isActive,
      'contactNumber': contactNumber,
      'email': email,
    };
  }

  /// Helper method to parse string lists from API
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String) return [value];
    return [];
  }

  /// Get formatted eligibility
  String get formattedEligibility => eligibility.join('\n• ');

  /// Get formatted benefits
  String get formattedBenefits => benefits.join('\n• ');

  /// Get formatted documents
  String get formattedDocuments => documents.join('\n• ');

  /// Get formatted application process
  String get formattedApplicationProcess {
    return applicationProcess.asMap().entries.map((entry) {
      return '${entry.key + 1}. ${entry.value}';
    }).join('\n');
  }

  /// Check if scheme is agriculture related
  bool get isAgricultureRelated {
    return category.toLowerCase().contains('agriculture') ||
        tags.any((tag) => ['farming', 'crop', 'agriculture', 'farmer']
            .contains(tag.toLowerCase()));
  }

  /// Get scheme priority (for sorting)
  int get priority {
    if (tags.contains('pm kisan') || tags.contains('pmfby')) return 1;
    if (tags.contains('kisan card') || tags.contains('soil health')) return 2;
    return 3;
  }

  @override
  String toString() {
    return 'GovernmentSchemeModel(id: $id, title: $title, category: $category)';
  }
}
