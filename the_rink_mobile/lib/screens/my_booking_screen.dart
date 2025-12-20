import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/booking_arena.dart';
// import '../theme/app_theme.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<Booking>> _fetchHistory(CookieRequest request) async {
    final response = await request.get('$baseUrl/booking/api/my-history/');
    
    // Debugging print
    // print("Response History: $response");

    List<Booking> list = [];
    for (var d in response) {
      if (d != null) {
        list.add(Booking.fromHistoryJson(d));
      }
    }
    return list;
  }

  Future<void> _cancelBooking(String bookingId, CookieRequest request) async {
    try {
      // Pake request.postJson karena endpoint Django lu expect JSON body
      final response = await request.postJson(
        '$baseUrl/booking/api/booking/cancel/', 
        jsonEncode({"booking_id": bookingId})
      );
      
      if (response['status'] == true) {
         setState(() {}); // Refresh UI
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking dibatalkan")));
      } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        // backgroundColor: AppColors.frostPrimary,
      ),
      body: FutureBuilder(
        future: _fetchHistory(request),
        builder: (context, AsyncSnapshot<List<Booking>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada bookingan nih. Gas main!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return _buildBookingCard(booking, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, CookieRequest request) {
    Color statusColor = Colors.green;
    String statusText = booking.status.name.capitalize();
    
    // Cek Completed (Tanggal lewat)
    bool isPast = false;
    if (booking.date != null) {
      isPast = booking.date!.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    }

    if (booking.status == BookingStatus.cancelled) {
      statusColor = Colors.red;
    } else if (isPast) {
      statusColor = Colors.grey;
      statusText = "Completed";
    } else {
      statusColor = Colors.blue; // AppColors.frostPrimary
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.arenaName ?? "Unknown Arena",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      booking.date != null ? DateFormat('dd MMM yyyy').format(booking.date!) : "-",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${booking.startHour}:00 - ${booking.startHour+1}:00"),
                const Spacer(),
                const Icon(Icons.sports_hockey, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(booking.activity?.name.capitalize() ?? "-"), 
              ],
            ),

            // Tombol Cancel
            if (booking.status == BookingStatus.booked && !isPast && booking.id != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelBooking(booking.id!, request),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, 
                    side: const BorderSide(color: Colors.red)
                  ),
                  child: const Text("Batalkan Booking"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}