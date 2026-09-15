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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Craft',
      stock: json['stock'] ?? 10,
      state: json['state'] ?? 'Rajasthan',
      sellerId: json['seller_id'] ?? 1,
      sellerName: json['seller_name'] ?? 'Asha Devi',
      sellerTitle: json['seller_title'] ?? 'Master Potter',
      sellerLocation: json['seller_location'] ?? 'Jaipur',
      imageUrl: json['image_url'] ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      material: json['material'] ?? 'Terracotta',
      madeIn: json['made_in'] ?? 'Jaipur, Rajasthan',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: json['review_count'] ?? 14,
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
