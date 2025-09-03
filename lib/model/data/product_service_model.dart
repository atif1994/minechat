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

  /// Legacy single image (keep for backward compatibility / primary image)
  final String? selectedImage;

  /// New: multiple images
  final List<String> images;

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
    this.images = const [], // default empty list
  });

  // ---- Helpers ----
  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    // Firestore Timestamp support
    try {
      // Avoid importing firebase here; use duck-typing
      final maybeToDate = (v as dynamic).toDate;
      if (maybeToDate is Function) return (v as dynamic).toDate() as DateTime;
    } catch (_) {}
    // String ISO support
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  static List<String> _parseImages(dynamic v) {
    if (v is List) {
      return v.whereType<String>().toList();
    }
    return const [];
  }

  // ---- Serialization ----
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'features': features,
      'userId': userId,
      // Keep ISO strings for compatibility; if you prefer Firestore Timestamps,
      // set them in the controller when writing.
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'selectedImage': selectedImage ?? '',
      'images': images, // 👈 new field
    };
  }

  factory ProductServiceModel.fromMap(Map<String, dynamic> map) {
    final parsedImages = _parseImages(map['images']);

    return ProductServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      category: map['category'] ?? '',
      features: map['features'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      selectedImage: (map['selectedImage'] is String &&
              (map['selectedImage'] as String).isNotEmpty)
          ? map['selectedImage'] as String
          : null,
      // normalize empty string -> null
      images: parsedImages,
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
    List<String>? images,
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
      images: images ?? this.images,
    );
  }
}
