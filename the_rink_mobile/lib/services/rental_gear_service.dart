// rental_gear_service.dart
// Service class untuk integrasi dengan Django API

import 'dart:convert';
import 'package:http/http.dart' as http;

// Import models
// import 'rental_gear_models.dart';

class RentalGearService {
  // Ganti dengan URL Django server Anda
  static const String baseUrl =
      'https://angga-tri41-therink.pbp.cs.ui.ac.id/rental_gear/api/flutter';
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
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load gears: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Django API failed, using demo data. Error: $e');
      // Fallback demo data so the UI keeps working
      return [
        {
          "id": 1,
          "name": "Pro Hockey Stick",
          "category": "hockey",
          "price_per_day": 50000,
          "stock": 4,
          "description":
              "Lightweight carbon fiber stick for power shots. Perfect for professionals and enthusiasts alike.",
          "image_url":
              "https://images.unsplash.com/photo-1515703407324-5f753afd8be8?w=400",
          "seller_id": 1,
          "seller_username": "coach_alan",
          "is_featured": true,
        },
        {
          "id": 2,
          "name": "Junior Hockey Stick",
          "category": "hockey",
          "price_per_day": 35000,
          "stock": 6,
          "description":
              "Designed for younger players, lightweight and easy to handle.",
          "image_url":
              "https://images.unsplash.com/photo-1580748142242-7a7c4f0c1f45?w=400",
          "seller_id": 1,
          "seller_username": "coach_alan",
          "is_featured": false,
        },
        {
          "id": 3,
          "name": "Protective Helmet",
          "category": "protective_gear",
          "price_per_day": 35000,
          "stock": 7,
          "description":
              "Certified helmet with adjustable straps. Maximum protection for ice sports.",
          "image_url":
              "https://images.unsplash.com/photo-1557701197-fe4918653279?w=400",
          "seller_id": 2,
          "seller_username": "gear_shop",
          "is_featured": true,
        },
        {
          "id": 4,
          "name": "Knee Pads Set",
          "category": "protective_gear",
          "price_per_day": 25000,
          "stock": 10,
          "description":
              "Comfortable knee pads with shock absorption technology.",
          "image_url":
              "https://images.unsplash.com/photo-1616279967983-ec413476e824?w=400",
          "seller_id": 2,
          "seller_username": "gear_shop",
          "is_featured": false,
        },
        {
          "id": 5,
          "name": "Elbow Guards",
          "category": "protective_gear",
          "price_per_day": 20000,
          "stock": 8,
          "description": "Lightweight elbow protection for all skill levels.",
          "image_url":
              "https://images.unsplash.com/photo-1599058917727-824293f4e65e?w=400",
          "seller_id": 2,
          "seller_username": "gear_shop",
          "is_featured": false,
        },
        {
          "id": 6,
          "name": "Ice Skates Pro (Size 42)",
          "category": "ice_skating",
          "price_per_day": 75000,
          "stock": 5,
          "description": "Professional-grade skates, freshly sharpened blades.",
          "image_url":
              "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400",
          "seller_id": 3,
          "seller_username": "arena_rental",
          "is_featured": true,
        },
        {
          "id": 7,
          "name": "Ice Skates Standard (Size 40)",
          "category": "ice_skating",
          "price_per_day": 50000,
          "stock": 0,
          "description": "Comfort-fit skates, great for beginners.",
          "image_url":
              "https://images.unsplash.com/photo-1578950435899-d1c1bf932ab2?w=400",
          "seller_id": 3,
          "seller_username": "arena_rental",
          "is_featured": false,
        },
        {
          "id": 8,
          "name": "Ice Skates Kids (Size 35)",
          "category": "ice_skating",
          "price_per_day": 40000,
          "stock": 4,
          "description": "Perfect for young skaters, comfortable and safe.",
          "image_url":
              "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=400",
          "seller_id": 3,
          "seller_username": "arena_rental",
          "is_featured": false,
        },
        {
          "id": 9,
          "name": "Skate Bag",
          "category": "other",
          "price_per_day": 15000,
          "stock": 15,
          "description": "Durable bag for carrying skates and accessories.",
          "image_url":
              "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400",
          "seller_id": 2,
          "seller_username": "gear_shop",
          "is_featured": false,
        },
        {
          "id": 10,
          "name": "Blade Guards",
          "category": "other",
          "price_per_day": 10000,
          "stock": 20,
          "description": "Protect your blades when off the ice.",
          "image_url":
              "https://images.unsplash.com/photo-1622560480654-d96214fdc887?w=400",
          "seller_id": 2,
          "seller_username": "gear_shop",
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
