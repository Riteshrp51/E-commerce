import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel _cart = CartModel.empty();
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  CartModel get cart => _cart;
  List<CartItemModel> get items => _cart.items;
  int get itemCount => _cart.totalItems;
  double get subtotal => _cart.subtotal;
  double get shippingFee => _cart.shippingFee;
  double get total => _cart.total;
  bool get isEmpty => _cart.items.isEmpty;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  bool isInCart(String productId) {
    return _cart.items.any((item) => item.productId == productId);
  }

  int getQuantity(String productId) {
    final item = _cart.items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        id: '',
        productId: '',
        name: '',
        price: 0,
        unitPrice: 0,
        imageUrl: '',
        category: '',
        stock: 0,
        inStock: false,
        quantity: 0,
        itemTotal: 0,
      ),
    );
    return item.quantity;
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.fetchCart();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(ProductModel product, {int quantity = 1}) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.addToCart(
        productId: product.id,
        quantity: quantity,
      );
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity(String productId, int newQuantity) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (newQuantity <= 0) {
        _cart = await _cartService.removeItem(productId);
      } else {
        _cart = await _cartService.updateQuantity(
          productId: productId,
          quantity: newQuantity,
        );
      }
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(String productId) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.removeItem(productId);
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  void clearLocalCart() {
    _cart = CartModel.empty();
    notifyListeners();
  }
}

