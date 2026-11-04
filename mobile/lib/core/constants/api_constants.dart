import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConstants {
  // Candidate hosts for phone connection:
  // 1. 127.0.0.1 (High-speed USB ADB reverse forwarding)
  // 2. 192.168.1.14 (Local Wi-Fi IP of development PC)
  // 3. 10.0.2.2 (Android Emulator host loopback)
  static const List<String> candidateHosts = [
    '127.0.0.1',
    '192.168.1.14',
    '10.0.2.2',
  ];
  static const int serverPort = 5000;
  static String? _cachedBaseUrl;

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:$serverPort';
    try {
      if (Platform.isAndroid) return 'http://127.0.0.1:$serverPort';
    } catch (_) {}
    return 'http://localhost:$serverPort';
  }

  // Active base URL for all API requests
  static String get baseUrl => _cachedBaseUrl ?? defaultBaseUrl;

  // Quickly resolves which host is actively reachable (< 800ms)
  static Future<String> resolveActiveBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    for (final host in candidateHosts) {
      final testUrl = 'http://$host:$serverPort';
      try {
        final client = http.Client();
        final uri = Uri.parse('$testUrl/api/products?limit=1');
        final response = await client.get(uri).timeout(const Duration(milliseconds: 900));
        client.close();
        if (response.statusCode >= 200 && response.statusCode < 500) {
          _cachedBaseUrl = testUrl;
          debugPrint('[ApiClient] Connected successfully to: $testUrl');
          return testUrl;
        }
      } catch (_) {}
    }

    _cachedBaseUrl = defaultBaseUrl;
    return _cachedBaseUrl!;
  }

  // API Endpoints
  static String get authRegister => '$baseUrl/api/auth/register';
  static String get authLogin => '$baseUrl/api/auth/login';
  static String get authLogout => '$baseUrl/api/auth/logout';
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
