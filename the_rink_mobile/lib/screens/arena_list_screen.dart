import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/booking_arena.dart';
import '../widgets/arena_card.dart';
// import '../theme/app_theme.dart';
import 'arena_detail_screen.dart';

class ArenaListScreen extends StatefulWidget {
  // Callback opsional kalo lu mau handle login pas klik booking
  final VoidCallback? onActionRequired; 

  const ArenaListScreen({super.key, this.onActionRequired});

  @override
  State<ArenaListScreen> createState() => _ArenaListScreenState();
}

class _ArenaListScreenState extends State<ArenaListScreen> {
  // URL Standar Emulator
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<Arena>> fetchArenas(CookieRequest request) async {
    final response = await request.get('$baseUrl/booking/api/arenas/');
    
    // Handling kalau response null/string/list
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
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Arena'),
      ),
      body: FutureBuilder(
        future: fetchArenas(request),
        builder: (context, AsyncSnapshot<List<Arena>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text("Gagal mengambil data arena."),
                  Text("${snapshot.error}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada arena yang tersedia.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final arena = snapshot.data![index];
              return ArenaCard(
                arena: arena,
                onTap: () {
                   // Navigasi ke detail
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => ArenaDetailScreen(arena: arena),
                     ),
                   );
                },
              );
            },
          );
        },
      ),
    );
  }
}