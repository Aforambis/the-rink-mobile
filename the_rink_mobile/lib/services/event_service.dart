import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';

class EventService {
  final String baseUrl = "https://angga-tri41-therink.pbp.cs.ui.ac.id";

  Future<List<Event>> fetchEvents(CookieRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return [
      Event(
        id: 1,
        name: 'Winter Wonderland Gala',
        description: 'Dansa di atas es dengan lampu aurora.',
        date: '2024-12-24',
        time: '19:00',
        location: 'Grand Ice Hall',
        price: 150000,
        category: 'Party',
        imageUrl:
            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=800',
        participantCount: 85,
        maxParticipants: 100,
        isRegistered: false,
      ),
      Event(
        id: 2,
        name: 'Pro Hockey: Bears vs Lions',
        description: 'Pertandingan sengit liga nasional.',
        date: '2024-12-28',
        time: '18:30',
        location: 'Main Stadium',
        price: 75000,
        category: 'Competition',
        imageUrl:
            'https://images.unsplash.com/photo-1580748141549-71748dbe0bdc?q=80&w=800',
        participantCount: 150,
        maxParticipants: 500,
        isRegistered: false,
      ),
      Event(
        id: 3,
        name: 'Intro to Figure Skating',
        description: 'Kelas pemula khusus dewasa.',
        date: '2024-12-26',
        time: '10:00',
        location: 'Rink B',
        price: 200000,
        category: 'Workshop',
        imageUrl:
            'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?q=80&w=800',
        participantCount: 12,
        maxParticipants: 15,
        isRegistered: true,
      ),
      Event(
        id: 4,
        name: 'Kids Frozen Adventure',
        description: 'Sesi khusus anak-anak (3-10 tahun).',
        date: '2024-12-30',
        time: '09:00',
        location: 'Kids Area',
        price: 50000,
        category: 'Social',
        imageUrl:
            'https://images.unsplash.com/photo-1612024782955-49fae79e441a?q=80&w=800',
        participantCount: 20,
        maxParticipants: 30,
        isRegistered: false,
      ),
      Event(
        id: 5,
        name: 'Late Night Disco Skate',
        description: 'Skating malam hari dengan DJ.',
        date: '2024-12-31',
        time: '23:00',
        location: 'Rink A',
        price: 100000,
        category: 'Party',
        imageUrl:
            'https://images.unsplash.com/photo-1545128485-c400e7702796?q=80&w=800',
        participantCount: 50,
        maxParticipants: 100,
        isRegistered: false,
      ),
      Event(
        id: 6,
        name: 'Speed Skating Qualifier',
        description: 'Kualifikasi atlet daerah.',
        date: '2025-01-02',
        time: '08:00',
        location: 'Oval Track',
        price: 25000,
        category: 'Competition',
        imageUrl:
            'https://images.unsplash.com/photo-1614868019074-97858c253d82?q=80&w=800',
        participantCount: 10,
        maxParticipants: 50,
        isRegistered: false,
      ),
    ];
  }

  Future<Map<String, dynamic>> fetchEventDetail(
    CookieRequest request,
    int eventId,
  ) async {
    // TODO: Uncomment ini ketika backend sudah siap & superuser ready
    /*
    try {
      final response = await request.get(
        '$baseUrl/events/api/detail/$eventId/',
      );
      
      // Backend response structure sesuai views.py:
      // {
      //   'event': {...},
      //   'recommended_events': [...]
      // }
      
      return response;
    } catch (e) {
      print('Error fetching event detail: $e');
      return {};
    }
    */

    // DUMMY DATA (sementara)
    await Future.delayed(const Duration(milliseconds: 500));

    final allEvents = await fetchEvents(request);
    final currentEvent = allEvents.firstWhere((e) => e.id == eventId);

    // Generate recommendations: same category, exclude current
    final recommendations = allEvents
        .where((e) => e.category == currentEvent.category && e.id != eventId)
        .take(3)
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'description': e.description,
            'date': e.date,
            'time': e.time,
            'location': e.location,
            'price': e.price,
            'category': e.category,
            'image_url': e.imageUrl,
            'participant_count': e.participantCount,
            'max_participants': e.maxParticipants,
            'is_registered': e.isRegistered,
          },
        )
        .toList();

    // Match backend response structure
    return {
      'event': {
        'id': currentEvent.id,
        'name': currentEvent.name,
        'description': currentEvent.description,
        'date': currentEvent.date,
        'time': currentEvent.time,
        'location': currentEvent.location,
        'price': currentEvent.price,
        'category': currentEvent.category,
        'image_url': currentEvent.imageUrl,
        'participant_count': currentEvent.participantCount,
        'max_participants': currentEvent.maxParticipants,
        'is_registered': currentEvent.isRegistered,
      },
      'recommended_events': recommendations,
    };
  }

  Future<Map<String, dynamic>> joinEvent(
    CookieRequest request,
    int eventId,
  ) async {
    final response = await request.post(
      '$baseUrl/events/api/join/$eventId/',
      {},
    );
    return response;
  }
}
