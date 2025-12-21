import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../auth/login.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final EventService _eventService = EventService();
  late Future<Map<String, dynamic>> _detailFuture;

  late bool _isRegistered;
  late int _currentParticipants;
  String get baseUrl => _eventService.baseUrl;

  @override
  void initState() {
    super.initState();
    _isRegistered = widget.event.isRegistered;
    _currentParticipants = widget.event.participantCount;

    final request = context.read<CookieRequest>();

    _detailFuture = _eventService
        .fetchEventDetail(request, widget.event.id)
        .then((data) {
          if (mounted && data.isNotEmpty) {
            setState(() {
              if (data.containsKey('is_registered')) {
                _isRegistered = data['is_registered'];
              }
              if (data.containsKey('participant_count')) {
                _currentParticipants = data['participant_count'];
              }
            });
          }
          return data;
        });
  }

  String formatRupiah(double number) {
    String price = number.toStringAsFixed(0);
    String result = "";
    int count = 0;
    for (int i = price.length - 1; i >= 0; i--) {
      count++;
      result = price[i] + result;
      if (count == 3 && i > 0) {
        result = ".$result";
        count = 0;
      }
    }
    return "Rp $result";
  }

  void _handleRSVP() async {
    final request = context.read<CookieRequest>();

    if (!request.loggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (_currentParticipants >= widget.event.maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event is fully booked!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.event.price == 0) {
      setState(() {
        _isRegistered = true;
        _currentParticipants++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully registered for free event!"),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    _showPaymentModal();
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentModalContent(
        event: widget.event,
        onPaymentComplete: _processPayment,
      ),
    );
  }

  Future<void> _processPayment(String paymentMethod) async {
    final request = context.read<CookieRequest>();

    setState(() {
      _isRegistered = true;
      _currentParticipants++;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Payment Successful!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Paid with $paymentMethod",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildRecommendationCard(Event recEvent) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(event: recEvent),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  recEvent.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.frostPrimary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recEvent.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recEvent.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recEvent.date,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recEvent.location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'event_img_${widget.event.id}',
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.event.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.snowSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.frostPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.frostPrimary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        widget.event.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.frostPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.event.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.glacialBlue,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.event.date,
                          style: const TextStyle(color: AppColors.mutedText),
                        ),
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 20,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.event.time,
                          style: const TextStyle(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: AppColors.frostPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.event.location,
                            style: const TextStyle(
                              color: AppColors.glacialBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.softDropShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Price",
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.event.price == 0
                                    ? "FREE"
                                    : formatRupiah(widget.event.price),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.frostPrimary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Available Slots",
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$_currentParticipants / ${widget.event.maxParticipants}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _currentParticipants >=
                                          widget.event.maxParticipants
                                      ? Colors.red
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "About Event",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.event.description,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _detailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final data = snapshot.data!;
                        final rawRecs =
                            data['recommended_events'] as List? ?? [];

                        if (rawRecs.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "You Might Also Like",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.glacialBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: rawRecs.length,
                                itemBuilder: (context, index) {
                                  var recData = Map<String, dynamic>.from(
                                    rawRecs[index],
                                  );

                                  if (recData['image_url'] != null &&
                                      !recData['image_url']
                                          .toString()
                                          .startsWith('http')) {
                                    recData['image_url'] =
                                        "$baseUrl${recData['image_url']}";
                                  }

                                  final recEvent = Event.fromJson(recData);
                                  return _buildRecommendationCard(recEvent);
                                },
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed:
                (_isRegistered ||
                    _currentParticipants >= widget.event.maxParticipants)
                ? null
                : _handleRSVP,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.frostPrimary,
              disabledBackgroundColor: _isRegistered
                  ? Colors.green[100]
                  : Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _isRegistered
                  ? "You are Registered"
                  : (_currentParticipants >= widget.event.maxParticipants
                        ? "Sold Out"
                        : "RSVP Now"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isRegistered ? Colors.green[800] : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// MOVE THESE CLASSES OUTSIDE (after the closing brace of _EventDetailPageState)

class _PaymentModalContent extends StatefulWidget {
  final Event event;
  final Future<void> Function(String) onPaymentComplete;

  const _PaymentModalContent({
    required this.event,
    required this.onPaymentComplete,
  });

  @override
  State<_PaymentModalContent> createState() => _PaymentModalContentState();
}

class _PaymentModalContentState extends State<_PaymentModalContent> {
  String? selectedMethod;
  bool isProcessing = false;

  String formatRupiah(double number) {
    String price = number.toStringAsFixed(0);
    String result = "";
    int count = 0;
    for (int i = price.length - 1; i >= 0; i--) {
      count++;
      result = price[i] + result;
      if (count == 3 && i > 0) {
        result = ".$result";
        count = 0;
      }
    }
    return "Rp $result";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.frostPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.payment_rounded,
                          color: AppColors.frostPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Complete Payment",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.glacialBlue,
                              ),
                            ),
                            Text(
                              "Choose your payment method",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PaymentMethodTile(
                    icon: Icons.qr_code_scanner_rounded,
                    label: "QRIS",
                    subtitle: "Scan & Pay instantly",
                    isSelected: selectedMethod == "QRIS",
                    onTap: () => setState(() => selectedMethod = "QRIS"),
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodTile(
                    icon: Icons.account_balance_rounded,
                    label: "Virtual Account",
                    subtitle: "BCA, BNI, Mandiri, BRI",
                    isSelected: selectedMethod == "VA",
                    onTap: () => setState(() => selectedMethod = "VA"),
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodTile(
                    icon: Icons.account_balance_wallet_rounded,
                    label: "E-Wallet",
                    subtitle: "GoPay, OVO, DANA, ShopeePay",
                    isSelected: selectedMethod == "E-Wallet",
                    onTap: () => setState(() => selectedMethod = "E-Wallet"),
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodTile(
                    icon: Icons.credit_card_rounded,
                    label: "Credit/Debit Card",
                    subtitle: "Visa, Mastercard, JCB",
                    isSelected: selectedMethod == "Card",
                    onTap: () => setState(() => selectedMethod = "Card"),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.frostPrimary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.frostPrimary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Event Fee",
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              formatRupiah(widget.event.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Platform Fee",
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              formatRupiah(widget.event.price * 0.05),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Payment",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.glacialBlue,
                              ),
                            ),
                            Text(
                              formatRupiah(widget.event.price * 1.05),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.frostPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: selectedMethod == null || isProcessing
                    ? null
                    : () async {
                        setState(() => isProcessing = true);
                        await widget.onPaymentComplete(selectedMethod!);
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.frostPrimary,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        "Pay ${formatRupiah(widget.event.price * 1.05)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.frostPrimary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.frostPrimary
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.frostPrimary.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.frostPrimary : Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected
                          ? AppColors.frostPrimary
                          : AppColors.glacialBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.frostPrimary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
