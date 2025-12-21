import 'package:flutter/material.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

class FeaturedEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onPressed;

  const FeaturedEventCard({
    super.key,
    required this.event,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, 
      margin: const EdgeInsets.only(right: 16, bottom: 8), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. GAMBAR FULL BACKGROUND + HERO
            Positioned.fill(
              child: Hero(
                tag: 'event-img-${event.id}', // Tag unik untuk animasi
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover, 
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white54)
                    ),
                  ),
                ),
              ),
            ),

            // 2. GRADASI HITAM (Shadow Overlay)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent, 
                      Colors.black.withOpacity(0.4), 
                      Colors.black.withOpacity(0.9), 
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // 3. EFEK KLIK (RIPPLE)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  splashColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),

            // 4. TEXT INFO (Numpuk di Bawah)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.frostPrimary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)
                      ]
                    ),
                    child: Text(
                      event.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Judul Event
                  Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Lokasi & Tanggal
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${event.location} • ${event.date}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}