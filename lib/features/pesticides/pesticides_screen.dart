// lib/features/pesticides/pesticides_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/pesticide_model.dart';
import '../../core/services/pesticide_service.dart';

class PesticidesScreen extends StatefulWidget {
  const PesticidesScreen({super.key});

  @override
  State<PesticidesScreen> createState() => _PesticidesScreenState();
}

class _PesticidesScreenState extends State<PesticidesScreen>
    with TickerProviderStateMixin {
  final PesticideService _pesticideService = PesticideService();
  final TextEditingController _searchController = TextEditingController();

  List<PesticideModel> _pesticides = [];
  List<PesticideModel> _filteredPesticides = [];
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

    _loadAllPesticides();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPesticides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pesticides = await _pesticideService.getAllPesticides();
      setState(() {
        _pesticides = pesticides;
        _filteredPesticides = pesticides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _filterPesticides() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<PesticideModel> pesticides;

      if (_selectedCategory == 'all') {
        pesticides = await _pesticideService.getAllPesticides();
      } else {
        pesticides =
            await _pesticideService.getPesticidesByCategory(_selectedCategory);
      }

      if (_selectedPlatform != 'all') {
        pesticides =
            pesticides.where((p) => p.platform == _selectedPlatform).toList();
      }

      setState(() {
        _pesticides = pesticides;
        _filteredPesticides = pesticides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchPesticides(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredPesticides = _pesticides;
      });
      return;
    }

    try {
      final searchResults = await _pesticideService.searchPesticides(query);
      setState(() {
        _filteredPesticides = searchResults;
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

  void _showPesticideDetails(PesticideModel pesticide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPesticideDetailsModal(pesticide),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        title: const Text(
          'Pesticides Store',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAllPesticides,
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

            // Pesticides List
            Expanded(
              child: _buildPesticidesList(),
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
          colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
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
              onChanged: _searchPesticides,
              decoration: InputDecoration(
                hintText: 'Search pesticides, pests, crops...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF7043)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchPesticides('');
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
                  Icons.scatter_plot, '${_pesticides.length}', 'Products'),
              _buildStatItem(Icons.eco,
                  '${_pesticides.where((p) => p.isOrganic).length}', 'Organic'),
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
              itemCount: ['all', ...PesticideService.getCategories()].length,
              itemBuilder: (context, index) {
                final categories = ['all', ...PesticideService.getCategories()];
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _filterPesticides();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFFF7043) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF7043)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category == 'all'
                              ? Icons.grid_view
                              : PesticideService.getCategoryIcon(category),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFFF7043),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category == 'all'
                              ? 'All'
                              : PesticideService.getCategoryDisplayName(
                                  category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFFF7043),
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
        _filterPesticides();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7043) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF7043) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFFF7043),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFFFF7043),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesticidesList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF7043)),
            SizedBox(height: 16),
            Text('Loading pesticides...'),
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
              'Failed to load pesticides',
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
              onPressed: _loadAllPesticides,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredPesticides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No pesticides found',
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
      onRefresh: _loadAllPesticides,
      color: const Color(0xFFFF7043),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPesticides.length,
        itemBuilder: (context, index) {
          final pesticide = _filteredPesticides[index];
          return _buildPesticideCard(pesticide);
        },
      ),
    );
  }

  Widget _buildPesticideCard(PesticideModel pesticide) {
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
                  pesticide.imageUrl,
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
                          Icon(Icons.scatter_plot,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Pesticide Image',
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
                    color: _getPlatformColor(pesticide.platform),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPlatformIcon(pesticide.platform),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pesticide.platform.toUpperCase(),
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
              if (pesticide.isOrganic)
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

              // Category Badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(pesticide.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    PesticideService.getCategoryDisplayName(pesticide.category),
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

          // Pesticide Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Brand
                Text(
                  pesticide.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A42),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (pesticide.brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'by ${pesticide.brand}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Active Ingredient
                if (pesticide.activeIngredient.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pesticide.activeIngredient,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Target Pests
                if (pesticide.targetPests.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bug_report,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Target: ${pesticide.targetPests}',
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
                if (pesticide.suitableCrops.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.agriculture,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Crops: ${pesticide.suitableCrops}',
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
                if (pesticide.rating > 0)
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < pesticide.rating.floor()
                                ? Icons.star
                                : index < pesticide.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${pesticide.rating} (${pesticide.reviewCount})',
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
                              '₹${pesticide.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF7043),
                              ),
                            ),
                            if (pesticide.packSize.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                '/ ${pesticide.packSize}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (pesticide.deliveryInfo.isNotEmpty)
                          Text(
                            pesticide.deliveryInfo,
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
                          onPressed: () => _showPesticideDetails(pesticide),
                          icon: const Icon(Icons.info_outline),
                          color: const Color(0xFFFF7043),
                        ),
                        ElevatedButton(
                          onPressed: pesticide.isAvailable
                              ? () => _launchUrl(pesticide.productUrl)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043),
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

  Widget _buildPesticideDetailsModal(PesticideModel pesticide) {
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
                      // Pesticide Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          pesticide.imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.scatter_plot, size: 64),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title and Brand
                      Text(
                        pesticide.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A42),
                        ),
                      ),

                      if (pesticide.brand.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Brand: ${pesticide.brand}',
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
                                    '₹${pesticide.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF7043),
                                    ),
                                  ),
                                  if (pesticide.packSize.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '/ ${pesticide.packSize}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (pesticide.deliveryInfo.isNotEmpty)
                                Text(
                                  pesticide.deliveryInfo,
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
                              color: _getPlatformColor(pesticide.platform),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getPlatformIcon(pesticide.platform),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  pesticide.platform.toUpperCase(),
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
                        pesticide.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),

                      // Active Ingredient
                      if (pesticide.activeIngredient.isNotEmpty) ...[
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
                            pesticide.activeIngredient,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],

                      // Usage Information
                      if (pesticide.targetPests.isNotEmpty ||
                          pesticide.suitableCrops.isNotEmpty) ...[
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
                        if (pesticide.targetPests.isNotEmpty)
                          _buildInfoRow(Icons.bug_report, 'Target Pests',
                              pesticide.targetPests),
                        if (pesticide.suitableCrops.isNotEmpty)
                          _buildInfoRow(Icons.agriculture, 'Suitable Crops',
                              pesticide.suitableCrops),
                        if (pesticide.dosage.isNotEmpty)
                          _buildInfoRow(
                              Icons.local_pharmacy, 'Dosage', pesticide.dosage),
                        if (pesticide.applicationMethod.isNotEmpty)
                          _buildInfoRow(Icons.scatter_plot, 'Application',
                              pesticide.applicationMethod),
                      ],

                      // Specifications
                      if (pesticide.specifications.isNotEmpty) ...[
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
                            children: pesticide.specifications.entries
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

                      // Safety Warnings
                      if (pesticide.safetyWarnings.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Color(0xFFFF5722)),
                            SizedBox(width: 8),
                            Text(
                              'Safety Warnings',
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
                            children: pesticide.safetyWarnings
                                .map(
                                  (warning) => Padding(
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
                                            warning,
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
                                    const BorderSide(color: Color(0xFFFF7043)),
                                foregroundColor: const Color(0xFFFF7043),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: pesticide.isAvailable
                                  ? () {
                                      Navigator.pop(context);
                                      _launchUrl(pesticide.productUrl);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7043),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(pesticide.isAvailable
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
          Icon(icon, size: 16, color: const Color(0xFFFF7043)),
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
        return const Color(0xFFFF7043);
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
      case 'insecticide':
        return const Color(0xFFFF5722);
      case 'fungicide':
        return const Color(0xFF9C27B0);
      case 'herbicide':
        return const Color(0xFF4CAF50);
      case 'organic':
        return const Color(0xFF8BC34A);
      case 'biological':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFFF7043);
    }
  }
}
