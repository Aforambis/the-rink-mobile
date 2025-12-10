import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/package.dart';
import '../widgets/featured_event_card.dart';
import '../widgets/package_card.dart';
import '../theme/app_theme.dart';

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
  // Use 10.0.2.2 for Android Emulator, or your PWS URL
  final String baseUrl = "https://angga-tri41-therink.pbp.cs.ui.ac.id";

  Future<List<Event>> fetchEvents(CookieRequest request) async {
    final response = await request.get('$baseUrl/events/api/list/');
    List<Event> listEvents = [];
    for (var d in response) {
      if (d != null) {
        listEvents.add(Event.fromJson(d));
      }
    }
    return listEvents;
  }

  Future<void> joinEvent(CookieRequest request, int eventId) async {
    try {
      final response = await request.post(
        '$baseUrl/events/api/join/$eventId/',
        {},
      );
      if (mounted) {
        if (response['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Successfully joined the event!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to join"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error connecting to server"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'Featured Events',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.glacialBlue,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: FutureBuilder(
                    future: fetchEvents(request),
                    builder: (context, AsyncSnapshot<List<Event>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        // Fallback logic preserved
                        if (widget.featuredEvents.isNotEmpty) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.featuredEvents.length,
                            itemBuilder: (context, index) {
                              final event = widget.featuredEvents[index];
                              return FeaturedEventCard(
                                event: event,
                                onRSVP: () {
                                  if (widget.onActionRequired != null) {
                                    widget.onActionRequired!(
                                      action:
                                          'RSVP for ${event.name}', // CHANGED .title to .name
                                    );
                                  }
                                },
                              );
                            },
                          );
                        }
                        return const Center(child: Text("No events available"));
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final event = snapshot.data![index];
                            return FeaturedEventCard(
                              event: event,
                              onRSVP: () {
                                joinEvent(request, event.id);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                // ... Packages Section (unchanged) ...
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Popular Packages',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.glacialBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.packages.length,
                  itemBuilder: (context, index) {
                    final package = widget.packages[index];
                    return PackageCard(
                      package: package,
                      onBook: () {
                        if (widget.onActionRequired != null) {
                          widget.onActionRequired!(
                            action: 'Book ${package.title}',
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
