import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'mock_data.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static String? authToken;

  /// Attempts to reach backend; returns true if server is active
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(milliseconds: 1500));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 1. Login with Phone & OTP
  static Future<UserModel> loginWithOtp({
    required String phone,
    required String otp,
    required UserRoleType preferredRole,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'otp': otp}),
          )
          .timeout(const Duration(milliseconds: 2000));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        authToken = data['access_token'];
        // Fetch current user
        final meResponse = await http.get(
          Uri.parse('$baseUrl/auth/me'),
          headers: {'Authorization': 'Bearer $authToken'},
        );
        if (meResponse.statusCode == 200) {
          final meData = jsonDecode(meResponse.body);
          return UserModel.fromJson(meData['user']);
        }
      }
    } catch (_) {
      // Graceful offline mock fallback
    }

    // Default to role-specific mock user
    if (preferredRole == UserRoleType.artisan) {
      return MockDataService.defaultArtisanUser;
    } else {
      return MockDataService.defaultCustomerUser;
    }
  }

  /// 2. Fetch Products
  static Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/'))
          .timeout(const Duration(milliseconds: 2000));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        if (list.isNotEmpty) {
          return list.map((json) => ProductModel.fromJson(json)).toList();
        }
      }
    } catch (_) {
      // Backend not running, use seed data
    }
    return MockDataService.getInitialProducts();
  }

  /// 3. Create Product (Publishing AI generated product)
  static Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/products/'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null) 'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(product.toJson()),
          )
          .timeout(const Duration(milliseconds: 2000));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Local fallback
    }
    return product;
  }

  /// 4. Fetch Orders
  static Future<List<OrderModel>> fetchOrders() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/orders/'),
            headers: {
              if (authToken != null) 'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(const Duration(milliseconds: 2000));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        if (list.isNotEmpty) {
          return list.map((json) => OrderModel.fromJson(json)).toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return MockDataService.getInitialOrders();
  }

  /// 5. Create Order
  static Future<OrderModel> createOrder({
    required int userId,
    required int productId,
    required int quantity,
    required double totalPrice,
    required String productName,
    required String artisanName,
  }) async {
    final newOrder = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch,
      orderCode: '#AX${(1050 + DateTime.now().millisecond % 50)}',
      userId: userId,
      productId: productId,
      productName: productName,
      artisanName: artisanName,
      quantity: quantity,
      totalPrice: totalPrice,
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
    );

    try {
      await http
          .post(
            Uri.parse('$baseUrl/orders/'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null) 'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(newOrder.toJson()),
          )
          .timeout(const Duration(milliseconds: 2000));
    } catch (_) {
      // Fallback
    }

    return newOrder;
  }
}
