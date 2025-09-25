// lib/features/insecticides/insecticides_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/insecticide_model.dart';
import '../../core/services/insecticide_service.dart';

class InsecticidesScreen extends StatefulWidget {
  const InsecticidesScreen({super.key});

  @override
  State<InsecticidesScreen> createState() => _InsecticidesScreenState();
}

class _InsecticidesScreenState extends State<InsecticidesScreen>
    with TickerProviderStateMixin {
  final InsecticideService _insecticideService = InsecticideService();
  final TextEditingController _searchController = TextEditingController();

  List<InsecticideModel> _insecticides = [];
  List<InsecticideModel> _filteredInsecticides = [];
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

    _loadAllInsecticides();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllInsecticides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final insecticides = await _insecticideService.getAllInsecticides();
      setState(() {
        _insecticides = insecticides;
        _filteredInsecticides = insecticides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _filterInsecticides() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<InsecticideModel> insecticides;

      if (_selectedCategory == 'all') {
        insecticides = await _insecticideService.getAllInsecticides();
      } else {
        insecticides = await _insecticideService
            .getInsecticidesByCategory(_selectedCategory);
      }

      if (_selectedPlatform != 'all') {
        insecticides =
            insecticides.where((i) => i.platform == _selectedPlatform).toList();
      }

      setState(() {
        _insecticides = insecticides;
        _filteredInsecticides = insecticides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchInsecticides(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredInsecticides = _insecticides;
      });
      return;
    }

    try {
      final searchResults = await _insecticideService.searchInsecticides(query);
      setState(() {
        _filteredInsecticides = searchResults;
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

  void _showInsecticideDetails(InsecticideModel insecticide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInsecticideDetailsModal(insecticide),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Insecticides Store',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF29B6F6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAllInsecticides,
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

            // Insecticides List
            Expanded(
              child: _buildInsecticidesList(),
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
          colors: [Color(0xFF29B6F6), Color(0xFF42A5F5)],
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
              onChanged: _searchInsecticides,
              decoration: InputDecoration(
                hintText: 'Search insecticides, pests, crops...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF29B6F6)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchInsecticides('');
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
              _buildStatItem(
                  Icons.bug_report, '${_insecticides.length}', 'Products'),
              _buildStatItem(
                  Icons.eco,
                  '${_insecticides.where((i) => i.isOrganic).length}',
                  'Organic'),
              _buildStatItem(Icons.store, '2', 'Platforms'),
              _buildStatItem(Icons.local_shipping, 'Fast', 'Delivery'),
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
              itemCount: ['all', ...InsecticideService.getCategories()].length,
              itemBuilder: (context, index) {
                final categories = [
                  'all',
                  ...InsecticideService.getCategories()
                ];
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _filterInsecticides();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF29B6F6) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF29B6F6)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category == 'all'
                              ? Icons.grid_view
                              : InsecticideService.getCategoryIcon(category),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF29B6F6),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category == 'all'
                              ? 'All'
                              : InsecticideService.getCategoryDisplayName(
                                  category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF29B6F6),
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
        _filterInsecticides();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF29B6F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF29B6F6) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF29B6F6),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF29B6F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsecticidesList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF29B6F6)),
            SizedBox(height: 16),
            Text('Loading insecticides...'),
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
              'Failed to load insecticides',
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
              onPressed: _loadAllInsecticides,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredInsecticides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No insecticides found',
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
      onRefresh: _loadAllInsecticides,
      color: const Color(0xFF29B6F6),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredInsecticides.length,
        itemBuilder: (context, index) {
          final insecticide = _filteredInsecticides[index];
          return _buildInsecticideCard(insecticide);
        },
      ),
    );
  }

  Widget _buildInsecticideCard(InsecticideModel insecticide) {
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
                  insecticide.imageUrl,
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
                          Icon(Icons.bug_report,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Insecticide Image',
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
                    color: _getPlatformColor(insecticide.platform),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPlatformIcon(insecticide.platform),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        insecticide.platform.toUpperCase(),
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
              if (insecticide.isOrganic)
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
                          'BIO',
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

              // Category Badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(insecticide.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    InsecticideService.getCategoryDisplayName(
                        insecticide.category),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Insecticide Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Brand
                Text(
                  insecticide.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A42),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (insecticide.brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'by ${insecticide.brand}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Active Ingredient
                if (insecticide.activeIngredient.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      insecticide.activeIngredient,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Target Insects
                if (insecticide.targetInsects.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bug_report,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Target: ${insecticide.targetInsects}',
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
                  const SizedBox(height: 4),
                ],

                // Suitable Crops
                if (insecticide.suitableCrops.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.agriculture,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Crops: ${insecticide.suitableCrops}',
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
                if (insecticide.rating > 0)
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < insecticide.rating.floor()
                                ? Icons.star
                                : index < insecticide.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${insecticide.rating} (${insecticide.reviewCount})',
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
                              '₹${insecticide.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF29B6F6),
                              ),
                            ),
                            if (insecticide.packSize.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                '/ ${insecticide.packSize}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (insecticide.deliveryInfo.isNotEmpty)
                          Text(
                            insecticide.deliveryInfo,
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
                          onPressed: () => _showInsecticideDetails(insecticide),
                          icon: const Icon(Icons.info_outline),
                          color: const Color(0xFF29B6F6),
                        ),
                        ElevatedButton(
                          onPressed: insecticide.isAvailable
                              ? () => _launchUrl(insecticide.productUrl)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF29B6F6),
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

  Widget _buildInsecticideDetailsModal(InsecticideModel insecticide) {
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
                      // Insecticide Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          insecticide.imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.bug_report, size: 64),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title and Brand
                      Text(
                        insecticide.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A42),
                        ),
                      ),

                      if (insecticide.brand.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Brand: ${insecticide.brand}',
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
                                    '₹${insecticide.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF29B6F6),
                                    ),
                                  ),
                                  if (insecticide.packSize.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '/ ${insecticide.packSize}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (insecticide.deliveryInfo.isNotEmpty)
                                Text(
                                  insecticide.deliveryInfo,
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
                              color: _getPlatformColor(insecticide.platform),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getPlatformIcon(insecticide.platform),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  insecticide.platform.toUpperCase(),
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
                        insecticide.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),

                      // Active Ingredient
                      if (insecticide.activeIngredient.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Active Ingredient',
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
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            insecticide.activeIngredient,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],

                      // Usage Information
                      if (insecticide.targetInsects.isNotEmpty ||
                          insecticide.suitableCrops.isNotEmpty) ...[
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
                        if (insecticide.targetInsects.isNotEmpty)
                          _buildInfoRow(Icons.bug_report, 'Target Insects',
                              insecticide.targetInsects),
                        if (insecticide.suitableCrops.isNotEmpty)
                          _buildInfoRow(Icons.agriculture, 'Suitable Crops',
                              insecticide.suitableCrops),
                        if (insecticide.modeOfAction.isNotEmpty)
                          _buildInfoRow(Icons.timeline, 'Mode of Action',
                              insecticide.modeOfAction),
                        if (insecticide.dosage.isNotEmpty)
                          _buildInfoRow(Icons.local_pharmacy, 'Dosage',
                              insecticide.dosage),
                        if (insecticide.applicationMethod.isNotEmpty)
                          _buildInfoRow(Icons.water_drop, 'Application',
                              insecticide.applicationMethod),
                        if (insecticide.phi.isNotEmpty)
                          _buildInfoRow(Icons.schedule, 'PHI (Pre-harvest)',
                              insecticide.phi),
                      ],

                      // Specifications
                      if (insecticide.specifications.isNotEmpty) ...[
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
                            children: insecticide.specifications.entries
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

                      // Safety Precautions
                      if (insecticide.safetyPrecautions.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Color(0xFFFF5722)),
                            SizedBox(width: 8),
                            Text(
                              'Safety Precautions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF5722),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            children: insecticide.safetyPrecautions
                                .map(
                                  (precaution) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.red.shade600,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            precaution,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.red.shade700,
                                            ),
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
                                    const BorderSide(color: Color(0xFF29B6F6)),
                                foregroundColor: const Color(0xFF29B6F6),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: insecticide.isAvailable
                                  ? () {
                                      Navigator.pop(context);
                                      _launchUrl(insecticide.productUrl);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF29B6F6),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(insecticide.isAvailable
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
          Icon(icon, size: 16, color: const Color(0xFF29B6F6)),
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
        return const Color(0xFF29B6F6);
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
      case 'systemic':
        return const Color(0xFF2196F3);
      case 'contact':
        return const Color(0xFFFF5722);
      case 'biological':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF29B6F6);
    }
  }
}
