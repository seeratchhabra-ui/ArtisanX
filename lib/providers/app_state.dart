import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';

class AppState extends ChangeNotifier {
  // Authentication & Role
  UserRoleType _currentRole = UserRoleType.artisan;
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  // Voice Assistant Active/Listening State (Controls Multi-Ring Ripple Animation)
  bool _isVoiceAssistantActive = false;

  // Products
  List<ProductModel> _products = [];
  bool _isLoadingProducts = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Orders
  List<OrderModel> _orders = [];
  bool _isLoadingOrders = false;

  // Cart
  final List<CartItemModel> _cart = [];

  // Likes & Wishlist
  final Set<int> _likedProductIds = {101};

  // Language for Bhashini
  String _selectedLanguage = 'hi';

  // Getters
  UserRoleType get currentRole => _currentRole;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isArtisan => _currentRole == UserRoleType.artisan;
  bool get isCustomer => _currentRole == UserRoleType.customer;

  bool get isVoiceAssistantActive => _isVoiceAssistantActive;

  List<ProductModel> get allProducts => _products;
  bool get isLoadingProducts => _isLoadingProducts;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<OrderModel> get orders => _orders;
  bool get isLoadingOrders => _isLoadingOrders;

  List<CartItemModel> get cart => _cart;
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartSubtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get cartTotal => cartSubtotal; // Free delivery in promotion

  String get selectedLanguage => _selectedLanguage;

  AppState() {
    _initApp();
  }

  void _initApp() async {
    // 1. Load initial offline seeds for fast immediate rendering
    _products = MockDataService.getInitialProducts();
    _orders = MockDataService.getInitialOrders();
    _currentUser = MockDataService.defaultArtisanUser;

    // Seed initial cart matching Figma design (Indigo Serving Bowl + Moonj Storage Basket)
    final bowl = _products.firstWhere(
      (p) => p.id == 101,
      orElse: () => _products[0],
    );
    final basket = _products.firstWhere(
      (p) => p.id == 102,
      orElse: () => _products.length > 1 ? _products[1] : _products[0],
    );
    _cart.add(CartItemModel(product: bowl, quantity: 1));
    _cart.add(CartItemModel(product: basket, quantity: 1));

    // 2. Fetch live data from backend
    await refreshAll();
  }

  /// Refreshes both products and orders from backend
  Future<void> refreshAll() async {
    await Future.wait([
      fetchProductsFromBackend(),
      fetchOrdersFromBackend(),
    ]);
  }

  // --- Voice Assistant State Management ---

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

  // --- Auth & Role Methods ---

  void setRole(UserRoleType role) {
    _currentRole = role;
    if (role == UserRoleType.artisan) {
      _currentUser = MockDataService.defaultArtisanUser;
    } else {
      _currentUser = MockDataService.defaultCustomerUser;
    }
    notifyListeners();
    fetchOrdersFromBackend();
  }

  Future<bool> loginWithOtp(String phone, String otp) async {
    try {
      final user = await ApiService.loginWithOtp(
        phone: phone,
        otp: otp,
        preferredRole: _currentRole,
      );
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      await refreshAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    ApiService.authToken = null;
    notifyListeners();
  }

  // --- Products Backend Fetch & Sync ---

  Future<void> fetchProductsFromBackend() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final backendProducts = await ApiService.fetchProducts();
      if (backendProducts.isNotEmpty) {
        _products = backendProducts;
      }
    } catch (e) {
      // Retain existing products on network error
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrdersFromBackend() async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      final backendOrders = await ApiService.fetchOrders();
      if (backendOrders.isNotEmpty) {
        _orders = backendOrders;
      }
    } catch (e) {
      // Retain existing orders
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  // --- Category & Search ---

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
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // --- Wishlist ---

  bool isLiked(int productId) => _likedProductIds.contains(productId);

  void toggleLike(int productId) {
    if (_likedProductIds.contains(productId)) {
      _likedProductIds.remove(productId);
    } else {
      _likedProductIds.add(productId);
    }
    notifyListeners();
  }

  // --- Cart Management ---

  void addToCart(ProductModel product, {int quantity = 1}) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cart[index].quantity += quantity;
    } else {
      _cart.add(CartItemModel(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateCartQuantity(int productId, int delta) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
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
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // --- Order Management ---

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

  // --- Artisan Product Upload ---

  Future<void> publishProduct(ProductModel newProduct) async {
    final created = await ApiService.createProduct(newProduct);
    _products.insert(0, created);
    notifyListeners();
  }

  // --- Language for Bhashini ---

  void setLanguage(String code) {
    _selectedLanguage = code;
    notifyListeners();
  }
}
