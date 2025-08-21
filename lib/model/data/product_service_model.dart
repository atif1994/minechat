class ProductServiceModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final String category;
  final String features;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? selectedImage; // ✅ Plain string, not Rx

  ProductServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.features,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.selectedImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'features': features,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'selectedImage': selectedImage ?? '',
    };
  }

  factory ProductServiceModel.fromMap(Map<String, dynamic> map) {
    return ProductServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      category: map['category'] ?? '',
      features: map['features'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      selectedImage: map['selectedImage'], // ✅ plain string
    );
  }

  ProductServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? price,
    String? category,
    String? features,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? selectedImage,
  }) {
    return ProductServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      features: features ?? this.features,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}
