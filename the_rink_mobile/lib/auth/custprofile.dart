import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_menu_item.dart';
import '../theme/app_theme.dart';
import '../screens/my_events_screen.dart'; // Pastikan import ini ada

class ProfileScreen extends StatefulWidget {
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _fetchUserData();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchUserData() async {
    final request = context.read<CookieRequest>();
    try {
      // Gunakan 127.0.0.1 untuk iOS Simulator agar konsisten
      final response = await request.get(
        'http://127.0.0.1:8000/auth_mob/user/',
      );
      if (response != null && mounted) {
        setState(() {
          _userData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        child: widget.isLoggedIn
            ? _buildLoggedInView(context)
            : _buildGuestView(context),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final username = _userData?['username'] ?? 'User';
    final email = _userData?['email'] ?? 'No email';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Avatar Section
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.frostPrimary, AppColors.frostSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppColors.softDropShadow,
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(fontSize: 14, color: AppColors.mutedText),
          ),
          const SizedBox(height: 24),

          // --- MENU ITEMS ---

          // 1. My Events (Menu Baru)
          ProfileMenuItem(
            icon: Icons.calendar_today,
            title: 'My Events',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyEventsScreen()),
              );
            },
          ),

          // 2. Menu lainnya
          ProfileMenuItem(
            icon: Icons.history,
            title: 'Booking History',
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: Icons.payment,
            title: 'Payment Methods',
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onSignOut,
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.frostedGlass,
                boxShadow: AppColors.softDropShadow,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 60,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to The Rink',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to access your profile, bookings, and more',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.mutedText),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onSignIn,
                child: const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
