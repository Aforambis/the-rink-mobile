import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/booking_arena.dart';
import '../theme/app_theme.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  Future<List<Booking>> _fetchHistory(CookieRequest request) async {
    final response = await request.get(
      'https://angga-tri41-therink.pbp.cs.ui.ac.id/booking_arena/api/bookings/my_history/',
    );
    List<Booking> list = [];
    for (var d in response) {
      if (d != null) list.add(Booking.fromJson(d));
    }
    return list;
  }

  Future<void> _cancelBooking(String bookingId, CookieRequest request) async {
    // Panggil API Cancel
    try {
      await request.post(
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/booking_arena/api/bookings/$bookingId/cancel/',
        {},
      );
      setState(() {}); // Refresh halaman
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking dibatalkan")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membatalkan")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: AppColors.frostPrimary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _fetchHistory(request),
        builder: (context, AsyncSnapshot<List<Booking>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada bookingan nih. Gas main!"),
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
    // Logic warna status
    Color statusColor = Colors.green;
    String statusText = booking.status.name
        .capitalize(); // Pake extension yg ada di model

    // Logic Completed: Kalo tanggal udah lewat dari hari ini
    bool isPast = booking.date.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (booking.status == BookingStatus.cancelled) {
      statusColor = Colors.red;
    } else if (isPast) {
      statusColor = Colors.grey;
      statusText = "Completed";
    } else {
      statusColor = AppColors.frostPrimary;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.date.toString().split(' ')[0], // YYYY-MM-DD
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.watch_later_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text("${booking.startHour}:00 - ${booking.startHour + 1}:00"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.sports_hockey, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                // Tampilkan activity yang diformat
                Text(booking.activity?.name ?? "-"),
              ],
            ),

            // Tombol Cancel cuma muncul kalo status Booked & belum lewat
            if (booking.status == BookingStatus.booked && !isPast) ...[
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelBooking(booking.id, request),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("Batalkan Booking"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
