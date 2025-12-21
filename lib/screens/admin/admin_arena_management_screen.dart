import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminArenaManagementScreen extends StatefulWidget {
  const AdminArenaManagementScreen({super.key});

  @override
  State<AdminArenaManagementScreen> createState() =>
      _AdminArenaManagementScreenState();
}

class _AdminArenaManagementScreenState
    extends State<AdminArenaManagementScreen> {
  List<Map<String, dynamic>> _arenas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArenas();
  }

  Future<void> _fetchArenas() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/booking/api/arenas/',
      );

      if (mounted && response != null && response['status'] == true) {
        setState(() {
          _arenas = List<Map<String, dynamic>>.from(response['arenas']);
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
        ).showSnackBar(const SnackBar(content: Text('Failed to load arenas')));
      }
    }
  }

  Future<void> _createArena() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final capacityController = TextEditingController();
    final locationController = TextEditingController();
    final imgUrlController = TextEditingController();
    final openingHoursController = TextEditingController();
    final googleMapsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Arena'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description *'),
                maxLines: 3,
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity *'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location *'),
              ),
              TextField(
                controller: imgUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: openingHoursController,
                decoration: const InputDecoration(
                  labelText: 'Opening Hours Text',
                ),
              ),
              TextField(
                controller: googleMapsController,
                decoration: const InputDecoration(labelText: 'Google Maps URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  capacityController.text.isEmpty ||
                  locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                  ),
                );
                return;
              }

              final request = context.read<CookieRequest>();
              try {
                final response = await request.post(
                  'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/arenas/create/',
                  {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'capacity': int.tryParse(capacityController.text) ?? 0,
                    'location': locationController.text,
                    'img_url': imgUrlController.text,
                    'opening_hours_text': openingHoursController.text,
                    'google_maps_url': googleMapsController.text,
                  },
                );

                if (response != null && response['status'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arena created successfully')),
                  );
                  Navigator.of(context).pop();
                  _fetchArenas();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create arena')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateArena(Map<String, dynamic> arena) async {
    final nameController = TextEditingController(text: arena['name']);
    final descriptionController = TextEditingController(
      text: arena['description'],
    );
    final capacityController = TextEditingController(
      text: arena['capacity'].toString(),
    );
    final locationController = TextEditingController(text: arena['location']);
    final imgUrlController = TextEditingController(
      text: arena['img_url'] ?? '',
    );
    final openingHoursController = TextEditingController(
      text: arena['opening_hours_text'] ?? '',
    );
    final googleMapsController = TextEditingController(
      text: arena['google_maps_url'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Arena: ${arena['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description *'),
                maxLines: 3,
              ),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity *'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location *'),
              ),
              TextField(
                controller: imgUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: openingHoursController,
                decoration: const InputDecoration(
                  labelText: 'Opening Hours Text',
                ),
              ),
              TextField(
                controller: googleMapsController,
                decoration: const InputDecoration(labelText: 'Google Maps URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  capacityController.text.isEmpty ||
                  locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                  ),
                );
                return;
              }

              final request = context.read<CookieRequest>();
              try {
                final response = await request.post(
                  'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/arenas/${arena['id']}/',
                  {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'capacity': int.tryParse(capacityController.text) ?? 0,
                    'location': locationController.text,
                    'img_url': imgUrlController.text,
                    'opening_hours_text': openingHoursController.text,
                    'google_maps_url': googleMapsController.text,
                  },
                );

                if (response != null && response['status'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arena updated successfully')),
                  );
                  Navigator.of(context).pop();
                  _fetchArenas();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update arena')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArena(String arenaId, String arenaName) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/booking/api/delete/$arenaId/',
        {}, // Empty body for delete
      );

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arena deleted successfully')),
        );
        _fetchArenas();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete arena')));
    }
  }

  void _showDeleteConfirmation(String arenaId, String arenaName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Arena'),
        content: Text(
          'Are you sure you want to delete arena "$arenaName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteArena(arenaId, arenaName);
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
        title: const Text('Arena Management'),
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
          IconButton(icon: const Icon(Icons.add), onPressed: _createArena),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchArenas),
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
            : _arenas.isEmpty
            ? const Center(
                child: Text(
                  'No arenas found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _arenas.length,
                itemBuilder: (context, index) {
                  final arena = _arenas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.business, color: Colors.white),
                      ),
                      title: Text(
                        arena['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(arena['location']),
                          Text('Capacity: ${arena['capacity']}'),
                          Text(
                            arena['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _updateArena(arena);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(arena['id'], arena['name']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
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
}
