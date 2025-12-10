import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/package.dart';
import '../models/community_post.dart';
import '../screens/home_events_screen.dart';
import '../screens/arena_booking_screen.dart';
import '../screens/gear_rental_screen.dart';
import '../screens/community_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/auth_modal_sheet.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart'; // Ensure this file exists

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // --- UPDATED MOCK DATA (Matches new Event model with participant counts) ---
  final List<Event> _featuredEvents = [
    Event(
      id: 1,
      name: 'Komet 3I/ATLAS Exhibition',
      description: 'Special cosmic skating experience with projection mapping',
      date: 'Dec 25, 2024',
      time: '18:00',
      location: 'Main Arena',
      imageUrl: 'https://via.placeholder.com/150',
      // New required fields
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
      // New required fields
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
      // New required fields
      participantCount: 150,
      maxParticipants: 200,
      isRegistered: false,
    ),
  ];

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

  final List<CommunityPost> _communityPosts = [
    CommunityPost(
      id: '1',
      username: 'ice_queen_23',
      content:
          'Just nailed my first axel jump! 🎉 The coaching here is incredible. Thank you Coach Maria!',
      likes: 142,
      timeAgo: '2h ago',
      avatarColor: 'blue',
    ),
    CommunityPost(
      id: '2',
      username: 'hockey_dad_mike',
      content:
          'My son\'s team won their first game today at The Rink! Such an amazing facility. Highly recommend for youth hockey.',
      likes: 89,
      timeAgo: '5h ago',
      avatarColor: 'red',
    ),
    CommunityPost(
      id: '3',
      username: 'figure_skater_sara',
      content:
          'The new LED floor lighting during evening sessions is absolutely stunning! Perfect for practice videos 📹',
      likes: 203,
      timeAgo: '1d ago',
      avatarColor: 'purple',
    ),
    CommunityPost(
      id: '4',
      username: 'first_timer_joe',
      content:
          'Took my first skating lesson today. Fell about 20 times but had a blast! Staff was super patient and helpful.',
      likes: 67,
      timeAgo: '2d ago',
      avatarColor: 'green',
    ),
  ];

  void _onNavTap(int index, CookieRequest request) {
    // Check real login status from CookieRequest for protected tabs
    if (!request.loggedIn && (index == 1 || index == 2)) {
      _showAuthModal();
      return;
    }

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
        onGoogleSignIn: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In is not yet implemented.'),
            ),
          );
        },
        onUsernamePasswordSignIn: () {
          Navigator.pop(context);
          // Navigate to the real Login Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        onContinueAsGuest: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleActionButton({required String action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action action confirmed!'),
        backgroundColor: AppColors.frostPrimary,
      ),
    );
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
        return const ArenaBookingScreen();
      case 2:
        return const GearRentalScreen();
      case 3:
        return CommunityScreen(
          posts: _communityPosts,
          isLoggedIn: request.loggedIn,
          onActionRequired: _showAuthModal,
        );
      case 4:
        return ProfileScreen(
          isLoggedIn: request.loggedIn,
          onSignOut: () async {
            // Replace with your actual PWS URL
            final response = await request.logout(
                "https://angga-tri41-therink.pbp.cs.ui.ac.id/auth/logout/");
            if (context.mounted) {
              String message = response["message"];
              if (response['status']) {
                String uname = response["username"];
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("$message Sampai jumpa, $uname."),
                ));
                setState(() {
                  _selectedIndex = 0;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(message),
                ));
              }
            }
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
    // Watch the CookieRequest provider to get login state
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: _getSelectedScreen(request),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onNavTap(index, request),
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