import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import 'event_detail_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  // Gunakan 127.0.0.1 karena kamu pakai iOS Simulator
  final String baseUrl = "https://angga-tri41-therink.pbp.cs.ui.ac.id";

  Future<List<Event>> fetchEvents(CookieRequest request) async {
    final response = await request.get('$baseUrl/events/api/list/');

    List<Event> listEvents = [];
    for (var d in response) {
      if (d != null) {
        // Fix URL image jika relative (sama seperti di EventService)
        if (d['image_url'] != null && d['image_url'].toString().isNotEmpty) {
          if (!d['image_url'].toString().startsWith('http')) {
            d['image_url'] = "$baseUrl${d['image_url']}";
          }
        }
        listEvents.add(Event.fromJson(d));
      }
    }
    return listEvents;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text("All Events")),
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      event.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${event.date} at ${event.time}"),
                        Text(
                          "Participants: ${event.participantCount} / ${event.maxParticipants}",
                          style: TextStyle(
                            color:
                                event.participantCount >= event.maxParticipants
                                ? Colors.red
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // PERBAIKAN DI SINI:
                        // Kita pass object 'event', bukan 'eventId'
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailPage(event: event),
                          ),
                        );
                      },
                      child: const Text("See Details"),
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
