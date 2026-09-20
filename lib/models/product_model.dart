class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int stock;
  final String state;
  final int sellerId;
  final String sellerName;
  final String sellerTitle;
  final String sellerLocation;
  final String imageUrl;
  final List<String> tags;
  final String material;
  final String madeIn;
  final double rating;
  final int reviewCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.state,
    required this.sellerId,
    required this.sellerName,
    this.sellerTitle = 'Master Craftsman',
    required this.sellerLocation,
    required this.imageUrl,
    this.tags = const [],
    this.material = 'Handcrafted Natural Material',
    this.madeIn = 'India',
    this.rating = 4.9,
    this.reviewCount = 28,
  });

  // Safely converts backend values that may arrive as:
  // - int
  // - double
  // - String
  static double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? fallback;
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? fallback;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _toInt(json['id']),

      name: json['name']?.toString() ?? '',

      description: json['description']?.toString() ?? '',

      // Handles both:
      // "1499.00"
      // 1499
      // 1499.00
      price: _toDouble(
        json['price'],
        fallback: 0.0,
      ),

      category: json['category']?.toString() ?? 'Craft',

      stock: _toInt(
        json['stock'],
        fallback: 10,
      ),

      state: json['state']?.toString() ?? 'Rajasthan',

      sellerId: _toInt(
        json['seller_id'],
        fallback: 1,
      ),

      sellerName:
          json['seller_name']?.toString() ?? 'Artisan',

      sellerTitle:
          json['seller_title']?.toString() ?? 'Master Potter',

      sellerLocation:
          json['seller_location']?.toString() ?? 'Jaipur',

      imageUrl:
          json['image_url']?.toString() ?? '',

      tags: json['tags'] is List
          ? (json['tags'] as List)
              .map((e) => e.toString())
              .toList()
          : [],

      material:
          json['material']?.toString() ?? 'Terracotta',

      madeIn:
          json['made_in']?.toString() ??
              'Jaipur, Rajasthan',

      // Handles both numbers and numeric strings.
      rating: _toDouble(
        json['rating'],
        fallback: 4.9,
      ),

      reviewCount: _toInt(
        json['review_count'],
        fallback: 14,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'state': state,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_title': sellerTitle,
      'seller_location': sellerLocation,
      'image_url': imageUrl,
      'tags': tags,
      'material': material,
      'made_in': madeIn,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? category,
    int? stock,
    String? state,
    int? sellerId,
    String? sellerName,
    String? sellerTitle,
    String? sellerLocation,
    String? imageUrl,
    List<String>? tags,
    String? material,
    String? madeIn,
    double? rating,
    int? reviewCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      state: state ?? this.state,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerTitle: sellerTitle ?? this.sellerTitle,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      material: material ?? this.material,
      madeIn: madeIn ?? this.madeIn,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}