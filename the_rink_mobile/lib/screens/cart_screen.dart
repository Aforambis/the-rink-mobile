import 'package:flutter/material.dart';
import '../models/rental_gear_models.dart';
import '../theme/app_theme.dart';
import '../services/cart_service.dart';

class CartItemPreview {
  final Gear gear;
  final int quantity;
  final int days;

  CartItemPreview({
    required this.gear,
    required this.quantity,
    required this.days,
  });
}

// Global cart service instance
final cartService = CartService();

/// Format number to Indonesian Rupiah format
String _formatRupiah(double amount) {
  // Harga sudah dalam Rupiah, langsung format
  String price = amount.toStringAsFixed(0);
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
  return result;
}

class CartScreen extends StatefulWidget {
  final List<CartItemPreview> items;

  const CartScreen({super.key, required this.items});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to cart changes
    cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  void _showPaymentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartPaymentModalContent(
        totalAmount: totalPrice,
        itemCount: cartService.itemCount,
        onPaymentComplete: _processPayment,
      ),
    );
  }

  Future<void> _processPayment(String paymentMethod) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
        backgroundColor: AppColors.frostPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );

    cartService.clearCart();
  }

  double get totalPrice => cartService.totalPrice;

  @override
  Widget build(BuildContext context) {
    final items = cartService.items;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Cart'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartService.clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: WinterTheme.pageBackground(),
        child: SafeArea(
          child: items.isEmpty
              ? _EmptyCartState(onExplore: () => Navigator.pop(context))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _CartItemCard(
                            item: item,
                            onQuantityChanged: (qty) {
                              cartService.updateQuantity(item.gear.id, qty);
                            },
                            onDaysChanged: (days) {
                              cartService.updateDays(item.gear.id, days);
                            },
                            onRemove: () {
                              cartService.removeFromCart(item.gear.id);
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.frostedGlass,
                        boxShadow: AppColors.softDropShadow,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${cartService.itemCount} items',
                                    style: TextStyle(
                                      color: AppColors.mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Rp ${_formatRupiah(totalPrice)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppColors.frostPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.frostPrimary,
                                  AppColors.auroraViolet,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.frostPrimary.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _showPaymentModal(context),
                              icon: const Icon(Icons.payment_rounded),
                              label: const Text('Complete Checkout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
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
}

class _CartItemCard extends StatelessWidget {
  final LocalCartItem item;
  final Function(int) onQuantityChanged;
  final Function(int) onDaysChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onDaysChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.frostedGlass,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softDropShadow,
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.auroraGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.sports_hockey_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.gear.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_formatRupiah(item.gear.pricePerDay)}/day',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subtotal: Rp ${_formatRupiah(item.subtotal)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.frostPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuantitySelector(
                  label: 'Qty',
                  value: item.quantity,
                  max: item.gear.stock,
                  onChanged: onQuantityChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuantitySelector(
                  label: 'Days',
                  value: item.days,
                  max: 30,
                  onChanged: onDaysChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Function(int) onChanged;

  const _QuantitySelector({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.frostPrimary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: value > 1 ? () => onChanged(value - 1) : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        value > 1 ? AppColors.frostPrimary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 14,
                    color: value > 1 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: value < max ? () => onChanged(value + 1) : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        value < max ? AppColors.frostPrimary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 14,
                    color: value < max ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  final VoidCallback onExplore;

  const _EmptyCartState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.auroraGradient,
                boxShadow: AppColors.softDropShadow,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some icy gear to get started.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.frostPrimary, AppColors.auroraViolet],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.frostPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: onExplore,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.explore_rounded),
                label: const Text(
                  'Explore Gear',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Modal Content for Cart Checkout
class _CartPaymentModalContent extends StatefulWidget {
  final double totalAmount;
  final int itemCount;
  final Future<void> Function(String) onPaymentComplete;

  const _CartPaymentModalContent({
    required this.totalAmount,
    required this.itemCount,
    required this.onPaymentComplete,
  });

  @override
  State<_CartPaymentModalContent> createState() =>
      _CartPaymentModalContentState();
}

class _CartPaymentModalContentState extends State<_CartPaymentModalContent> {
  String? selectedMethod;
  bool isProcessing = false;

  String formatCurrency(double amount) {
    // Harga sudah dalam Rupiah, langsung format
    String price = amount.toStringAsFixed(0);
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
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final platformFee = widget.totalAmount * 0.05;
    final grandTotal = widget.totalAmount + platformFee;

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
                  _CartPaymentMethodTile(
                    icon: Icons.qr_code_scanner_rounded,
                    label: "QRIS",
                    subtitle: "Scan & Pay instantly",
                    isSelected: selectedMethod == "QRIS",
                    onTap: () => setState(() => selectedMethod = "QRIS"),
                  ),
                  const SizedBox(height: 12),
                  _CartPaymentMethodTile(
                    icon: Icons.account_balance_rounded,
                    label: "Virtual Account",
                    subtitle: "BCA, BNI, Mandiri, BRI",
                    isSelected: selectedMethod == "VA",
                    onTap: () => setState(() => selectedMethod = "VA"),
                  ),
                  const SizedBox(height: 12),
                  _CartPaymentMethodTile(
                    icon: Icons.account_balance_wallet_rounded,
                    label: "E-Wallet",
                    subtitle: "GoPay, OVO, DANA, ShopeePay",
                    isSelected: selectedMethod == "E-Wallet",
                    onTap: () => setState(() => selectedMethod = "E-Wallet"),
                  ),
                  const SizedBox(height: 12),
                  _CartPaymentMethodTile(
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
                            Text(
                              "Rental Fee (${widget.itemCount} items)",
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              formatCurrency(widget.totalAmount),
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
                              "Platform Fee (5%)",
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              formatCurrency(platformFee),
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
                              formatCurrency(grandTotal),
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
                  minimumSize: const Size(double.infinity, 50),
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
                        "Pay ${formatCurrency(grandTotal)}",
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

class _CartPaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _CartPaymentMethodTile({
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
