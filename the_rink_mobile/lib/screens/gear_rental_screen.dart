import 'package:flutter/material.dart';
import '../models/rental_gear_models.dart';
import '../services/rental_gear_service.dart';
import 'cart_screen.dart';
import '../theme/app_theme.dart';

class GearRentalScreen extends StatefulWidget {
  const GearRentalScreen({super.key});

  @override
  State<GearRentalScreen> createState() => _GearRentalScreenState();
}

class _GearRentalScreenState extends State<GearRentalScreen> {
  final RentalGearService _service = RentalGearService();
  List<Gear> _gears = [];
  List<Gear> _filteredGears = [];
  final TextEditingController _searchController = TextEditingController();
  // Simple local cart state (demo)
  final List<CartItemPreview> _cartItems = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _activeCategory;

  String _getCategoryDisplay(String category) {
    final categoryMap = {
      'ice_skating': 'Ice Skating',
      'protective_gear': 'Protective Gear',
      'hockey': 'Hockey',
      'apparel': 'Apparel',
      'accessories': 'Accessories',
      'curling': 'Curling',
    };
    return categoryMap[category.toLowerCase()] ?? category;
  }

  IconData _getCategoryIcon(String category) {
    final iconMap = {
      'ice_skating': Icons.ice_skating,
      'protective_gear': Icons.shield,
      'hockey': Icons.sports_hockey,
      'apparel': Icons.checkroom,
      'accessories': Icons.shopping_bag,
      'curling': Icons.sports,
    };
    return iconMap[category.toLowerCase()] ?? Icons.sports_hockey_rounded;
  }

  // Category mapping removed; search-only filtering

  @override
  void initState() {
    super.initState();
    _loadGears();
    _searchController.addListener(() {
      final text = _searchController.text;
      if (text != _searchQuery) {
        _onSearchChanged(text);
      }
    });
  }

  @override
  void dispose() {
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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String text) {
    setState(() {
      _searchQuery = text.trim().toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Gear> result = _gears;

    // Search filter (name + description + seller)
    if (_searchQuery.isNotEmpty) {
      result = result.where((g) {
        final hay = '${g.name} ${g.description} ${g.sellerUsername}'
            .toLowerCase();
        return hay.contains(_searchQuery);
      }).toList();
    }

    // Category filter (optional, from chips)
    if (_activeCategory != null && _activeCategory!.isNotEmpty) {
      result = result
          .where((g) => g.category.toLowerCase() == _activeCategory)
          .toList();
    }

    _filteredGears = result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
        ),
        title: const Text('Gear Rental'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      CartScreen(items: List<CartItemPreview>.from(_cartItems)),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              // Search + filter row (search field with a filter button on the right)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search gear…',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.snowSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.frostPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: AppColors.frostedGlass,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        tooltip: 'Filters',
                        icon: const Icon(Icons.tune),
                        color: AppColors.frostPrimary,
                        onPressed: () {
                          // placeholder: we keep chips visible below; this button can open advanced filters later
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Single horizontal row: search bar followed by filter chips
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // Inline search field styled like a wide chip
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: SizedBox(
                        width: 320,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search gear…',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.snowSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.frostPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._buildCategoryChips(),
                  ],
                ),
              ),

              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategoryChips() {
    final categories =
        _gears.map((g) => g.category.toLowerCase()).toSet().toList()..sort();

    final widgets = <Widget>[];
    widgets.add(
      _FilterChip(
        label: 'All',
        selected: _activeCategory == null,
        onTap: () {
          setState(() {
            _activeCategory = null;
            _applyFilters();
          });
        },
      ),
    );

    for (final c in categories) {
      widgets.add(const SizedBox(width: 8));
      widgets.add(
        _FilterChip(
          label: _getCategoryDisplay(c),
          icon: _getCategoryIcon(c),
          selected: _activeCategory == c,
          onTap: () {
            setState(() {
              _activeCategory = c;
              _applyFilters();
            });
          },
        ),
      );
    }
    return widgets;
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.frostPrimary),
      );
    }

    if (_error != null) {
      final isNetworkIssue = _error!.toLowerCase().contains(
        'failed host lookup',
      );
      final friendlyMessage = isNetworkIssue
          ? 'Cannot reach the server. Make sure the backend is running or your device is online.'
          : _error!;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.frostedGlass,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.softDropShadow,
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: AppColors.auroraGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load gear',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.glacialBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  friendlyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadGears,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_filteredGears.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_hockey_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No gears available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new equipment',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGears,
      color: AppColors.frostPrimary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isTablet = constraints.maxWidth >= 600;
          final crossAxisCount = isWide ? 4 : (isTablet ? 3 : 2);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredGears.length,
            itemBuilder: (context, index) {
              final gear = _filteredGears[index];
              return _GearCard(gear: gear, onTap: () => _showGearDetail(gear));
            },
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
      builder: (context) => _GearDetailSheet(
        gear: gear,
        onAddToCart: (g) {
          // add or increase quantity if same gear exists
          final idx = _cartItems.indexWhere((e) => e.gear.id == g.id);
          if (idx >= 0) {
            _cartItems[idx] = CartItemPreview(
              gear: _cartItems[idx].gear,
              quantity: _cartItems[idx].quantity + 1,
              days: _cartItems[idx].days,
            );
          } else {
            _cartItems.add(CartItemPreview(gear: g, quantity: 1, days: 1));
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${g.name} to cart'),
              action: SnackBarAction(
                label: 'View Cart',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        items: List<CartItemPreview>.from(_cartItems),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
          setState(() {});
        },
      ),
    );
  }

  Future<void> _openSearch() async {
    final selected = await showSearch<Gear?>(
      context: context,
      delegate: _GearSearchDelegate(gears: _gears),
    );

    if (!mounted || selected == null) return;
    _showGearDetail(selected);
  }
}

class _GearCard extends StatelessWidget {
  final Gear gear;
  final VoidCallback onTap;

