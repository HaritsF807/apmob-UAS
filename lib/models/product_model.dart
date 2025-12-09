class Product {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final String? categoryId;
  final String? categoryName;
  final String? image;
  final String status; // 'available' or 'unavailable'
  final List<ProductVariant>? variants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    this.categoryName,
    this.image,
    this.status = 'available',
    this.variants,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] is String) 
          ? double.tryParse(json['price']) ?? 0.0 
          : (json['price']?.toDouble() ?? 0.0),
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'] ?? json['category']?['name'],
      image: json['image'],
      status: json['status'] ?? 'available',
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((v) => ProductVariant.fromJson(v))
              .toList()
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      if (categoryId != null) 'category_id': categoryId,
      if (image != null) 'image': image,
      'status': status,
      if (variants != null) 'variants': variants!.map((v) => v.toJson()).toList(),
    };
  }

  bool get isActive => status == 'available';
}

class ProductVariant {
  final String? id;
  final String name;
  final double additionalPrice;

  ProductVariant({
    this.id,
    required this.name,
    this.additionalPrice = 0.0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      additionalPrice: (json['additional_price'] is String)
          ? double.tryParse(json['additional_price']) ?? 0.0
          : (json['additional_price']?.toDouble() ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'additional_price': additionalPrice,
    };
  }
}
