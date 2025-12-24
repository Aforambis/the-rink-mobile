import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/rental_gear_models.dart';
import '../services/rental_gear_service.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

// Global cart service instance
final cartService = CartService();

/// Build image widget that supports both SVG and regular images
Widget buildGearImage(
  String imageUrl, {
  BoxFit fit = BoxFit.cover,
  double iconSize = 32,
}) {
  if (imageUrl.isEmpty) {
    return _buildGearPlaceholder(iconSize);
  }

  // Check if URL is SVG
  if (imageUrl.toLowerCase().endsWith('.svg')) {
    return SvgPicture.network(
      imageUrl,
      fit: fit,
      placeholderBuilder: (context) => Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.frostPrimary,
        ),
      ),
    );
  }

  // Regular image
  return Image.network(
    imageUrl,
    fit: fit,
    errorBuilder: (context, error, stackTrace) =>
        _buildGearPlaceholder(iconSize),
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.frostPrimary,
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    },
  );
}

Widget _buildGearPlaceholder(double iconSize) {
  return Center(
    child: Container(
      padding: EdgeInsets.all(iconSize / 2),
      decoration: const BoxDecoration(
        gradient: AppColors.auroraGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.sports_hockey_rounded,
        size: iconSize,
        color: Colors.white,
      ),
    ),
  );
}

/// Format number to Indonesian Rupiah format
String _formatRupiah(double amount) {
  // Harga sudah dalam Rupiah, langsung format
  String price = amount.toStringAsFixed(0);
  String result = "";
  int count = 0;
  for (int i = price.length - 1; i >= 0; i--) {
    count++;
    result = price[i] + result;
    if (count == 3 && i > 0) {
      result = ".$result";
      count = 0;
    }
  }
  return result;
}

class GearRentalScreen extends StatefulWidget {
  const GearRentalScreen({super.key});

  @override
  State<GearRentalScreen> createState() => _GearRentalScreenState();
}

class _GearRentalScreenState extends State<GearRentalScreen>
    with SingleTickerProviderStateMixin {
  final RentalGearService _service = RentalGearService();
  final TextEditingController _searchController = TextEditingController();
  List<Gear> _gears = [];
  List<Gear> _filteredGears = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late AnimationController _animationController;

  // Updated categories to match backend data from Django scraping
  final List<String> _categories = [
    'All',
    'Apparel',
    'Ice Skating',
    'Protective Gear',
    'Accessories',
    'Other',
  ];

  // Category icons for visual appeal
  final Map<String, IconData> _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Apparel': Icons.checkroom_rounded,
    'Ice Skating': Icons.ice_skating,
    'Protective Gear': Icons.shield_rounded,
    'Accessories': Icons.backpack_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  // Mapping from display category to backend category (MUST match Django database values)
  final Map<String, String> _categoryMapping = {
    'All': 'all',
    'Apparel': 'apparel',
    'Ice Skating': 'ice_skating',
    'Protective Gear': 'protective_gear',
    'Accessories': 'accessories',
    'Other': 'other',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadGears();
    // Listen to cart changes for badge update
    cartService.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    cartService.removeListener(_onCartChanged);
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGears() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getAllGears();
      final gears = data.map((json) => Gear.fromJson(json)).toList();

      setState(() {
        _gears = gears;
        _filteredGears = gears;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Gear> filtered = _gears;

    // Filter by category
    if (_selectedCategory != 'All') {
      final backendCategory = _categoryMapping[_selectedCategory] ?? '';
      filtered = filtered
          .where(
            (gear) =>
                gear.category.toLowerCase() == backendCategory.toLowerCase(),
          )
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (gear) =>
                gear.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                gear.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    _filteredGears = filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.frostPrimary.withOpacity(0.9),
                    AppColors.auroraViolet.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.sports_hockey_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Gear Rental',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(items: []),
                        ),
                      );
                    },
                  ),
                ),
                if (cartService.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cartService.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.iceSheetGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.frostPrimary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search gear...',
                      hintStyle: TextStyle(
                        color: AppColors.mutedText.withOpacity(0.6),
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.frostPrimary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.mutedText,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Category Filter with modern design
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => _filterByCategory(category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.frostPrimary,
                                      AppColors.auroraViolet,
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.frostPrimary.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.frostPrimary.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _categoryIcons[category],
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.frostPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.glacialBlue,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.frostedGlass,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.softDropShadow,
              ),
              child: const CircularProgressIndicator(
                color: AppColors.frostPrimary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading gear collection...',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.frostedGlass,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softDropShadow,
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 60,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connection Error',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.glacialBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!.contains('Failed host lookup')
                    ? 'Cannot connect to server.\nPlease check your connection.'
                    : _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.frostPrimary, AppColors.auroraViolet],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.frostPrimary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _loadGears,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredGears.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.frostedGlass,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softDropShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.auroraGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_hockey_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Gear Found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.glacialBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedCategory == 'All'
                    ? 'Check back later for new equipment'
                    : 'No gear in "$_selectedCategory" category',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGears,
      color: AppColors.frostPrimary,
      backgroundColor: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _filteredGears.length,
        itemBuilder: (context, index) {
          final gear = _filteredGears[index];
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index / _filteredGears.length) * 0.5,
                    ((index + 1) / _filteredGears.length) * 0.5 + 0.5,
                    curve: Curves.easeOut,
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index / _filteredGears.length) * 0.5,
                        ((index + 1) / _filteredGears.length) * 0.5 + 0.5,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: _GearCard(gear: gear, onTap: () => _showGearDetail(gear)),
          );
        },
      ),
    );
  }

  void _showGearDetail(Gear gear) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GearDetailSheet(gear: gear),
    );
  }
}

