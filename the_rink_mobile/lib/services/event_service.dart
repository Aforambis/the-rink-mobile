import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';

class EventService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator
  final String baseUrl = "https://angga-tri41-therink.pbp.cs.ui.ac.id/events/api";
  Future<List<Event>> fetchEvents(CookieRequest request) async {
    final response = await request.get('$baseUrl/list/');

    List<Event> listEvents = [];
    for (var d in response) {
      if (d != null) {
        listEvents.add(Event.fromJson(d));
      }
    }
    return listEvents;
  }

  // 3. PERTAHANKAN FITUR BARU KAMU (Fetch Detail)
  // Note: Karena fetchEvents di atas sekarang pakai API,
  // fungsi ini otomatis akan memfilter data ASLI dari server, bukan dummy lagi.
  Future<Map<String, dynamic>> fetchEventDetail(
    CookieRequest request,
    int eventId,
  ) async {
    // Kita panggil fetchEvents (yang sekarang sudah Real API)
    final allEvents = await fetchEvents(request);

    // Logic filter lokal kamu tetap aman digunakan
    try {
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
    } catch (e) {
      // Handle jika event ID tidak ditemukan di list API
      print("Event not found: $e");
      return {};
    }
  }

  // 4. GUNAKAN JOIN EVENT DARI REMOTE (URL path disesuaikan dengan baseUrl baru)
  Future<Map<String, dynamic>> joinEvent(
    CookieRequest request,
    int eventId,
  ) async {
    final response = await request.post('$baseUrl/join/$eventId/', {});
    return response;
  }
}
