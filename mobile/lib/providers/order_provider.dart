import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  OrderModel? _lastPlacedOrder;
  bool _isLoading = false;
  bool _isPlacingOrder = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  OrderModel? get lastPlacedOrder => _lastPlacedOrder;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.fetchOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.fetchOrderById(orderId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder({
    required DeliveryAddressModel deliveryAddress,
    String paymentType = 'COD',
  }) async {
    _isPlacingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.placeOrder(
        deliveryAddress: deliveryAddress,
        paymentType: paymentType,
      );
      _lastPlacedOrder = order;
      _orders.insert(0, order);
      _isPlacingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isPlacingOrder = false;
      notifyListeners();
      return false;
    }
  }
}

