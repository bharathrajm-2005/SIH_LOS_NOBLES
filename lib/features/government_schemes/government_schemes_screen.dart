import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/app_colors.dart';
import '../../core/services/government_schemes_service.dart';
import '../../core/models/government_scheme.dart';
import '../../widgets/scheme_detail_screen.dart';

class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  State<GovernmentSchemesScreen> createState() =>
      _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GovernmentSchemeModel> _allSchemes = [];
  List<GovernmentSchemeModel> _filteredSchemes = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Agriculture & Insurance',
    'Agriculture & Financial Support',
    'Agriculture & Credit',
    'Agriculture & Soil Management',
    'Agriculture & Irrigation',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final schemesService =
          Provider.of<GovernmentSchemesService>(context, listen: false);
      final schemes = await schemesService.getAllSchemes();

      // Sort by priority and date
      schemes.sort((a, b) {
        final priorityComparison = a.priority.compareTo(b.priority);
        if (priorityComparison != 0) return priorityComparison;
        return b.lastUpdated.compareTo(a.lastUpdated);
      });

      setState(() {
        _allSchemes = schemes;
        _filteredSchemes = schemes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterSchemes() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredSchemes = _allSchemes.where((scheme) {
        final matchesSearch = query.isEmpty ||
            scheme.title.toLowerCase().contains(query) ||
            scheme.description.toLowerCase().contains(query) ||
            scheme.tags.any((tag) => tag.toLowerCase().contains(query));

        final matchesCategory =
            _selectedCategory == 'All' || scheme.category == _selectedCategory;

        return matchesSearch && matchesCategory && scheme.isActive;
      }).toList();
    });
  }

  void _openSchemeWebsite(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open website')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchemes,
          ),
          PopupMenuButton<String>(
            onSelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
              _filterSchemes();
            },
            itemBuilder: (context) => _categories
                .map(
                  (category) => PopupMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        if (category == _selectedCategory)
                          const Icon(Icons.check, size: 16),
                        if (category == _selectedCategory)
                          const SizedBox(width: 8),
                        Expanded(child: Text(category)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search schemes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterSchemes();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) => _filterSchemes(),
            ),
          ),

          // Category Filter Chip
          if (_selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedCategory),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                      _filterSchemes();
                    },
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _filteredSchemes.isEmpty
                        ? _buildEmptyWidget()
                        : _buildSchemesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Failed to load schemes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSchemes,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No schemes found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or category filter',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredSchemes.length,
      itemBuilder: (context, index) {
        final scheme = _filteredSchemes[index];
        return _buildSchemeCard(scheme);
      },
    );
  }

  Widget _buildSchemeCard(GovernmentSchemeModel scheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchemeDetailScreen(scheme: scheme),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Category
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scheme.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey.shade400),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                scheme.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: scheme.tags
                    .take(3)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 12),

              // Bottom Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        scheme.state,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _openSchemeWebsite(scheme.officialWebsite),
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text('Visit Website'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
