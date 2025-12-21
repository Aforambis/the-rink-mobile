import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:the_rink_mobile/models/event.dart'; // Correct import

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  Future<List<Event>> fetchEvents(CookieRequest request) async {
    final response = await request.get('https://angga-tri41-therink.pbp.cs.ui.ac.id/events/api/list/');
    
    List<Event> listEvents = [];
    for (var d in response) {
      if (d != null) {
        listEvents.add(Event.fromJson(d));
      }
    }
    return listEvents;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: FutureBuilder<List<Event>>(
        future: fetchEvents(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events available"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${event.date} at ${event.time}"),
                        Text(
                          "Participants: ${event.participantCount} / ${event.maxParticipants}",
                          style: TextStyle(
                            color: event.participantCount >= event.maxParticipants 
                                ? Colors.red 
                                : Colors.grey[600]
                          ),
                        ),
                      ],
                    ),
                    trailing: event.isRegistered 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 30) // Registered
                        : ElevatedButton( // Join Button
                            onPressed: event.participantCount >= event.maxParticipants 
                                ? null // Disable if full
                                : () {
                                    // Handle join logic here
                                  },
                            child: const Text("Join"),
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}