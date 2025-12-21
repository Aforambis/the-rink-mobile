import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminGearManagementScreen extends StatefulWidget {
  const AdminGearManagementScreen({super.key});

  @override
  State<AdminGearManagementScreen> createState() =>
      _AdminGearManagementScreenState();
}

class _AdminGearManagementScreenState extends State<AdminGearManagementScreen> {
  List<Map<String, dynamic>> _gears = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGears();
  }

  Future<void> _fetchGears() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/gears/',
      );

      if (mounted && response != null && response['status'] == true) {
        setState(() {
          _gears = List<Map<String, dynamic>>.from(response['gears']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load gears')));
      }
    }
  }

  Future<void> _deleteGear(int gearId, String gearName) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/gears/$gearId/delete/',
        {}, // Empty body for delete
      );

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gear deleted successfully')),
        );
        _fetchGears();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete gear')));
    }
  }

  void _showDeleteConfirmation(int gearId, String gearName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gear'),
        content: Text(
          'Are you sure you want to delete gear "$gearName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteGear(gearId, gearName);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Management'),
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
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchGears),
        ],
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
            : _gears.isEmpty
            ? const Center(
                child: Text(
                  'No gears found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _gears.length,
                itemBuilder: (context, index) {
                  final gear = _gears[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image:
                              gear['image_url'] != null &&
                                  gear['image_url'].isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(gear['image_url']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color:
                              gear['image_url'] == null ||
                                  gear['image_url'].isEmpty
                              ? _getCategoryColor(gear['category'])
                              : null,
                        ),
                        child:
                            (gear['image_url'] == null ||
                                gear['image_url'].isEmpty)
                            ? Icon(
                                _getCategoryIcon(gear['category']),
                                color: Colors.white,
                              )
                            : null,
                      ),
                      title: Text(
                        gear['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seller: ${gear['seller_username']}'),
                          Text('Category: ${gear['category']}'),
                          Text('Price: Rp ${gear['price_per_day']} per day'),
                          Text('Stock: ${gear['stock']}'),
                          if (gear['is_featured'] == true) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Featured',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(gear['id'], gear['name']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hockey':
        return Colors.blue;
      case 'curling':
        return Colors.purple;
      case 'ice_skating':
        return Colors.cyan;
      case 'apparel':
        return Colors.pink;
      case 'accessories':
        return Colors.green;
      case 'protective_gear':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hockey':
        return Icons.sports_hockey;
      case 'curling':
        return Icons.sports_baseball; // Closest available icon
      case 'ice_skating':
        return Icons.ice_skating;
      case 'apparel':
        return Icons.checkroom;
      case 'accessories':
        return Icons.watch;
      case 'protective_gear':
        return Icons.security;
      default:
        return Icons.sports;
    }
  }
}
