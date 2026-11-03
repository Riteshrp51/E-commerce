import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Your PC's Wi-Fi IP address for physical Android devices
  // (Or run 'adb reverse tcp:5000 tcp:5000' in cmd to use localhost)
  static const String serverHost = '192.168.1.14';
  static const int serverPort = 5000;

  // Configurable base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    }
    try {
      if (Platform.isAndroid) {
        // Physical phone or emulator on local Wi-Fi
        return 'http://$serverHost:$serverPort';
      }
    } catch (_) {}
    return 'http://localhost:$serverPort';
  }

  // API Endpoints
  static String get authRegister => '$baseUrl/api/auth/register';
  static String get authLogin => '$baseUrl/api/auth/login';
  static String get authMe => '$baseUrl/api/auth/me';

  static String get products => '$baseUrl/api/products';
  static String get categories => '$baseUrl/api/products/categories';
  static String productDetails(String id) => '$baseUrl/api/products/$id';

  static String get cart => '$baseUrl/api/cart';
  static String get cartItems => '$baseUrl/api/cart/items';
  static String cartItem(String id) => '$baseUrl/api/cart/items/$id';

  static String get orders => '$baseUrl/api/orders';
  static String orderDetails(String id) => '$baseUrl/api/orders/$id';

  // Helper to format full image URL (handles relative path like /assets/...)
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }
}

