import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/booking_arena.dart';
import '../widgets/arena_card.dart';
import '../theme/app_theme.dart';
import 'arena_detail_screen.dart'; // Pastiin import screen detail lu bener

class ArenaListScreen extends StatefulWidget {
  final VoidCallback onActionRequired; // Callback buat modal login (kyk community screen)

  const ArenaListScreen({
    super.key,
    required this.onActionRequired,
  });

  @override
  State<ArenaListScreen> createState() => _ArenaListScreenState();
}

class _ArenaListScreenState extends State<ArenaListScreen> {
  // Fungsi buat ngambil data dari Django
  Future<List<Arena>> fetchArenas(CookieRequest request) async {
    // TODO: Ganti URL sesuai device lu.
    // - Android Emulator: 'http://10.0.2.2:8000/booking_arena/api/arenas/'
    // - Chrome/Browser: 'http://127.0.0.1:8000/booking_arena/api/arenas/'
    // - HP Fisik (Debugging USB): Pake IP Laptop (misal 192.168.1.x)
    
    final response = await request.get('http://127.0.0.1:8000/booking/api/arenas/');
    
    if (response == null) {
      return [];
    }

    // Decoding data
    var data = response; 
    if (response is String) {
      data = jsonDecode(response);
    }
    
    List<Arena> listArena = []; 
    for (var d in data) {
      if (d != null) {
        listArena.add(Arena.fromJson(d));
      }
    }
    return listArena; 
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>(); // Akses cookie request

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Find Arena'),
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh data manual
            },
          )
        ],
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        // DISINI KUNCINYA: FutureBuilder
        child: FutureBuilder(
          future: fetchArenas(request),
          builder: (context, AsyncSnapshot<List<Arena>> snapshot) {
            // 1. Kalo lagi loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            
            // 2. Kalo error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Gagal mengambil data arena.\nPastikan Django nyala!",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // 3. Kalo data kosong
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(context);
            }

            // 4. Kalo sukses -> Tampilin List
            return ListView.builder(
              padding: const EdgeInsets.only(top: kToolbarHeight + 40, bottom: 100),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final arena = snapshot.data![index];
                return ArenaCard(
                  arena: arena,
                  onTap: () {
                    if (!request.loggedIn) {
                      widget.onActionRequired(); 
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArenaDetailScreen(arena: arena),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Contoh logic tombol
           if (!request.loggedIn) widget.onActionRequired();
        },
        backgroundColor: AppColors.frostPrimary,
        child: const Icon(Icons.map_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.snowshoeing, size: 80, color: Colors.white70),
          const SizedBox(height: 16),
          Text(
            'No Arenas Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Belum ada data arena di Django lu bro.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}