import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  // ============================================================
  // AUTHENTICATION & ROLE
  // ============================================================

  // IMPORTANT:
  // No role is assumed before login.
  //
  // The backend is the source of truth for the user's role.
  UserRoleType? _currentRole;

  UserModel? _currentUser;
  bool _isLoggedIn = false;

  // ============================================================
  // VOICE ASSISTANT
  // ============================================================

  bool _isVoiceAssistantActive = false;

  // ============================================================
  // PRODUCTS
  // ============================================================

  List<ProductModel> _products = [];

  bool _isLoadingProducts = false;
  String? _productsError;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  // ============================================================
  // ORDERS
  // ============================================================

  List<OrderModel> _orders = [];

  bool _isLoadingOrders = false;
  String? _ordersError;

  // ============================================================
  // AUTHENTICATION ERROR
  // ============================================================

  String? _authError;

  // ============================================================
  // CART
  // ============================================================

  final List<CartItemModel> _cart = [];

  // ============================================================
  // LIKES & WISHLIST
  // ============================================================

  final Set<int> _likedProductIds = {101};

  // ============================================================
  // LANGUAGE
  // ============================================================

  String _selectedLanguage = 'hi';

  // ============================================================
  // GETTERS
  // ============================================================

  /// The role returned by the backend.
  ///
  /// This is null before a user logs in.
  UserRoleType? get currentRole => _currentRole;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _isLoggedIn;

  /// True only when the backend-authenticated user is an artisan.
  bool get isArtisan => _currentRole == UserRoleType.artisan;

  /// True only when the backend-authenticated user is a customer.
  bool get isCustomer => _currentRole == UserRoleType.customer;

  bool get isVoiceAssistantActive => _isVoiceAssistantActive;

  List<ProductModel> get allProducts => _products;

  bool get isLoadingProducts => _isLoadingProducts;

  String? get productsError => _productsError;

  List<OrderModel> get orders => _orders;

  bool get isLoadingOrders => _isLoadingOrders;

  String? get ordersError => _ordersError;

  String? get authError => _authError;

  String get selectedCategory => _selectedCategory;

  String get searchQuery => _searchQuery;

  List<CartItemModel> get cart => _cart;

  int get cartItemCount =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartSubtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get cartTotal => cartSubtotal;

  String get selectedLanguage => _selectedLanguage;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    // IMPORTANT:
    // Do NOT create a default artisan/customer user.
    // Do NOT load mock products/orders.
    //
    // The backend is the source of truth.

    await refreshAll();
  }

  // ============================================================
  // BACKEND REFRESH
  // ============================================================

  Future<void> refreshAll() async {
    await Future.wait([
      fetchProductsFromBackend(),
      fetchOrdersFromBackend(),
    ]);
  }

  // ============================================================
  // VOICE ASSISTANT
  // ============================================================

  void setVoiceAssistantActive(bool active) {
    if (_isVoiceAssistantActive != active) {
      _isVoiceAssistantActive = active;
      notifyListeners();
    }
  }

  void toggleVoiceAssistant() {
    _isVoiceAssistantActive = !_isVoiceAssistantActive;
    notifyListeners();
  }

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  /// This method should NOT determine the user's role.
  ///
  /// The backend determines whether this user is an artisan
  /// or customer and returns that information in the login response.
  Future<bool> loginWithOtp(String phone, String otp) async {
    _authError = null;

    notifyListeners();

    try {
      // IMPORTANT:
      // Do not send a preferred role.
      //
      // The backend decides the user's actual role.
      final user = await ApiService.loginWithOtp(
        phone: phone,
        otp: otp,
      );

      // ========================================================
      // BACKEND IS THE SOURCE OF TRUTH
      // ========================================================

      _currentUser = user;

      // UserModel.fromJson() has already converted:
      //
      // "artisan"  -> UserRoleType.artisan
      // "customer" -> UserRoleType.customer
      //
      // Therefore we simply use the role returned by the backend.
      _currentRole = user.role;

      _isLoggedIn = true;

      _authError = null;

      notifyListeners();

      // Now that we have the authenticated user, refresh
      // backend data.
      await refreshAll();

      return true;
    } catch (e) {
      // Login failed.
      //
      // Do not leave a previous role/user active.
      _isLoggedIn = false;
      _currentUser = null;
      _currentRole = null;

      _authError = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    _isLoggedIn = false;

    _currentUser = null;

    // IMPORTANT:
    // Do not fall back to artisan/customer after logout.
    _currentRole = null;

    ApiService.authToken = null;

    // Clear backend-derived data as well.
    _products = [];
    _orders = [];

    _productsError = null;
    _ordersError = null;
    _authError = null;

    notifyListeners();
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Future<void> fetchProductsFromBackend() async {
    _isLoadingProducts = true;
    _productsError = null;

    notifyListeners();

    try {
      final backendProducts = await ApiService.fetchProducts();

      // An empty list from the backend is valid.
      _products = backendProducts;
    } catch (e) {
      // IMPORTANT:
      // Never fall back to MockDataService.
      //
      // If the backend fails, the UI should show an error state.
      _products = [];

      _productsError = e.toString();
    } finally {
      _isLoadingProducts = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ORDERS
  // ============================================================

  Future<void> fetchOrdersFromBackend() async {
    _isLoadingOrders = true;
    _ordersError = null;

    notifyListeners();

    try {
      final backendOrders = await ApiService.fetchOrders();

      // An empty list from the backend is valid.
      _orders = backendOrders;
    } catch (e) {
      // IMPORTANT:
      // Never use mock orders.
      _orders = [];

      _ordersError = e.toString();
    } finally {
      _isLoadingOrders = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CATEGORY & SEARCH
  // ============================================================

  void selectCategory(String category) {
    _selectedCategory = category;

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;

    notifyListeners();
  }

  List<ProductModel> get filteredProducts {
    return _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          p.category.toLowerCase() ==
              _selectedCategory.toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty ||
          p.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          p.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          p.tags.any(
            (t) => t
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()),
          );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ============================================================
  // WISHLIST
  // ============================================================

  bool isLiked(int productId) {
    return _likedProductIds.contains(productId);
  }

  void toggleLike(int productId) {
    if (_likedProductIds.contains(productId)) {
      _likedProductIds.remove(productId);
    } else {
      _likedProductIds.add(productId);
    }

    notifyListeners();
  }

  // ============================================================
  // CART
  // ============================================================

  void addToCart(
    ProductModel product, {
    int quantity = 1,
  }) {
    final index =
        _cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _cart[index].quantity += quantity;
    } else {
      _cart.add(
        CartItemModel(
          product: product,
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  void updateCartQuantity(
    int productId,
    int delta,
  ) {
    final index =
        _cart.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final newQty = _cart[index].quantity + delta;

      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = newQty;
      }

      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _cart.removeWhere(
      (item) => item.product.id == productId,
    );

    notifyListeners();
  }

  void clearCart() {
    _cart.clear();

    notifyListeners();
  }

  // ============================================================
  // ORDERS / CHECKOUT
  // ============================================================

  Future<void> checkoutCurrentCart({
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    for (final item in _cart) {
      final newOrder = await ApiService.createOrder(
        userId: _currentUser?.id ?? 2,
        productId: item.product.id,
        quantity: item.quantity,
        totalPrice: item.totalPrice,
        productName: item.product.name,
        artisanName: item.product.sellerName,
      );

      _orders.insert(0, newOrder);
    }

    clearCart();

    notifyListeners();
  }

  // ============================================================
  // ARTISAN PRODUCT UPLOAD
  // ============================================================

  Future<void> publishProduct(
    ProductModel newProduct,
  ) async {
    final created = await ApiService.createProduct(newProduct);

    _products.insert(0, created);

    notifyListeners();
  }

  // ============================================================
  // LANGUAGE
  // ============================================================

  void setLanguage(String code) {
    _selectedLanguage = code;

    notifyListeners();
  }
}