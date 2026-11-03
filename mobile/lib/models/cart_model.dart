class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final double? offerPrice;
  final double unitPrice;
  final String imageUrl;
  final String category;
  final int stock;
  final bool inStock;
  final int quantity;
  final double itemTotal;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.offerPrice,
    required this.unitPrice,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.inStock,
    required this.quantity,
    required this.itemTotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      inStock: json['inStock'] ?? true,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      itemTotal: (json['itemTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final int totalItems;
  final double subtotal;
  final double shippingFee;
  final double total;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalItems,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
  });

  factory CartModel.empty() {
    return CartModel(
      id: '',
      userId: '',
      items: [],
      totalItems: 0,
      subtotal: 0.0,
      shippingFee: 0.0,
      total: 0.0,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<CartItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return CartModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      items: parsedItems,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

