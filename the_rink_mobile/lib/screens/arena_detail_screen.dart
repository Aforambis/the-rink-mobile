import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 

import '../models/booking_arena.dart';
// import '../theme/app_theme.dart'; // Uncomment kalo file theme lu ada

class ArenaDetailScreen extends StatefulWidget {
  final Arena arena;

  const ArenaDetailScreen({super.key, required this.arena});

  @override
  State<ArenaDetailScreen> createState() => _ArenaDetailScreenState();
}

class _ArenaDetailScreenState extends State<ArenaDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  
  // Kita simpan slot yang terisi. Key: Jam, Value: Booking Data
  Map<int, Booking> _bookedSlots = {};
  bool _isLoading = true;

  final int openHour = 10;
  final int closeHour = 22;

  // GANTI URL DISINI SESUAI ENVIRONMENT
  final String baseUrl = "http://127.0.0.1:8000"; 

  @override
  void initState() {
    super.initState();
    // Fetch data setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSlots();
    });
  }

  Future<void> _fetchSlots() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final String url = '$baseUrl/booking/api/bookings/?arena=${widget.arena.id}&date=$dateStr';

    try {
      final response = await request.get(url);
      
      Map<int, Booking> tempSlots = {};
      
      // Django return list of dicts
      for (var d in response) {
        if (d != null) {
          Booking b = Booking.fromSlotJson(d);
          // Simpan booking berdasarkan jam mulai
          tempSlots[b.startHour] = b;
        }
      }

      setState(() {
        _bookedSlots = tempSlots;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching slots: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitBooking(int hour, BookingActivity activity) async {
    final request = context.read<CookieRequest>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Kirim request booking
    final response = await request.postJson(
      "$baseUrl/booking/api/booking/create/",
      jsonEncode({
        "arena_id": widget.arena.id,
        "date": dateStr,
        "start_hour": hour,
        "activity": activity == BookingActivity.iceSkating ? "ice_skating" 
                  : activity == BookingActivity.iceHockey ? "ice_hockey" 
                  : "curling",
      }),
    );

    // Cek status dari JSON response Django
    if (response['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Booking Berhasil!"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context); // Tutup Modal
      _fetchSlots(); // Refresh slot biar tombolnya jadi merah/abu
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message'] ?? "Gagal booking"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arena.name),
        // backgroundColor: AppColors.frostPrimary, 
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
              errorBuilder: (_,__,___) => Container(height: 200, color: Colors.grey[300]),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(widget.arena.location, style: const TextStyle(color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.arena.description),
                const Divider(height: 32),

                // --- DATE PICKER ---
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _fetchSlots(); // Fetch ulang pas ganti tanggal
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent), // AppColors.frostPrimary
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date: ${DateFormat('EEEE, d MMM y').format(_selectedDate)}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Available Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // --- SLOT LIST ---
                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (_selectedDate.day == DateTime.now().day && DateTime.now().hour >= closeHour)
                   const Center(child: Text("Arena sudah tutup hari ini."))
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
    // Cek apakah jam ini sudah lewat (untuk hari ini)
    bool isTimePassed = _selectedDate.day == DateTime.now().day && 
                        _selectedDate.month == DateTime.now().month &&
                        _selectedDate.year == DateTime.now().year &&
                        hour <= DateTime.now().hour;

    // Cek di map _bookedSlots
    Booking? bookingInfo = _bookedSlots[hour];
    bool isBooked = bookingInfo != null;
    bool isMine = isBooked && bookingInfo.isMine;

    String statusText = "Available";
    Color btnColor = Colors.blue; // AppColors.frostPrimary
    VoidCallback? onTap = () => _showActivityModal(hour);

    if (isTimePassed) {
       statusText = "Passed";
       btnColor = Colors.grey;
       onTap = null;
    } else if (isMine) {
      statusText = "Booked by You";
      btnColor = Colors.green; // Indikator punya sendiri
      onTap = null;
    } else if (isBooked) {
      statusText = "Booked"; // Punya orang lain
      btnColor = Colors.grey;
      onTap = null; 
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
             bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Book Slot: ${hour}:00", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Select Activity:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              
              _buildRadioOption("Ice Skating", BookingActivity.iceSkating, selected, (val) => setModalState(() => selected = val!)),
              _buildRadioOption("Ice Hockey", BookingActivity.iceHockey, selected, (val) => setModalState(() => selected = val!)),
              _buildRadioOption("Curling", BookingActivity.curling, selected, (val) => setModalState(() => selected = val!)),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // AppColors.frostPrimary
                    padding: const EdgeInsets.symmetric(vertical: 14)
                  ),
                  onPressed: () => _submitBooking(hour, selected),
                  child: const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title, BookingActivity value, BookingActivity group, Function(BookingActivity?) onChange) {
    return RadioListTile<BookingActivity>(
      title: Text(title),
      value: value,
      groupValue: group,
      onChanged: onChange,
      activeColor: Colors.blueAccent,
      contentPadding: EdgeInsets.zero,
    );
  }
}