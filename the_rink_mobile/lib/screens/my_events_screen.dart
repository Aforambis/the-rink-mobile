import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import 'event_detail_page.dart'; 

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EventService _eventService = EventService();
  
  // Variable untuk menyimpan hasil future biar bisa di-refresh
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil data setiap kali halaman ini dibuka/diakses
    final request = context.read<CookieRequest>();
    _eventsFuture = _eventService.fetchEvents(request);
  }

  Future<void> _refreshData() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _eventsFuture = _eventService.fetchEvents(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Events"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.glacialBlue,
          indicatorColor: AppColors.frostPrimary,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<List<Event>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Text("Failed to load events"),
                       ElevatedButton(onPressed: _refreshData, child: const Text("Retry"))
                     ],
                   ),
                 );
              }

              final allEvents = snapshot.data ?? [];
              
              // Filter event yang isRegistered == true
              // DEBUG: Kalau masih kosong, pastikan backend benar-benar mengembalikan is_registered: true
              final myEvents = allEvents.where((e) => e.isRegistered).toList();

              // Logic sorting sederhana
              final upcoming = myEvents; // Bisa ditambah filter tanggal jika perlu
              final past = <Event>[]; 

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(upcoming),
                  _buildList(past, isPast: true),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Event> events, {bool isPast = false}) {
    if (events.isEmpty) {
      return ListView( // Pakai ListView biar RefreshIndicator tetap jalan walau kosong
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: AppColors.mutedText.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    isPast ? "No past events" : "You haven't joined any events yet",
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      itemCount: events.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
               borderRadius: BorderRadius.circular(8),
               child: Image.network(
                 event.imageUrl, 
                 width: 60, height: 60, fit: BoxFit.cover, 
                 errorBuilder: (_,__,___) => Container(color: Colors.grey[200], width: 60, height: 60, child: const Icon(Icons.event)),
               ),
            ),
            title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${event.date} • ${event.location}"),
            trailing: isPast 
              ? const Chip(label: Text("Completed")) 
              : const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
              );
            },
          ),
        );
      },
    );
  }
}