import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';

class EventService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator
  final String baseUrl = "http://10.0.2.2:8000/events/api";

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

  Future<Map<String, dynamic>> joinEvent(CookieRequest request, int eventId) async {
    final response = await request.post('$baseUrl/join/$eventId/', {});
    return response;
  }
}