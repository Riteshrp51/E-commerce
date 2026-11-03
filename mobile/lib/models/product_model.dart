class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> images;
  final double price;
  final double? offerPrice;
  final String category;
  final int stock;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.images,
    required this.price,
    this.offerPrice,
    required this.category,
    required this.stock,
    required this.inStock,
  });

  double get effectivePrice =>
      (offerPrice != null && offerPrice! > 0) ? offerPrice! : price;

  bool get hasDiscount =>
      offerPrice != null && offerPrice! > 0 && offerPrice! < price;

  int get discountPercent =>
      hasDiscount ? (((price - offerPrice!) / price) * 100).round() : 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    }

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      images: parsedImages,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      category: json['category'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      inStock: json['inStock'] ?? ((json['stock'] as num?)?.toInt() ?? 0) > 0,
    );
  }
}