class _GearCard extends StatefulWidget {
  final Gear gear;
  final VoidCallback onTap;

  const _GearCard({required this.gear, required this.onTap});

  @override
  State<_GearCard> createState() => _GearCardState();
}

class _GearCardState extends State<_GearCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.frostedGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.frostPrimary.withOpacity(
                  _isHovered ? 0.2 : 0.1,
                ),
                blurRadius: _isHovered ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.iceBackground,
                            Colors.white.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: _buildGearPlaceholder(48),
                          ),
                          // Featured Badge
                          if (widget.gear.isFeatured)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.frostPrimary,
                                      AppColors.auroraViolet,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.auroraViolet.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Featured',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Out of Stock Overlay
                          if (widget.gear.stock == 0)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2,
                                    sigmaY: 2,
                                  ),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'OUT OF STOCK',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Details Section
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.gear.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.glacialBlue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.frostPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.gear.category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.frostPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => AppColors
                                    .auroraGradient
                                    .createShader(bounds),
                                child: Text(
                                  'Rp ${_formatRupiah(widget.gear.pricePerDay)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Text(
                                '/day',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w500,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _GearDetailSheet extends StatefulWidget {
  final Gear gear;

  const _GearDetailSheet({required this.gear});

  @override
  State<_GearDetailSheet> createState() => _GearDetailSheetState();
}

class _GearDetailSheetState extends State<_GearDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _quantity = 1;
  int _days = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gear = widget.gear;
    final totalPrice = gear.pricePerDay * _quantity * _days;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _scaleAnimation.value),
          child: child,
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.iceBackground],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  gradient: AppColors.auroraGradient,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image Section
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.frostPrimary.withOpacity(0.1),
                                AppColors.auroraViolet.withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: _buildGearPlaceholder(80),
                        ),
                        // Gradient overlay at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Featured Badge
                        if (gear.isFeatured)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.frostPrimary,
                                    AppColors.auroraViolet,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.auroraViolet.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Featured',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            gear.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.glacialBlue,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Category Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.frostPrimary.withOpacity(0.15),
                                  AppColors.auroraViolet.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.frostPrimary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(gear.category),
                                  size: 16,
                                  color: AppColors.frostPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  gear.category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.frostPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Price Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.frostPrimary,
                                  AppColors.auroraViolet,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.frostPrimary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Price per day',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${_formatRupiah(gear.pricePerDay)}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        gear.stock > 0
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: gear.stock > 0
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        gear.stock > 0
                                            ? '${gear.stock} in stock'
                                            : 'Out of stock',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Quantity & Days Selector
                          if (gear.stock > 0) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuantitySelector(
                                    'Quantity',
                                    _quantity,
                                    gear.stock,
                                    (val) => setState(() => _quantity = val),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildQuantitySelector(
                                    'Days',
                                    _days,
                                    30,
                                    (val) => setState(() => _days = val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Seller Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.frostedGlass,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              boxShadow: AppColors.softDropShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.auroraGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Seller',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.mutedText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Admin The-Rink',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.glacialBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Add to Cart Button
                          Container(
                            decoration: BoxDecoration(
                              gradient: gear.stock > 0
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.frostPrimary,
                                        AppColors.auroraViolet,
                                      ],
                                    )
                                  : null,
                              color: gear.stock > 0 ? null : Colors.grey[300],
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: gear.stock > 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors.frostPrimary
                                            .withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: gear.stock > 0
                                    ? () {
                                        // Add to cart using cart service
                                        cartService.addToCart(
                                          gear,
                                          quantity: _quantity,
                                          days: _days,
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Added ${gear.name} x$_quantity for $_days days',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor:
                                                AppColors.frostPrimary,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            action: SnackBarAction(
                                              label: 'View Cart',
                                              textColor: Colors.white,
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                ); // Close detail sheet first
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CartScreen(
                                                      items: cartService.items
                                                          .map(
                                                            (item) =>
                                                                CartItemPreview(
                                                              gear: item.gear,
                                                              quantity:
                                                                  item.quantity,
                                                              days: item.days,
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        gear.stock > 0
                                            ? Icons.shopping_cart_rounded
                                            : Icons
                                                .remove_shopping_cart_rounded,
                                        color: gear.stock > 0
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        gear.stock > 0
                                            ? 'Add to Cart • Rp ${_formatRupiah(totalPrice)}'
                                            : 'Out of Stock',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: gear.stock > 0
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(
    String label,
    int value,
    int max,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.frostedGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: AppColors.softDropShadow,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleButton(
                Icons.remove_rounded,
                value > 1,
                () => onChanged(value - 1),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.glacialBlue,
                ),
              ),
              _buildCircleButton(
                Icons.add_rounded,
                value < max,
                () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, bool enabled, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.auroraGradient : null,
            color: enabled ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'skates':
        return Icons.ice_skating;
      case 'protective gear':
        return Icons.shield_rounded;
      case 'sticks':
        return Icons.sports_hockey_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
