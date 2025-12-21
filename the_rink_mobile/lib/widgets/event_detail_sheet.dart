import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';
import '../services/event_service.dart';
import '../auth/login.dart';

class EventDetailSheet extends StatefulWidget {
  final Event event;
  final Function(int eventId) onRSVP;
  final Function(Event recommendedEvent) onRecommendationClick;

  const EventDetailSheet({
    super.key,
    required this.event,
    required this.onRSVP,
    required this.onRecommendationClick,
  });

  @override
  State<EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends State<EventDetailSheet> {
  late Future<Map<String, dynamic>> _detailFuture;
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _detailFuture = _eventService.fetchEventDetail(request, widget.event.id);
  }

  void _handleRSVP() {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    widget.onRSVP(widget.event.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<CookieRequest>().loggedIn;
    final isRegistered = widget.event.isRegistered;
    final isFull =
        widget.event.participantCount >= widget.event.maxParticipants;

    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Hampir full screen biar puas
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.snowSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
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

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero, // Padding diatur manual di child
                  children: [
                    // 1. HERO IMAGE (Langsung nempel atas)
                    Hero(
                      tag:
                          'event-img-${widget.event.id}', // Tag harus SAMA dengan di Home
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: Image.network(
                            widget.event.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[300]),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul & Kategori
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.frostPrimary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.event.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.frostPrimaryDark,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "\$${widget.event.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.frostPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.event.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.glacialBlue,
                                ),
                          ),

                          const SizedBox(height: 16),

                          // Info Row (Waktu & Lokasi)
                          _buildInfoRow(
                            Icons.calendar_today,
                            "${widget.event.date} • ${widget.event.time}",
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.location_on,
                            widget.event.location,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.people,
                            "${widget.event.participantCount} / ${widget.event.maxParticipants} Participants",
                          ),

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),

                          const Text(
                            "About",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.event.description,
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Tombol RSVP
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (isRegistered || isFull) && isLoggedIn
                                  ? null
                                  : _handleRSVP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.frostPrimary,
                                disabledBackgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                !isLoggedIn
                                    ? "Login to RSVP"
                                    : isRegistered
                                    ? "You're Going!"
                                    : isFull
                                    ? "Sold Out"
                                    : "RSVP Now",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // RECOMMENDATIONS (Versi Immersive Mini)
                          FutureBuilder<Map<String, dynamic>>(
                            future: _detailFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const SizedBox.shrink();
                              final data = snapshot.data ?? {};
                              final rawRecs =
                                  data['recommended_events'] as List? ?? [];

                              if (rawRecs.isEmpty)
                                return const SizedBox.shrink();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "You Might Also Like",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 160, // Tinggi area scroll
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: rawRecs.length,
                                      itemBuilder: (context, index) {
                                        var recData = rawRecs[index];
                                        // Fix URL dummy
                                        if (recData['image_url'] != null &&
                                            !recData['image_url']
                                                .toString()
                                                .startsWith('http')) {
                                          recData['image_url'] =
                                              "${_eventService.baseUrl}${recData['image_url']}";
                                        }
                                        final recEvent = Event.fromJson(
                                          recData,
                                        );

                                        // MINI IMMERSIVE CARD
                                        return GestureDetector(
                                          onTap: () => widget
                                              .onRecommendationClick(recEvent),
                                          child: Container(
                                            width: 140,
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Stack(
                                                children: [
                                                  // Gambar
                                                  Positioned.fill(
                                                    child: Image.network(
                                                      recEvent.imageUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  // Gradasi
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                          ],
                                                          stops: const [
                                                            0.5,
                                                            1.0,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Teks
                                                  Positioned(
                                                    bottom: 12,
                                                    left: 12,
                                                    right: 12,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          recEvent.name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          recEvent.date,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                                fontSize: 10,
                                                              ),
                                                        ),
                                                      ],
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
                                  const SizedBox(height: 40),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper Widget kecil
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedText),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
        ),
      ],
    );
  }
}
