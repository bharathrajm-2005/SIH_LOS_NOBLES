// lib/features/fertilizers/fertilizers_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/fertilizer_model.dart';
import '../../core/services/fertilizer_service.dart';

class FertilizersScreen extends StatefulWidget {
  const FertilizersScreen({super.key});

  @override
  State<FertilizersScreen> createState() => _FertilizersScreenState();
}

class _FertilizersScreenState extends State<FertilizersScreen>
    with TickerProviderStateMixin {
  final FertilizerService _fertilizerService = FertilizerService();
  final TextEditingController _searchController = TextEditingController();

  List<FertilizerModel> _fertilizers = [];
  List<FertilizerModel> _filteredFertilizers = [];
  String _selectedCategory = 'all';
  String _selectedPlatform = 'all';
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadAllFertilizers();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllFertilizers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fertilizers = await _fertilizerService.getAllFertilizers();
      setState(() {
        _fertilizers = fertilizers;
        _filteredFertilizers = fertilizers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _filterFertilizers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<FertilizerModel> fertilizers;

      if (_selectedCategory == 'all') {
        fertilizers = await _fertilizerService.getAllFertilizers();
      } else {
        fertilizers = await _fertilizerService
            .getFertilizersByCategory(_selectedCategory);
      }

      if (_selectedPlatform != 'all') {
        fertilizers =
            fertilizers.where((f) => f.platform == _selectedPlatform).toList();
      }

      setState(() {
        _fertilizers = fertilizers;
        _filteredFertilizers = fertilizers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchFertilizers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredFertilizers = _fertilizers;
      });
      return;
    }

    try {
      final searchResults = await _fertilizerService.searchFertilizers(query);
      setState(() {
        _filteredFertilizers = searchResults;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open product link');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening link: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFertilizerDetails(FertilizerModel fertilizer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFertilizerDetailsModal(fertilizer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Fertilizers Store',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF66BB6A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAllFertilizers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header and Search
            _buildHeaderSection(),

            // Filters
            _buildFiltersSection(),

            // Fertilizers List
            Expanded(
              child: _buildFertilizersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _searchFertilizers,
              decoration: InputDecoration(
                hintText: 'Search fertilizers, NPK, crops...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF66BB6A)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchFertilizers('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.grass, '${_fertilizers.length}', 'Products'),
              _buildStatItem(
                  Icons.eco,
                  '${_fertilizers.where((f) => f.isOrganic).length}',
                  'Organic'),
              _buildStatItem(Icons.store, '2', 'Platforms'),
              _buildStatItem(Icons.local_shipping, 'Free', 'Delivery'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ['all', ...FertilizerService.getCategories()].length,
              itemBuilder: (context, index) {
                final categories = [
                  'all',
                  ...FertilizerService.getCategories()
                ];
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _filterFertilizers();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF66BB6A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF66BB6A)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category == 'all'
                              ? Icons.grid_view
                              : FertilizerService.getCategoryIcon(category),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF66BB6A),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category == 'all'
                              ? 'All'
                              : FertilizerService.getCategoryDisplayName(
                                  category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF66BB6A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Platform Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlatformChip('all', 'All Platforms', Icons.store),
              _buildPlatformChip('amazon', 'Amazon', Icons.shopping_cart),
              _buildPlatformChip('flipkart', 'Flipkart', Icons.shopping_bag),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformChip(String platform, String label, IconData icon) {
    final isSelected = _selectedPlatform == platform;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlatform = platform;
        });
        _filterFertilizers();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF66BB6A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF66BB6A) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF66BB6A),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF66BB6A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizersList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF66BB6A)),
            SizedBox(height: 16),
            Text('Loading fertilizers...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load fertilizers',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAllFertilizers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredFertilizers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No fertilizers found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllFertilizers,
      color: const Color(0xFF66BB6A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredFertilizers.length,
        itemBuilder: (context, index) {
          final fertilizer = _filteredFertilizers[index];
          return _buildFertilizerCard(fertilizer);
        },
      ),
    );
  }

  Widget _buildFertilizerCard(FertilizerModel fertilizer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  fertilizer.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grass,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Fertilizer Image',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Platform Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPlatformColor(fertilizer.platform),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPlatformIcon(fertilizer.platform),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fertilizer.platform.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Organic Badge
              if (fertilizer.isOrganic)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'ORGANIC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // NPK Badge
              if (fertilizer.npkRatio.isNotEmpty)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(fertilizer.category),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NPK ${fertilizer.npkRatio}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Fertilizer Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Brand
                Text(
                  fertilizer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A42),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (fertilizer.brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'by ${fertilizer.brand}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Nutrients
                if (fertilizer.nutrients.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fertilizer.nutrients,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Suitable Crops
                if (fertilizer.suitableCrops.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.agriculture,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Crops: ${fertilizer.suitableCrops}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Rating and Reviews
                if (fertilizer.rating > 0)
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < fertilizer.rating.floor()
                                ? Icons.star
                                : index < fertilizer.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${fertilizer.rating} (${fertilizer.reviewCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Price and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹${fertilizer.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF66BB6A),
                              ),
                            ),
                            if (fertilizer.packSize.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                '/ ${fertilizer.packSize}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (fertilizer.deliveryInfo.isNotEmpty)
                          Text(
                            fertilizer.deliveryInfo,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showFertilizerDetails(fertilizer),
                          icon: const Icon(Icons.info_outline),
                          color: const Color(0xFF66BB6A),
                        ),
                        ElevatedButton(
                          onPressed: fertilizer.isAvailable
                              ? () => _launchUrl(fertilizer.productUrl)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66BB6A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Buy Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerDetailsModal(FertilizerModel fertilizer) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fertilizer Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          fertilizer.imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.grass, size: 64),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title and Brand
                      Text(
                        fertilizer.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A42),
                        ),
                      ),

                      if (fertilizer.brand.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Brand: ${fertilizer.brand}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Price and Platform
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '₹${fertilizer.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF66BB6A),
                                    ),
                                  ),
                                  if (fertilizer.packSize.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '/ ${fertilizer.packSize}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (fertilizer.deliveryInfo.isNotEmpty)
                                Text(
                                  fertilizer.deliveryInfo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getPlatformColor(fertilizer.platform),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getPlatformIcon(fertilizer.platform),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fertilizer.platform.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A42),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fertilizer.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),

                      // NPK Information
                      if (fertilizer.npkRatio.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'NPK Ratio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A42),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            fertilizer.npkRatio,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      // Usage Information
                      if (fertilizer.nutrients.isNotEmpty ||
                          fertilizer.suitableCrops.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Usage Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A42),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (fertilizer.nutrients.isNotEmpty)
                          _buildInfoRow(
                              Icons.grain, 'Nutrients', fertilizer.nutrients),
                        if (fertilizer.suitableCrops.isNotEmpty)
                          _buildInfoRow(Icons.agriculture, 'Suitable Crops',
                              fertilizer.suitableCrops),
                        if (fertilizer.dosage.isNotEmpty)
                          _buildInfoRow(
                              Icons.scale, 'Dosage', fertilizer.dosage),
                        if (fertilizer.applicationMethod.isNotEmpty)
                          _buildInfoRow(Icons.water_drop, 'Application',
                              fertilizer.applicationMethod),
                      ],

                      // Benefits
                      if (fertilizer.benefits.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Key Benefits',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A42),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...fertilizer.benefits
                            .map(
                              (benefit) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        benefit,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],

                      // Specifications
                      if (fertilizer.specifications.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Specifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A42),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: fertilizer.specifications.entries
                                .map(
                                  (spec) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          spec.key,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          spec.value.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side:
                                    const BorderSide(color: Color(0xFF66BB6A)),
                                foregroundColor: const Color(0xFF66BB6A),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: fertilizer.isAvailable
                                  ? () {
                                      Navigator.pop(context);
                                      _launchUrl(fertilizer.productUrl);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF66BB6A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(fertilizer.isAvailable
                                  ? 'Buy Now'
                                  : 'Out of Stock'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF66BB6A)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'amazon':
        return const Color(0xFFFF9900);
      case 'flipkart':
        return const Color(0xFF2874F0);
      default:
        return const Color(0xFF66BB6A);
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'amazon':
        return Icons.shopping_cart;
      case 'flipkart':
        return Icons.shopping_bag;
      default:
        return Icons.store;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chemical':
        return const Color(0xFF2196F3);
      case 'organic':
        return const Color(0xFF4CAF50);
      case 'micronutrient':
        return const Color(0xFFFF9800);
      case 'liquid':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF66BB6A);
    }
  }
}
