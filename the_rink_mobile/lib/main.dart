import 'package:flutter/material.dart';

void main() {
  runApp(const TheRinkApp());
}

// ============================================================================
// MODELS
// ============================================================================

class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String imageIcon;
  final bool isFeatured;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageIcon,
    this.isFeatured = false,
  });
}

class Package {
  final String id;
  final String title;
  final String description;
  final double price;
  final String duration;

  Package({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
  });
}

class CommunityPost {
  final String id;
  final String username;
  final String content;
  final int likes;
  final String timeAgo;
  final String avatarColor;

  CommunityPost({
    required this.id,
    required this.username,
    required this.content,
    required this.likes,
    required this.timeAgo,
    required this.avatarColor,
  });
}

// ============================================================================
// MAIN APP
// ============================================================================

class TheRinkApp extends StatelessWidget {
  const TheRinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Rink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B46C1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6B46C1),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ============================================================================
// MAIN NAVIGATION SCREEN (State Manager)
// ============================================================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

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
      content: 'Just nailed my first axel jump! 🎉 The coaching here is incredible. Thank you Coach Maria!',
      likes: 142,
      timeAgo: '2h ago',
      avatarColor: 'blue',
    ),
    CommunityPost(
      id: '2',
      username: 'hockey_dad_mike',
      content: 'My son\'s team won their first game today at The Rink! Such an amazing facility. Highly recommend for youth hockey.',
      likes: 89,
      timeAgo: '5h ago',
      avatarColor: 'red',
    ),
    CommunityPost(
      id: '3',
      username: 'figure_skater_sara',
      content: 'The new LED floor lighting during evening sessions is absolutely stunning! Perfect for practice videos 📹',
      likes: 203,
      timeAgo: '1d ago',
      avatarColor: 'purple',
    ),
    CommunityPost(
      id: '4',
      username: 'first_timer_joe',
      content: 'Took my first skating lesson today. Fell about 20 times but had a blast! Staff was super patient and helpful.',
      likes: 67,
      timeAgo: '2d ago',
      avatarColor: 'green',
    ),
  ];

  void _onNavTap(int index) {
    // Check if user is trying to access restricted tabs
    if (!_isLoggedIn && (index == 1 || index == 2)) {
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
          setState(() {
            _isLoggedIn = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back! You\'re now signed in.'),
              backgroundColor: Color(0xFF6B46C1),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onUsernamePasswordSignIn: () {
          Navigator.pop(context);
          setState(() {
            _isLoggedIn = true;
          });
        },
        onContinueAsGuest: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleActionButton({required String action}) {
    if (!_isLoggedIn) {
      _showAuthModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action action confirmed!'),
          backgroundColor: const Color(0xFF6B46C1),
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
        return const ArenaBookingScreen();
      case 2:
        return const GearRentalScreen();
      case 3:
        return CommunityScreen(
          posts: _communityPosts,
          isLoggedIn: _isLoggedIn,
          onActionRequired: _showAuthModal,
        );
      case 4:
        return ProfileScreen(
          isLoggedIn: _isLoggedIn,
          onSignOut: () {
            setState(() {
              _isLoggedIn = false;
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

// ============================================================================
// AUTH MODAL
// ============================================================================

class AuthModalSheet extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onUsernamePasswordSignIn;
  final VoidCallback onContinueAsGuest;

  const AuthModalSheet({
    super.key,
    required this.onGoogleSignIn,
    required this.onUsernamePasswordSignIn,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(
            Icons.ice_skating_rounded,
            size: 64,
            color: Color(0xFF6B46C1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in to join the fun!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Access exclusive features, book ice time, and connect with the community',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGoogleSignIn,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text('Continue with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B46C1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUsernamePasswordSignIn,
              icon: const Icon(Icons.email_rounded),
              label: const Text('Username / Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B46C1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF6B46C1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onContinueAsGuest,
            child: const Text(
              'Continue as Guest',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// ============================================================================
// MODULE 4: HOME/EVENTS SCREEN
// ============================================================================

class HomeEventsScreen extends StatelessWidget {
  final List<Event> featuredEvents;
  final List<Package> packages;
  final Function({required String action})? onActionRequired;

  const HomeEventsScreen({
    super.key,
    required this.featuredEvents,
    required this.packages,
    this.onActionRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Rink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Section
            if (featuredEvents.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Featured Events',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: featuredEvents.length,
                  itemBuilder: (context, index) {
                    final event = featuredEvents[index];
                    return _FeaturedEventCard(
                      event: event,
                      onRSVP: () {
                        if (onActionRequired != null) {
                          onActionRequired!(action: 'RSVP for ${event.title}');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Packages Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Packages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return _PackageCard(
                  package: package,
                  onBook: () {
                    if (onActionRequired != null) {
                      onActionRequired!(action: 'Book ${package.title}');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onRSVP;

  const _FeaturedEventCard({
    required this.event,
    required this.onRSVP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  event.imageIcon,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onRSVP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B46C1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('RSVP', style: TextStyle(fontSize: 14)),
                    ),
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

class _PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onBook;

  const _PackageCard({
    required this.package,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Color(0xFF6B46C1),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${package.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B46C1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        package.duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B46C1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Book'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODULE 3: ARENA BOOKING SCREEN
// ============================================================================

class ArenaBookingScreen extends StatelessWidget {
  const ArenaBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arena Booking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ice_skating_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Book Your Ice Time',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a time slot and reserve the rink',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODULE 2: GEAR RENTAL SCREEN
// ============================================================================

class GearRentalScreen extends StatelessWidget {
  const GearRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Rental'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_hockey_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Rent Your Equipment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse skates, protective gear, and more',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODULE 5: COMMUNITY SCREEN
// ============================================================================

class CommunityScreen extends StatelessWidget {
  final List<CommunityPost> posts;
  final bool isLoggedIn;
  final VoidCallback onActionRequired;

  const CommunityScreen({
    super.key,
    required this.posts,
    required this.isLoggedIn,
    required this.onActionRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _CommunityPostCard(
            post: post,
            isLoggedIn: isLoggedIn,
            onLike: () {
              if (!isLoggedIn) {
                onActionRequired();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post liked!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isLoggedIn) {
            onActionRequired();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create post feature coming soon!')),
            );
          }
        },
        backgroundColor: const Color(0xFF6B46C1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _CommunityPostCard extends StatefulWidget {
  final CommunityPost post;
  final bool isLoggedIn;
  final VoidCallback onLike;

  const _CommunityPostCard({
    required this.post,
    required this.isLoggedIn,
    required this.onLike,
  });

  @override
  State<_CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<_CommunityPostCard> {
  bool _isLiked = false;

  Color _getAvatarColor() {
    switch (widget.post.avatarColor) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'purple':
        return const Color(0xFF6B46C1);
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getAvatarColor(),
                  child: Text(
                    widget.post.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.post.timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    widget.onLike();
                    if (widget.isLoggedIn) {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                    }
                  },
                ),
                Text(
                  '${widget.post.likes + (_isLiked ? 1 : 0)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: widget.onLike,
                ),
                Text(
                  'Comment',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODULE 1: PROFILE SCREEN
// ============================================================================

class ProfileScreen extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;

  const ProfileScreen({
    super.key,
    required this.isLoggedIn,
    required this.onSignOut,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoggedIn ? _buildLoggedInView(context) : _buildGuestView(context),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF6B46C1),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Skater',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'john.skater@email.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileMenuItem(
            icon: Icons.history,
            title: 'Booking History',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.payment,
            title: 'Payment Methods',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to The Rink',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to access your profile, bookings, and more',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B46C1)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}