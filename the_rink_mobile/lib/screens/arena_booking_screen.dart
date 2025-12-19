// screens/arena_list_screen.dart
import 'package:flutter/material.dart';
import 'package:the_rink_mobile/theme/app_theme.dart';
import '../models/booking_arena.dart';
import '../widgets/arena_card.dart';

class ArenaBookingScreen extends StatelessWidget {
  final List<Arena> arenas;
  final bool isLoggedIn;
  final VoidCallback onActionRequired; 

  const ArenaBookingScreen({
    super.key,
    required this.arenas,
    required this.isLoggedIn,
    required this.onActionRequired, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Booking'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        child: ListView.builder(
            // ...
            itemBuilder: (context, index) {
              final arena = arenas[index];
              return ArenaCard(
                arena: arena,
                onTap: () {
                  // Contoh: Kalo mau liat detail HARUS login
                  // Kalo enggak login, panggil onActionRequired
                  if (!isLoggedIn) {
                    onActionRequired(); // <--- Panggil di sini
                  } else {
                    // Navigate ke detail
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Opening ${arena.name}...')),
                    );
                  }
                },
              );
            },
          ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Contoh: Fitur ini butuh login
          if (!isLoggedIn) {
             onActionRequired(); // <--- Panggil di sini juga
          } else {
             // Jalanin fiturnya
          }
        },
        backgroundColor: AppColors.frostPrimary,
        child: const Icon(Icons.map_outlined, color: Colors.white),
      ),
    );
  }
}