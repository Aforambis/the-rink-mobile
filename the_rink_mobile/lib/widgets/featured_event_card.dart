import 'package:flutter/material.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

class FeaturedEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onRSVP;

  const FeaturedEventCard({
    super.key,
    required this.event,
    required this.onRSVP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        decoration: WinterTheme.frostedCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Image Section
            Expanded(
              flex: 4,
              child: ClipRRect( // Clip the image to the rounded corners
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.frostPrimary, AppColors.auroraViolet],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  // UPDATED: Use Image.network with the new imageUrl field
                  child: Image.network(
                    event.imageUrl, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image fails to load
                      return const Center(
                        child: Icon(Icons.event_available, size: 40, color: Colors.white70),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Info Section
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.name, // FIXED: Changed from event.title to event.name
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                         const SizedBox(height: 2),
                         // Added location for better context
                         Text(
                          event.location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.frostPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onRSVP,
                        child: const Text(
                          'RSVP',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
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