  const _GearCard({
    required this.gear,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[100]!, Colors.grey[200]!],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: gear.imageUrl.isNotEmpty
                        ? Hero(
                            tag: 'gear_${gear.id}',
                            child: Image.network(
                              gear.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: AppColors.frostPrimary,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.sports_hockey_rounded,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              _getCategoryIcon(gear.category),
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                  // Featured Badge
                  if (gear.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.frostPrimary,
                              AppColors.frostSecondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.frostPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, color: Colors.white, size: 12),
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
                    if (gear.stock == 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gear.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (gear.stock > 0)
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${gear.stock} in stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${gear.pricePerDay.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.frostPrimary,
                          ),
                        ),
                        const Text(
                          '/day',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
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
    );
  }
}

class _GearSearchDelegate extends SearchDelegate<Gear?> {
  _GearSearchDelegate({required this.gears});

  final List<Gear> gears;

  @override
  String? get searchFieldLabel => 'Search gear, seller, or category';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.frostPrimary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        hintStyle: const TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: base.textTheme.apply(bodyColor: Colors.white),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? gears.take(6).toList() : _filter(query);
    if (suggestions.isEmpty) {
      return _EmptySuggestion(message: 'No matching gear found.');
    }
    return _ResultList(
      gears: suggestions,
      onSelected: (gear) => close(context, gear),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filter(query);
    if (results.isEmpty) {
      return _EmptySuggestion(message: 'No results for "$query"');
    }
    return _ResultList(
      gears: results,
      onSelected: (gear) => close(context, gear),
    );
  }

  List<Gear> _filter(String term) {
    final q = term.trim().toLowerCase();
    if (q.isEmpty) return gears;
    return gears.where((gear) {
      final haystack =
          '${gear.name} ${gear.description} ${gear.category} ${gear.sellerUsername}'
              .toLowerCase();
      return haystack.contains(q);
    }).toList();
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.gears, required this.onSelected});

  final List<Gear> gears;
  final ValueChanged<Gear> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        final gear = gears[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.frostPrimary.withOpacity(0.15),
            child: Icon(Icons.ice_skating, color: AppColors.frostPrimary),
          ),
          title: Text(gear.name),
          subtitle: Text(
            '${gear.category} • ${gear.sellerUsername.isEmpty ? 'The Rink' : gear.sellerUsername}',
          ),
          trailing: Text(
            '\$${gear.pricePerDay.toStringAsFixed(0)}/day',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => onSelected(gear),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemCount: gears.length,
    );
  }
}

class _EmptySuggestion extends StatelessWidget {
  const _EmptySuggestion({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppColors.mutedText)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.frostPrimary.withOpacity(0.15)
              : AppColors.snowSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.frostPrimary
                : Colors.white.withOpacity(0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.frostPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.glacialBlue : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GearDetailSheet extends StatelessWidget {
  final Gear gear;
  final void Function(Gear gear) onAddToCart;

  const _GearDetailSheet({required this.gear, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.iceSheetGradient,
              ),
              child: gear.imageUrl.isNotEmpty
                  ? Image.network(
                      gear.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.sports_hockey_rounded,
                          size: 80,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons.sports_hockey_rounded,
                      size: 80,
                      color: Colors.grey,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gear.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (gear.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.frostPrimary,
                                AppColors.frostSecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.snowSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryDisplay(gear.category),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.glacialBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${gear.pricePerDay.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.frostPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'per day',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stock
                  Row(
                    children: [
                      Icon(
                        gear.stock > 0
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: gear.stock > 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        gear.stock > 0
                            ? '${gear.stock} available'
                            : 'Out of stock',
                        style: TextStyle(
                          fontSize: 16,
                          color: gear.stock > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Seller
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Seller: ${gear.sellerUsername.isNotEmpty ? gear.sellerUsername : 'The Rink'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gear.description.isNotEmpty
                        ? gear.description
                        : 'No description available.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: gear.stock > 0
                          ? () => onAddToCart(gear)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(
                        gear.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplay(String category) {
    const categoryMap = {
      'ice_skating': 'Ice Skating',
      'protective_gear': 'Protective Gear',
      'hockey': 'Hockey',
      'apparel': 'Apparel',
      'accessories': 'Accessories',
      'curling': 'Curling',
    };
    return categoryMap[category.toLowerCase()] ?? category;
  }
}
