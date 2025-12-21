import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/package.dart';

import '../screens/home_events_screen.dart';
import '../screens/arena_list_screen.dart';
import '../screens/gear_rental_screen.dart';
import '../screens/forum_screen.dart';
import '../auth/custprofile.dart';
import '../widgets/auth_modal_sheet.dart';
import '../auth/login.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Event> _featuredEvents = [
    Event(
      id: 1,
      name: 'Komet 3I/ATLAS Exhibition',
      description: 'Special cosmic skating experience with projection mapping',
      date: 'Dec 25, 2024',
      time: '18:00',
      location: 'Main Arena',
      imageUrl: 'https://via.placeholder.com/150',
      // Tambahan field baru biar tidak error
      price: 150000.0,
      category: 'Exhibition',
      participantCount: 45,
      maxParticipants: 100,
      isRegistered: false,
    ),
    Event(
      id: 2,
      name: 'Open Skate Night',
      description: 'Free skate session with live DJ and lights',
      date: 'Every Friday',
      time: '20:00',
      location: 'Rink B',
      imageUrl: 'https://via.placeholder.com/150',
      // Tambahan field baru
      price: 50000.0,
      category: 'Recreation',
      participantCount: 12,
      maxParticipants: 50,
      isRegistered: false,
    ),
    Event(
      id: 3,
      name: 'New Year Ice Gala',
      description: 'Ring in the new year on ice!',
      date: 'Dec 31, 2024',
      time: '22:00',
      location: 'Grand Hall',
      imageUrl: 'https://via.placeholder.com/150',
      // Tambahan field baru
      price: 250000.0,
      category: 'Gala',
      participantCount: 150,
      maxParticipants: 200,
      isRegistered: false,
    ),
  ];

  //   final List<Arena> _listArenas = [
  //   Arena(
  //     id: '1',
  //     name: 'Galactic Ice Rink Jakarta',
  //     description: 'Arena ice skating standar olimpiade pertama di Jakarta Selatan. Fasilitas lengkap dengan penyewaan sepatu premium dan pelatih profesional. Cocok buat date atau latihan serius.',
  //     capacity: 200,
  //     location: 'Gandaria City, Jakarta Selatan',
  //     imgUrl: 'https://images.unsplash.com/photo-1515706584606-e7e5d63f47e3?auto=format&fit=crop&q=80&w=1000', // Gambar Ice Rink
  //     openingHoursText: 'Senin - Minggu: 10:00 - 22:00',
  //     googleMapsUrl: 'https://maps.google.com',
  //   ),
  //   Arena(
  //     id: '2',
  //     name: 'Winter Wonderland BSD',
  //     description: 'Rasakan sensasi bermain salju dan ice skating di area semi-outdoor terbesar di Tangerang. Ada area khusus untuk pemula dan anak-anak.',
  //     capacity: 150,
  //     location: 'BSD City, Tangerang',
  //     imgUrl: 'https://images.unsplash.com/photo-1543788339-b9034cb8826c?auto=format&fit=crop&q=80&w=1000',
  //     openingHoursText: 'Weekend Only: 08:00 - 20:00',
  //     googleMapsUrl: 'https://maps.google.com',
  //   ),
  //   Arena(
  //     id: '3',
  //     name: 'Puncak Frozen Arena',
  //     description: 'Arena curling dan hockey profesional di dataran tinggi. Udara sejuk alami ditambah dinginnya es bikin suasana makin autentik.',
  //     capacity: 500,
  //     location: 'Cisarua, Bogor',
  //     imgUrl: 'https://images.unsplash.com/photo-1580748141549-71748dbe0bdc?auto=format&fit=crop&q=80&w=1000', // Gambar Hockey
  //     openingHoursText: 'Setiap Hari: 06:00 - 23:00',
  //     googleMapsUrl: 'https://maps.google.com',
  //   ),
  //   Arena(
  //     id: '4',
  //     name: 'Mall of Ice Bandung',
  //     description: 'Tempat nongkrong sambil skating. Lokasi strategis di tengah kota Bandung.',
  //     capacity: 100,
  //     location: 'Paris Van Java, Bandung',
  //     // Sengaja dikosongin imgUrl-nya buat ngetes placeholder image lu jalan apa nggak
  //     imgUrl: null,
  //     openingHoursText: '10:00 - 21:00',
  //     googleMapsUrl: 'https://maps.google.com',
  //   ),
  //   Arena(
  //     id: '5',
  //     name: 'Surabaya Polar Center',
  //     description: 'Pusat pelatihan atlet musim dingin nasional. Terbuka untuk umum pada jam tertentu. Wajib reservasi seminggu sebelumnya karena slot terbatas.',
  //     capacity: 1000,
  //     location: 'Kenjeran, Surabaya',
  //     imgUrl: 'https://images.unsplash.com/photo-1612959813568-154df67b2d5f?auto=format&fit=crop&q=80&w=1000',
  //     openingHoursText: 'Senin - Jumat: 16:00 - 22:00',
  //     googleMapsUrl: 'https://maps.google.com',
  //   ),
  // ];

  final List<Package> _packages = [
    Package(
      id: '1',
      title: 'Beginner Class',
      description: '4-week introduction to ice skating for all ages',
      price: 149.99,
      duration: '4 weeks',
    ),
    Package(
      id: '2',
      title: 'Date Night Bundle',
      description: 'Skate rental for 2, hot cocoa, and private ice time',
      price: 89.99,
      duration: '2 hours',
    ),
    Package(
      id: '3',
      title: 'Family Season Pass',
      description: 'Unlimited skating for up to 4 family members',
      price: 599.99,
      duration: '3 months',
    ),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AuthModalSheet(
        onUsernamePasswordSignIn: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        onContinueAsGuest: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleActionButton({required String action}) {
    if (!context.read<CookieRequest>().loggedIn) {
      _showAuthModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action action confirmed!'),
          backgroundColor: AppColors.frostPrimary,
        ),
      );
    }
  }

  Widget _getSelectedScreen(CookieRequest request) {
    switch (_selectedIndex) {
      case 0:
        return HomeEventsScreen(
          // Pass the fallback data (used if backend is empty/error)
          featuredEvents: _featuredEvents,
          packages: _packages,
          onActionRequired: _handleActionButton,
        );
      case 1:
        return ArenaListScreen(
          onActionRequired: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        );

      case 2:
        return const GearRentalScreen();
      case 3:
        return const ForumScreen();
      case 4:
        return ProfileScreen(
          isLoggedIn: context.read<CookieRequest>().loggedIn,
          onSignOut: () async {
            final request = context.read<CookieRequest>();
            await request.logout(
              "https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/logout/",
            );
            setState(() {
              _selectedIndex = 0;
            });
          },
          onSignIn: _showAuthModal,
        );
      default:
        return HomeEventsScreen(
          featuredEvents: _featuredEvents,
          packages: _packages,
          onActionRequired: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: _getSelectedScreen(request),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onNavTap(index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ice_skating_rounded),
            label: 'Arena',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_hockey_rounded),
            label: 'Gear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
