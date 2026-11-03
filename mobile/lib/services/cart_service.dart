import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartService {
  Future<CartModel> fetchCart() async {
    final response = await ApiClient.get(
      ApiConstants.cart,
      requireAuth: true,
    );
    return CartModel.fromJson(response['data']);
  }

  Future<CartModel> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.cartItems,
      body: {
        'productId': productId,
        'quantity': quantity,
      },
      requireAuth: true,
    );
    return CartModel.fromJson(response['data']);
  }

  Future<CartModel> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    final response = await ApiClient.patch(
      ApiConstants.cartItem(productId),
      body: {'quantity': quantity},
      requireAuth: true,
    );
    return CartModel.fromJson(response['data']);
  }

  Future<CartModel> removeItem(String productId) async {
    final response = await ApiClient.delete(
      ApiConstants.cartItem(productId),
      requireAuth: true,
    );
    return CartModel.fromJson(response['data']);
  }

  Future<void> clearCart() async {
    await ApiClient.delete(
      ApiConstants.cart,
      requireAuth: true,
    );
  }
}

