import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String serverOrigin = 'http://127.0.0.1:8000';
  static const String baseUrl = '$serverOrigin/api';

  static String? authToken;

  // ============================================================
  // HELPERS
  // ============================================================

  /// Converts relative media URLs such as /uploads/image.jpg
  /// into absolute backend URLs.
  static String resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80';
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('/')) {
      return '$serverOrigin$url';
    }

    return '$serverOrigin/$url';
  }

  /// Checks whether the backend is reachable.
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(milliseconds: 2500));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // 1. AUTHENTICATION & SMS OTP
  // ============================================================

  /// Requests an OTP from the backend.
  ///
  /// There is NO offline/mock OTP fallback.
  static Future<Map<String, dynamic>> requestOtp(String phone) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/request-otp'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'phone': phone,
            }),
          )
          .timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception(
        'Backend OTP request failed: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Unable to connect to backend: $e',
      );
    }
  }

  /// Logs in using phone number and OTP.
  ///
  /// IMPORTANT:
  /// The backend is the source of truth for the user's role.
  ///
  /// Flutter does NOT send a role here.
  ///
  /// Backend response should contain something like:
  ///
  /// {
  ///   "access_token": "...",
  ///   "user": {
  ///     "id": 1,
  ///     "name": "Asha Devi",
  ///     "phone": "...",
  ///     "role": "artisan"
  ///   }
  /// }
  ///
  /// UserModel.fromJson() converts the backend role into
  /// UserRoleType.artisan or UserRoleType.customer.
  ///
  /// There is NO mock-user fallback.
  static Future<UserModel> loginWithOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'phone': phone,
              'otp': otp,
            }),
          )
          .timeout(const Duration(milliseconds: 3500));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['access_token'];

        if (token != null) {
          authToken = token.toString();
        }

        if (data['user'] != null) {
          return UserModel.fromJson(
            Map<String, dynamic>.from(data['user']),
          );
        }

        throw Exception(
          'Backend returned no user.',
        );
      }

      throw Exception(
        'Login failed: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Unable to login: $e',
      );
    }
  }

  // ============================================================
  // 2. PRODUCT CATALOG
  // ============================================================

  /// Fetches all craft products from the backend database.
  ///
  /// Backend failure throws an exception.
  /// It does NOT return mock products.
  static Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/'),
            headers: {
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);

        return list.map((json) {
          final product = ProductModel.fromJson(
            Map<String, dynamic>.from(json),
          );

          return product.copyWith(
            imageUrl: resolveImageUrl(product.imageUrl),
          );
        }).toList();
      }

      throw Exception(
        'Failed to fetch products: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Unable to fetch products: $e',
      );
    }
  }

  /// Creates and publishes a new product.
  ///
  /// Backend failure throws an exception.
  /// It does NOT pretend that the product was created.
  static Future<ProductModel> createProduct(
    ProductModel product,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/products/'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'name': product.name,
              'description': product.description,
              'price': product.price,
              'category': product.category,
              'stock': product.stock,
              'state': product.state,
            }),
          )
          .timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final created = ProductModel.fromJson(
          Map<String, dynamic>.from(data),
        );

        return created.copyWith(
          imageUrl: product.imageUrl,
        );
      }

      throw Exception(
        'Failed to create product: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Unable to create product: $e',
      );
    }
  }

  // ============================================================
  // 3. MEDIA & CAMERA UPLOAD
  // ============================================================

  /// Uploads a camera-captured image/file to the backend.
  ///
  /// If bytes are supplied, those bytes are uploaded.
  ///
  /// If no bytes are supplied, a tiny placeholder JPEG payload is
  /// used because this method historically supported simulated
  /// uploads. This does NOT pretend the backend upload succeeded:
  /// the backend must still return HTTP 200.
  static Future<String?> uploadSimulatedImage({
    required String filename,
    List<int>? bytes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/media/upload');

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      final imageBytes = bytes ??
          [
            255,
            216,
            255,
            224,
            0,
            16,
            74,
            70,
            73,
            70,
          ];

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
        ),
      );

      if (authToken != null) {
        request.headers['Authorization'] =
            'Bearer $authToken';
      }

      final streamedResponse = await request.send().timeout(
            const Duration(milliseconds: 4000),
          );

      final response =
          await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // 4. AI & VISION SERVICES
  // ============================================================

  /// Runs Google Cloud Vision + Gemini listing generation.
  static Future<Map<String, dynamic>?> digitizeProductWithAi({
    String? imageUrl,
    String? voiceTranscript,
    String? categoryHint,
    String? artisanName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/digitize-product'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'image_url': imageUrl,
              'voice_transcript': voiceTranscript,
              'category_hint': categoryHint,
              'artisan_name': artisanName,
            }),
          )
          .timeout(const Duration(milliseconds: 5000));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Asks the KalaSathi chatbot.
  static Future<String> askKalaSathi(String query) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/chat'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'query': query,
            }),
          )
          .timeout(const Duration(milliseconds: 4000));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['reply'] ?? '';
      }

      return '';
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // 5. RAZORPAY PAYMENT GATEWAY
  // ============================================================

  /// Creates a Razorpay payment order.
  static Future<Map<String, dynamic>?> createRazorpayOrder({
    required double amount,
    int? orderId,
    String? productName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/payments/create-order'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'amount': amount,
              'order_id': orderId,
              'product_name': productName,
            }),
          )
          .timeout(const Duration(milliseconds: 4000));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Verifies Razorpay cryptographic signature.
  ///
  /// Returns false if verification fails.
  /// It NEVER assumes that payment succeeded.
  static Future<bool> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    int? orderId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/payments/verify'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'razorpay_order_id': razorpayOrderId,
              'razorpay_payment_id': razorpayPaymentId,
              'razorpay_signature': razorpaySignature,
              'order_id': orderId,
            }),
          )
          .timeout(const Duration(milliseconds: 4000));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['status'] == 'success';
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // 6. ORDERS
  // ============================================================

  /// Fetches orders from the backend.
  ///
  /// Backend failure throws an exception.
  /// It does NOT return mock orders.
  static Future<List<OrderModel>> fetchOrders() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/orders/'),
            headers: {
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);

        return list
            .map(
              (json) => OrderModel.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }

      throw Exception(
        'Failed to fetch orders: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Unable to fetch orders: $e',
      );
    }
  }

  /// Creates an order in the backend.
  ///
  /// Backend failure throws an exception.
  /// It does NOT create a fake local order.
  static Future<OrderModel> createOrder({
    required int userId,
    required int productId,
    required int quantity,
    required double totalPrice,
    required String productName,
    required String artisanName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'product_id': productId,
              'quantity': quantity,
              'user_id': userId,
            }),
          )
          .timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return OrderModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        'Failed to create order: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Unable to create order: $e',
      );
    }
  }

  // ============================================================
  // 7. ARTISAN PROFILE
  // ============================================================

  /// Updates artisan profile avatar.
  static Future<bool> updateArtisanAvatar(
    String imageUrl,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/artisan/profile/avatar'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'image_url': imageUrl,
            }),
          )
          .timeout(const Duration(milliseconds: 3000));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Fetches live artisan workshop analytics.
  static Future<Map<String, dynamic>?> fetchArtisanStats() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/artisan/stats'),
            headers: {
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // 8. ARTISAN PEHCHAN VERIFICATION
  // ============================================================

  /// Verifies Artisan Pehchan ID / Aadhaar document.
  ///
  /// Backend failure throws an exception.
  /// It does NOT automatically mark the artisan as verified.
  static Future<Map<String, dynamic>> verifyPehchanId({
    String? documentUrl,
    String? pehchanId,
    String? artisanName,
    String? phone,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/artisan/verify-pehchan'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null)
                'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'document_url': documentUrl,
              'pehchan_id': pehchanId,
              'artisan_name': artisanName,
              'phone': phone,
            }),
          )
          .timeout(const Duration(milliseconds: 4000));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception(
        'Verification failed: HTTP ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Unable to verify artisan: $e',
      );
    }
  }
}