import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/package.dart';
import '../models/community_post.dart';
import '../screens/home_events_screen.dart';
import '../screens/arena_list_screen.dart';
import '../screens/gear_rental_screen.dart';
import '../screens/community_screen.dart';
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

  // Mock data
  final List<Event> _featuredEvents = [
    Event(
      id: '1',
      title: 'Komet 3I/ATLAS Exhibition',
      description: 'Special cosmic skating experience with projection mapping',
      date: 'Dec 25, 2024',
      imageIcon: '🌠',
      isFeatured: true,
    ),
    Event(
      id: '2',
      title: 'Open Skate Night',
      description: 'Free skate session with live DJ and lights',
      date: 'Every Friday',
      imageIcon: '⛸️',
      isFeatured: true,
    ),
    Event(
      id: '3',
      title: 'New Year Ice Gala',
      description: 'Ring in the new year on ice!',
      date: 'Dec 31, 2024',
      imageIcon: '🎉',
      isFeatured: true,
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

  void _onNavTap(int index) {
    // Check if user is trying to access restricted tabs
    if (!context.read<CookieRequest>().loggedIn && (index == 1 || index == 2)) {
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
          // Mock Google sign-in - in real app, handle actual login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google sign-in not implemented yet.'),
              backgroundColor: AppColors.frostPrimary,
              duration: Duration(seconds: 2),
            ),
          );
        },
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

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeEventsScreen(
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
        return CommunityScreen(
          posts: _communityPosts,
          isLoggedIn: context.read<CookieRequest>().loggedIn,
          onActionRequired: _showAuthModal,
        );
      case 4:
        return ProfileScreen(
          isLoggedIn: context.read<CookieRequest>().loggedIn,
          onSignOut: () async {
            final request = context.read<CookieRequest>();
            await request.logout("http://127.0.0.1:8000/auth_mob/logout/");
            setState(() {
              _selectedIndex = 0;
            });
          },
          onSignIn: _showAuthModal,
        );
      default:
        return const HomeEventsScreen(
          featuredEvents: [],
          packages: [],
          onActionRequired: null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
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
