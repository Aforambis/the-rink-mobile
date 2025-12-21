import 'package:flutter/foundation.dart';
import '../models/rental_gear_models.dart';

/// Simple cart item model for local cart management
class LocalCartItem {
  final Gear gear;
  int quantity;
  int days;

  LocalCartItem({required this.gear, this.quantity = 1, this.days = 1});

  double get subtotal => gear.pricePerDay * quantity * days;
}

/// Singleton cart service for managing cart state across the app
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<LocalCartItem> _items = [];

  List<LocalCartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Add gear to cart
  void addToCart(Gear gear, {int quantity = 1, int days = 1}) {
    // Check if gear already exists in cart
    final existingIndex = _items.indexWhere((item) => item.gear.id == gear.id);

    if (existingIndex != -1) {
      // Update existing item
      _items[existingIndex].quantity += quantity;
      _items[existingIndex].days = days;
    } else {
      // Add new item
      _items.add(LocalCartItem(gear: gear, quantity: quantity, days: days));
    }
    notifyListeners();
  }

  /// Remove gear from cart
  void removeFromCart(int gearId) {
    _items.removeWhere((item) => item.gear.id == gearId);
    notifyListeners();
  }

  /// Update quantity
  void updateQuantity(int gearId, int quantity) {
    final index = _items.indexWhere((item) => item.gear.id == gearId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// Update days
  void updateDays(int gearId, int days) {
    final index = _items.indexWhere((item) => item.gear.id == gearId);
    if (index != -1 && days > 0) {
      _items[index].days = days;
      notifyListeners();
    }
  }

  /// Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Check if gear is in cart
  bool isInCart(int gearId) {
    return _items.any((item) => item.gear.id == gearId);
  }

  /// Get cart item by gear id
  LocalCartItem? getCartItem(int gearId) {
    try {
      return _items.firstWhere((item) => item.gear.id == gearId);
    } catch (e) {
      return null;
    }
  }
}
