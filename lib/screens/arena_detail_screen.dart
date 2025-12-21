import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/booking_arena.dart';
import '../theme/app_theme.dart';

class ArenaDetailScreen extends StatefulWidget {
  final Arena arena;
  final VoidCallback? onActionRequired; // Callback for login requirement

  const ArenaDetailScreen({
    super.key,
    required this.arena,
    this.onActionRequired,
  });

  @override
  State<ArenaDetailScreen> createState() => _ArenaDetailScreenState();
}

class _ArenaDetailScreenState extends State<ArenaDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Booking> _existingBookings = [];
  bool _isLoading = true;

  // Jam operasional (Hardcode dulu atau ambil dari widget.arena.openingHoursText kalo mau diparsing)
  final int openHour = 10;
  final int closeHour = 22;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  // --- 1. FUNGSI FETCH DATA BOOKING ---
  Future<void> _fetchBookings() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    // Format tanggal jadi YYYY-MM-DD buat filter API
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final String url =
        'https://angga-tri41-therink.pbp.cs.ui.ac.id/booking/api/bookings/?arena=${widget.arena.id}&date=$dateStr';

    try {
      final response = await request.get(url);
      // Response udah otomatis decoded json sama CookieRequest
      List<Booking> listData = [];
      for (var d in response) {
        if (d != null) {
          listData.add(Booking.fromJson(d));
        }
      }
      setState(() {
        _existingBookings = listData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 2. FUNGSI POST BOOKING ---
  Future<void> _submitBooking(int hour, BookingActivity activity) async {
    final request = context.read<CookieRequest>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final response = await request.postJson(
      "https://angga-tri41-therink.pbp.cs.ui.ac.id/booking/api/booking/create/",
      jsonEncode({
        "arena_id": widget.arena.id,
        "date": dateStr,
        "start_hour": hour,
        "activity": activity == BookingActivity.iceSkating
            ? "ice_skating"
            : activity == BookingActivity.iceHockey
            ? "ice_hockey"
            : "curling",
      }),
    );

    if (response['id'] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking Berhasil!")));
      Navigator.pop(context);
      _fetchBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal: ${response['detail'] ?? 'Unknown error'}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arena.name),
        backgroundColor: AppColors.frostPrimary, // Sesuaikan warna
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Gambar Arena
          if (widget.arena.imgUrl != null && widget.arena.imgUrl!.isNotEmpty)
            Image.network(
              widget.arena.imgUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 200, color: Colors.grey),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.arena.location,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(widget.arena.description),
                const Divider(height: 32),

                // --- DATE PICKER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Jadwal: ${DateFormat('EEEE, d MMM y').format(_selectedDate)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.frostPrimary,
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                          _fetchBookings(); // Fetch ulang pas ganti tanggal
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- SLOT LIST ---
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ...List.generate(closeHour - openHour, (index) {
                    final int hour = openHour + index;
                    return _buildSlotCard(hour);
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(int hour) {
    // Cek apakah ada booking di jam ini
    Booking? currentBooking;
    try {
      currentBooking = _existingBookings.firstWhere(
        (b) => b.startHour == hour && b.status != BookingStatus.cancelled,
      );
    } catch (e) {
      currentBooking = null;
    }

    // Logic Status
    bool isBooked = currentBooking != null;
    // PENTING: request.jsonData['username'] harus ada dari login, atau cek ID user
    // Karena kita pakai API DRF, data user login biasanya gak kesimpen di 'jsonData' bawaan PBP auth secara default kecuali lu set pas login.
    // WORKAROUND SIMPLE: Kita anggap kalo tombol cancel muncul, itu punya kita.
    // Tapi karena logic "My Booking" butuh user ID, sementara kita skip dulu logic "My Booking" di detail page,
    // kita fokus: Kalo Booked = tombol mati (abu-abu).

    String statusText = "Available";
    Color btnColor = AppColors.frostPrimary;
    VoidCallback? onTap;

    if (isBooked) {
      statusText = "Booked";
      btnColor = Colors.grey;
      onTap = null;
    } 
    else {
      // Require login for booking
      // if (request.loggedIn) {
      //   onTap = () => _showActivityModal(hour);
      // } 
      // else {
      //   statusText = "Login to Book";
      //   btnColor = Colors.orange;
      //   onTap =
      //       widget.onActionRequired ??
      //       () {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text('Please login to make a booking')),
      //         );
      //       };
      // }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: Colors.white,
              ),
              onPressed: onTap,
              child: Text(statusText),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityModal(int hour) {
    BookingActivity selected = BookingActivity.iceSkating;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Aktivitas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              RadioListTile(
                title: const Text("Ice Skating"),
                value: BookingActivity.iceSkating,
                groupValue: selected,
                onChanged: (val) => setModalState(() => selected = val!),
              ),
              RadioListTile(
                title: const Text("Ice Hockey"),
                value: BookingActivity.iceHockey,
                groupValue: selected,
                onChanged: (val) => setModalState(() => selected = val!),
              ),
              RadioListTile(
                title: const Text("Curling"),
                value: BookingActivity.curling,
                groupValue: selected,
                onChanged: (val) => setModalState(() => selected = val!),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.frostPrimary,
                  ),
                  onPressed: () => _submitBooking(hour, selected),
                  child: const Text(
                    "Konfirmasi Booking",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
