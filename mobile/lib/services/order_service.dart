import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  Future<OrderModel> placeOrder({
    required DeliveryAddressModel deliveryAddress,
    String paymentType = 'COD',
  }) async {
    final response = await ApiClient.post(
      ApiConstants.orders,
      body: {
        'deliveryAddress': deliveryAddress.toJson(),
        'paymentType': paymentType,
      },
      requireAuth: true,
    );
    return OrderModel.fromJson(response['data']);
  }

  Future<List<OrderModel>> fetchOrders() async {
    final response = await ApiClient.get(
      ApiConstants.orders,
      requireAuth: true,
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> fetchOrderById(String orderId) async {
    final response = await ApiClient.get(
      ApiConstants.orderDetails(orderId),
      requireAuth: true,
    );
    return OrderModel.fromJson(response['data']);
  }
}

