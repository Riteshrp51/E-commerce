class OrderItemSnapshot {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItemSnapshot({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get itemTotal => price * quantity;

  factory OrderItemSnapshot.fromJson(Map<String, dynamic> json) {
    return OrderItemSnapshot(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

class DeliveryAddressModel {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;

  DeliveryAddressModel({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  String get formattedAddress => '$street, $city, $state - $postalCode';

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemSnapshot> items;
  final DeliveryAddressModel deliveryAddress;
  final double totalAmount;
  final String status; // 'Pending', 'Processing', 'Shipped', 'Delivered'
  final String paymentType;
  final bool isPaid;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.status,
    required this.paymentType,
    required this.isPaid,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<OrderItemSnapshot> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => OrderItemSnapshot.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: parsedItems,
      deliveryAddress: DeliveryAddressModel.fromJson(
        json['deliveryAddress'] as Map<String, dynamic>? ?? {},
      ),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      paymentType: json['paymentType'] ?? 'COD',
      isPaid: json['isPaid'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

