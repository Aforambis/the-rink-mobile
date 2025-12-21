import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminEventManagementScreen extends StatefulWidget {
  const AdminEventManagementScreen({super.key});

  @override
  State<AdminEventManagementScreen> createState() =>
      _AdminEventManagementScreenState();
}

class _AdminEventManagementScreenState
    extends State<AdminEventManagementScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/events/',
      );

      if (mounted && response != null && response['status'] == true) {
        setState(() {
          _events = List<Map<String, dynamic>>.from(response['events']);
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
        ).showSnackBar(const SnackBar(content: Text('Failed to load events')));
      }
    }
  }

  Future<void> _createEvent() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final organizerController = TextEditingController();
    final instructorController = TextEditingController();
    final requirementsController = TextEditingController();
    final priceController = TextEditingController();
    final maxParticipantsController = TextEditingController();

    String selectedCategory = 'social';
    String selectedLevel = 'all';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay selectedEndTime = const TimeOfDay(hour: 17, minute: 0);
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Event'),
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
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: const [
                  DropdownMenuItem(
                    value: 'competition',
                    child: Text('Competition'),
                  ),
                  DropdownMenuItem(value: 'workshop', child: Text('Workshop')),
                  DropdownMenuItem(
                    value: 'social',
                    child: Text('Social Event'),
                  ),
                  DropdownMenuItem(
                    value: 'training',
                    child: Text('Training Session'),
                  ),
                ],
                onChanged: (value) => selectedCategory = value!,
              ),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: const InputDecoration(labelText: 'Level *'),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                    value: 'intermediate',
                    child: Text('Intermediate'),
                  ),
                  DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  DropdownMenuItem(value: 'all', child: Text('All Levels')),
                ],
                onChanged: (value) => selectedLevel = value!,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location *'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price *'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxParticipantsController,
                decoration: const InputDecoration(
                  labelText: 'Max Participants *',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: organizerController,
                decoration: const InputDecoration(labelText: 'Organizer'),
              ),
              TextField(
                controller: instructorController,
                decoration: const InputDecoration(labelText: 'Instructor'),
              ),
              TextField(
                controller: requirementsController,
                decoration: const InputDecoration(labelText: 'Requirements'),
                maxLines: 2,
              ),
              // Date and Time pickers would be added here
              SwitchListTile(
                title: const Text('Active'),
                value: isActive,
                onChanged: (value) => isActive = value,
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
                  locationController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  maxParticipantsController.text.isEmpty) {
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
                  'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/events/create/',
                  {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'category': selectedCategory,
                    'level': selectedLevel,
                    'location': locationController.text,
                    'price': double.tryParse(priceController.text) ?? 0,
                    'max_participants':
                        int.tryParse(maxParticipantsController.text) ?? 30,
                    'organizer': organizerController.text,
                    'instructor': instructorController.text,
                    'requirements': requirementsController.text,
                    'date': selectedDate.toIso8601String().split('T')[0],
                    'start_time':
                        '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                    'end_time':
                        '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}',
                    'is_active': isActive,
                  },
                );

                if (response != null && response['status'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event created successfully')),
                  );
                  Navigator.of(context).pop();
                  _fetchEvents();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create event')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEvent(Map<String, dynamic> event) async {
    // Similar to create but with pre-filled values
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event editing not implemented yet')),
    );
  }

  Future<void> _deleteEvent(int eventId, String eventName) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/auth_mob/admin/events/$eventId/delete/',
        {}, // Empty body for delete
      );

      if (response != null && response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
        _fetchEvents();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete event')));
    }
  }

  void _showDeleteConfirmation(int eventId, String eventName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete event "$eventName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteEvent(eventId, eventName);
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
        title: const Text('Event Management'),
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
          IconButton(icon: const Icon(Icons.add), onPressed: _createEvent),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchEvents),
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
            : _events.isEmpty
            ? const Center(
                child: Text(
                  'No events found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(event['category']),
                        child: Icon(
                          _getCategoryIcon(event['category']),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        event['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${event['date']} at ${event['location']}'),
                          Text('${event['start_time']} - ${event['end_time']}'),
                          Text(
                            'Category: ${event['category']} | Level: ${event['level']}',
                          ),
                          Text(
                            'Price: Rp ${event['price']} | Max: ${event['max_participants']}',
                          ),
                          Text('Registered: ${event['current_participants']}'),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: event['is_active'] == true
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event['is_active'] == true
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: event['is_active'] == true
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _updateEvent(event);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(event['id'], event['name']);
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'competition':
        return Colors.red;
      case 'workshop':
        return Colors.blue;
      case 'social':
        return Colors.green;
      case 'training':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'competition':
        return Icons.emoji_events;
      case 'workshop':
        return Icons.build;
      case 'social':
        return Icons.people;
      case 'training':
        return Icons.school;
      default:
        return Icons.event;
    }
  }
}
