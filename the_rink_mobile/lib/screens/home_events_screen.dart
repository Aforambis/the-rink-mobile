import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/package.dart';
import '../widgets/featured_event_card.dart';
import '../widgets/package_card.dart';

class HomeEventsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Rink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Section
            if (featuredEvents.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Featured Events',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: featuredEvents.length,
                  itemBuilder: (context, index) {
                    final event = featuredEvents[index];
                    return FeaturedEventCard(
                      event: event,
                      onRSVP: () {
                        if (onActionRequired != null) {
                          onActionRequired!(action: 'RSVP for ${event.title}');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Packages Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Packages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return PackageCard(
                  package: package,
                  onBook: () {
                    if (onActionRequired != null) {
                      onActionRequired!(action: 'Book ${package.title}');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
