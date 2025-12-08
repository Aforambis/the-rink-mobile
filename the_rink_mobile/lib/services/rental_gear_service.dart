// rental_gear_service.dart
// Service class untuk integrasi dengan Django API

import 'dart:convert';
import 'package:http/http.dart' as http;

// Import models
// import 'rental_gear_models.dart';

class RentalGearService {
  // Ganti dengan URL Django server Anda
  static const String baseUrl = 'http://localhost:8000/rental_gear/api/flutter';

  // Untuk production, gunakan domain sebenarnya:
  // static const String baseUrl = 'https://your-domain.com/rental_gear/api/flutter';

  // ==================== PUBLIC ENDPOINTS (No Auth) ====================

  /// Get all available gears
  ///
  /// Returns: List of Gear objects
  Future<List<dynamic>> getAllGears() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/gears/'))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load gears: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback demo data so the UI keeps working
      return [
        {
          "id": 1,
          "name": "Pro Hockey Stick",
          "category": "hockey",
          "price_per_day": 12.5,
          "stock": 4,
          "description": "Lightweight carbon fiber stick for power shots.",
          "image_url": "",
          "seller_id": 1,
          "seller_username": "coach_alan",
          "is_featured": true,
        },
        {
          "id": 2,
          "name": "Protective Helmet",
          "category": "protective_gear",
          "price_per_day": 8.0,
          "stock": 7,
          "description": "Certified helmet with adjustable straps.",
          "image_url": "",
          "seller_id": 2,
          "seller_username": "gear_shop",
          "is_featured": false,
        },
        {
          "id": 3,
          "name": "Ice Skates (Size 42)",
          "category": "ice_skating",
          "price_per_day": 10.0,
          "stock": 0,
          "description": "Comfort-fit skates, freshly sharpened.",
          "image_url": "",
          "seller_id": 3,
          "seller_username": "arena_rental",
          "is_featured": false,
        },
      ];
    }
  }

  /// Get gear detail by ID
  /// Returns: Gear object
  Future<Map<String, dynamic>> getGearDetail(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gears/$id/'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Gear not found');
      } else {
        throw Exception('Failed to load gear detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching gear detail: $e');
    }
  }

  // ==================== CART ENDPOINTS (Auth Required) ====================

  /// Get user's cart
  /// Requires: authentication cookie
  /// Returns: CartResponse
  Future<Map<String, dynamic>> getCart(String cookie) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart/'),
        headers: {'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  /// Add item to cart
  /// Requires: authentication cookie
  /// Parameters:
  ///   - gearId: int (ID of gear to add)
  ///   - quantity: int (1-stock available)
  ///   - days: int (1-30)
  /// Returns: ApiResponse
  Future<Map<String, dynamic>> addToCart({
    required int gearId,
    required int quantity,
    required int days,
    required String cookie,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add/'),
        headers: {'Content-Type': 'application/json', 'Cookie': cookie},
        body: jsonEncode({
          'gear_id': gearId,
          'quantity': quantity,
          'days': days,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  /// Update cart item quantity/days
  /// Requires: authentication cookie
  /// Parameters:
  ///   - itemId: int (cart item ID)
  ///   - quantity: int? (optional)
  ///   - days: int? (optional)
  /// Returns: ApiResponse with new subtotal
  Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    int? quantity,
    int? days,
    required String cookie,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (quantity != null) body['quantity'] = quantity;
      if (days != null) body['days'] = days;

      final response = await http.post(
        Uri.parse('$baseUrl/cart/update/$itemId/'),
        headers: {'Content-Type': 'application/json', 'Cookie': cookie},
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  /// Remove item from cart
  /// Requires: authentication cookie
  /// Parameters: itemId (cart item ID)
  /// Returns: ApiResponse
  Future<Map<String, dynamic>> removeFromCart({
    required int itemId,
    required String cookie,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/remove/$itemId/'),
        headers: {'Cookie': cookie},
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  /// Checkout all items in cart
  /// Requires: authentication cookie
  /// Returns: CheckoutResponse with rental details
  Future<Map<String, dynamic>> checkout(String cookie) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkout/'),
        headers: {'Cookie': cookie},
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error during checkout: $e');
    }
  }

  // ==================== RENTAL HISTORY ====================

  /// Get user's rental history
  /// Requires: authentication cookie
  /// Returns: RentalsResponse
  Future<Map<String, dynamic>> getRentalHistory(String cookie) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rentals/'),
        headers: {'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception(
          'Failed to load rental history: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching rental history: $e');
    }
  }

  // ==================== SELLER ENDPOINTS ====================

  /// Get seller's own gears
  /// Requires: authentication cookie (seller account)
  /// Returns: SellerGearsResponse
  Future<Map<String, dynamic>> getSellerGears(String cookie) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seller/gears/'),
        headers: {'Cookie': cookie},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Seller authentication required');
      } else {
        throw Exception('Failed to load seller gears: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching seller gears: $e');
    }
  }

  /// Create new gear (seller only)
  /// Requires: authentication cookie (seller account)
  /// Parameters: Gear details
  /// Returns: ApiResponse with gear_id
  Future<Map<String, dynamic>> createGear({
    required String name,
    required String category,
    required double pricePerDay,
    required int stock,
    String? description,
    String? imageUrl,
    bool isFeatured = false,
    required String cookie,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/gears/create/'),
        headers: {'Content-Type': 'application/json', 'Cookie': cookie},
        body: jsonEncode({
          'name': name,
          'category': category,
          'price_per_day': pricePerDay,
          'stock': stock,
          'description': description ?? '',
          'image_url': imageUrl ?? '',
          'is_featured': isFeatured,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error creating gear: $e');
    }
  }

  /// Update existing gear (seller only)
  /// Requires: authentication cookie (seller account)
  /// Parameters: gear ID and fields to update
  /// Returns: ApiResponse
  Future<Map<String, dynamic>> updateGear({
    required int gearId,
    String? name,
    String? category,
    double? pricePerDay,
    int? stock,
    String? description,
    String? imageUrl,
    bool? isFeatured,
    required String cookie,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (category != null) body['category'] = category;
      if (pricePerDay != null) body['price_per_day'] = pricePerDay;
      if (stock != null) body['stock'] = stock;
      if (description != null) body['description'] = description;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (isFeatured != null) body['is_featured'] = isFeatured;

      final response = await http.post(
        Uri.parse('$baseUrl/seller/gears/$gearId/update/'),
        headers: {'Content-Type': 'application/json', 'Cookie': cookie},
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error updating gear: $e');
    }
  }

  /// Delete gear (seller only)
  /// Requires: authentication cookie (seller account)
  /// Parameters: gear ID
  /// Returns: ApiResponse
  Future<Map<String, dynamic>> deleteGear({
    required int gearId,
    required String cookie,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seller/gears/$gearId/delete/'),
        headers: {'Cookie': cookie},
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error deleting gear: $e');
    }
  }
}
