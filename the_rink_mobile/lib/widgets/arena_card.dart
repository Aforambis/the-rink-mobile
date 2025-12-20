import 'package:flutter/material.dart';
import '../models/booking_arena.dart';
import '../theme/app_theme.dart'; 

class ArenaCard extends StatelessWidget {
  final Arena arena;
  final VoidCallback onTap;

  const ArenaCard({
    super.key,
    required this.arena,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // Biar gambar ngikutin lengkungan card
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Arena (Handle kalo null pake placeholder)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: arena.imgUrl != null && arena.imgUrl!.isNotEmpty
                  ? Image.network(
                      arena.imgUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stack) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            
            // 2. Info Arena
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Arena
                  Text(
                    arena.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Lokasi (Icon + Text)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, 
                                 size: 16, color: AppColors.frostPrimary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          arena.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Kapasitas
                  Row(
                    children: [
                      const Icon(Icons.people_outline, 
                                 size: 16, color: AppColors.frostPrimary),
                      const SizedBox(width: 4),
                      Text(
                        'Capacity: ${arena.capacity}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
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

  // Placeholder kalo gak ada gambar biar gak jelek
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.stadium_outlined, size: 48, color: Colors.grey[400]),
      ),
    );
  }
}