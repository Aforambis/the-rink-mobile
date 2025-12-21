import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'admin_user_management_screen.dart';
import 'admin_arena_management_screen.dart';
import 'admin_gear_management_screen.dart';
import 'admin_event_management_screen.dart';
import 'admin_forum_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/stats/',
      );

      if (mounted && response != null) {
        setState(() {
          _stats = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load admin stats')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _buildDashboard(),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Welcome, Superuser!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'You have full control over the system.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // Management Cards Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildManagementCard(
                  icon: Icons.sports_hockey,
                  title: 'Rental Gear',
                  description:
                      'Manage rental gear items, categories, and inventory.',
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.cyan],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminGearManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.calendar_today,
                  title: 'Events',
                  description: 'Manage events, registrations, and categories.',
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminEventManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.forum,
                  title: 'Forum',
                  description: 'Manage forum posts, replies, and users.',
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminForumManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.business,
                  title: 'Booking Arena',
                  description: 'Manage arenas, slots, and bookings.',
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.red],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminArenaManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.people,
                  title: 'Users',
                  description: 'Manage user accounts, profiles, and types.',
                  gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.purple],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminUserManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.logout,
                  title: 'Logout',
                  description: 'Logout from admin dashboard.',
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.pink],
                  ),
                  onTap: () async {
                    // Call logout API
                    final request = context.read<CookieRequest>();
                    try {
                      await request.post(
                        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/logout/',
                        {},
                      );
                    } catch (e) {
                      // Continue with logout even if API call fails
                    }

                    // Navigate to login screen (assuming login screen is at root)
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', // Assuming login is at root
                        (Route<dynamic> route) => false, // Remove all routes
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Quick Stats Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      icon: Icons.sports_hockey,
                      label: 'Gear Items',
                      value: _stats?['gear_count']?.toString() ?? '0',
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.calendar_today,
                      label: 'Active Events',
                      value: _stats?['event_count']?.toString() ?? '0',
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      icon: Icons.forum,
                      label: 'Forum Posts',
                      value: _stats?['post_count']?.toString() ?? '0',
                      color: Colors.purple,
                    ),
                    _buildStatCard(
                      icon: Icons.people,
                      label: 'Total Users',
                      value: _stats?['user_count']?.toString() ?? '0',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String description,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
