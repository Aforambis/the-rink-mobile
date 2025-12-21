import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/package.dart';
import '../widgets/featured_event_card.dart';
import '../widgets/event_detail_sheet.dart';
import '../theme/app_theme.dart';
import '../services/event_service.dart';
import '../screens/event_detail_page.dart';

class HomeEventsScreen extends StatefulWidget {
  final List<Event> featuredEvents;
  final List<Package> packages;
  final Function({required String action})? onActionRequired;

  const HomeEventsScreen({
    super.key,
    required this.featuredEvents,
    required this.packages,
    this.onActionRequired,
  });

  @override
  State<HomeEventsScreen> createState() => _HomeEventsScreenState();
}

class _HomeEventsScreenState extends State<HomeEventsScreen> {
  final EventService _eventService = EventService();

  // State untuk Search & Filter
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Competition",
    "Workshop",
    "Social",
    "Party",
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // --- SMART LOGIC: SORT BY POPULARITY ---
  Future<void> _loadEvents() async {
    final request = context.read<CookieRequest>();
    final events = await _eventService.fetchEvents(request);

    if (!mounted) return;

    // 1. Copy list biar aman
    List<Event> candidates = List.from(events);

    // 2. Sort berdasarkan peserta terbanyak (Descending) -> Biar yang laku naik ke atas
    candidates.sort((a, b) => b.participantCount.compareTo(a.participantCount));

    // 3. Ambil 3 Teratas sebagai "Featured"
    List<Event> featured = candidates.take(3).toList();

    // 4. Sisanya jadi "Upcoming", urutkan berdasarkan Tanggal Terdekat
    List<Event> upcoming = events
        .where((e) => !featured.any((f) => f.id == e.id))
        .toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));

    // 5. Gabung: [Featured 1, Featured 2, Featured 3, Upcoming 1, ...]
    List<Event> finalSmartList = [...featured, ...upcoming];

    setState(() {
      _allEvents = finalSmartList;
      _filteredEvents = finalSmartList;
      _isLoading = false;
    });
  }

  void _runFilter() {
    List<Event> results = _allEvents;

    if (_selectedCategory != "All") {
      results = results
          .where(
            (e) => e.category.toLowerCase() == _selectedCategory.toLowerCase(),
          )
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      results = results
          .where(
            (e) =>
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.location.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _filteredEvents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('The Rink'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // --- 1. SEARCH BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _runFilter();
                    },
                    decoration: InputDecoration(
                      hintText: "Search events, location...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.frostPrimary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: AppColors.frostPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- 2. CATEGORY FILTER ---
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              _runFilter();
                            });
                          },
                          selectedColor: AppColors.frostPrimary,
                          backgroundColor: Colors.white.withOpacity(0.8),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.glacialBlue,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.frostPrimary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filteredEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "No events found :(",
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FEATURED EVENTS (Top 3) ---
                      if (_searchQuery.isEmpty &&
                          _selectedCategory == "All") ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Featured Events',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.glacialBlue,
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            // Tampilkan max 3 event
                            itemCount: _filteredEvents.length > 3
                                ? 3
                                : _filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = _filteredEvents[index];
                              return FeaturedEventCard(
                                event: event,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventDetailPage(event: event),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // --- UPCOMING EVENTS (Sisanya) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Search Results'
                              : 'Upcoming Events',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.glacialBlue,
                              ),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // Kalau search: tampilin semua. Kalau home: tampilin mulai dari index ke-3 (karena 0,1,2 udah di Featured)
                        itemCount:
                            (_searchQuery.isEmpty && _selectedCategory == "All")
                            ? (_filteredEvents.length > 3
                                  ? _filteredEvents.length - 3
                                  : 0)
                            : _filteredEvents.length,
                        itemBuilder: (context, index) {
                          // Offset index +3
                          final actualIndex =
                              (_searchQuery.isEmpty &&
                                  _selectedCategory == "All")
                              ? index + 3
                              : index;

                          if (actualIndex >= _filteredEvents.length)
                            return const SizedBox.shrink();

                          final event = _filteredEvents[actualIndex];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventDetailPage(event: event),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          event.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.frostPrimary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                event.category,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors
                                                      .frostPrimaryDark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              event.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: AppColors.mutedText,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  event.date,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.mutedText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Rp ${event.price.toStringAsFixed(0)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.frostPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
