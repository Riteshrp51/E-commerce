import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String customHostPrefKey = 'dailymart_custom_server_host';

  // Candidate hosts for phone connection:
  // 1. 127.0.0.1 (USB Cable with ADB reverse forwarding - works 100% on Mobile Data without Wi-Fi!)
  // 2. 172.16.20.148 (Current Ethernet IP)
  // 3. 10.71.196.29 (Wi-Fi IP)
  // 4. 10.0.2.2 (Android Emulator host loopback)
  static const List<String> candidateHosts = [
    '127.0.0.1',
    '172.16.20.148',
    '10.71.196.29',
    '10.0.2.2',
  ];
  static const int serverPort = 5000;
  static String? _cachedBaseUrl;

  static String get defaultBaseUrl => 'http://127.0.0.1:$serverPort';

  // Active base URL for all API requests
  static String get baseUrl => _cachedBaseUrl ?? defaultBaseUrl;

  static void setBaseUrl(String url) {
    _cachedBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  // Probe a single URL quickly
  static Future<bool> probeUrl(String url) async {
    try {
      final cleanUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
      final client = http.Client();
      final uri = Uri.parse('$cleanUrl/api/products?limit=1');
      final response = await client
          .get(uri)
          .timeout(const Duration(milliseconds: 1500));
      client.close();
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  // Test and save custom server address
  static Future<bool> testAndSaveHost(String hostOrUrl) async {
    String formattedUrl = hostOrUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      if (!formattedUrl.contains(':')) {
        formattedUrl = 'http://$formattedUrl:$serverPort';
      } else {
        formattedUrl = 'http://$formattedUrl';
      }
    }

    final isOk = await probeUrl(formattedUrl);
    if (isOk) {
      _cachedBaseUrl = formattedUrl;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(customHostPrefKey, formattedUrl);
      } catch (_) {}
      return true;
    }
    return false;
  }

  // Quickly resolves which host is actively reachable
  static Future<String> resolveActiveBaseUrl({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }

    // 1. Check custom saved host from SharedPreferences first
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(customHostPrefKey);
      if (saved != null && saved.isNotEmpty) {
        final isOk = await probeUrl(saved);
        if (isOk) {
          _cachedBaseUrl = saved;
          debugPrint('[ApiClient] Using saved custom server host: $saved');
          return saved;
        }
      }
    } catch (_) {}

    // 2. Probe candidate hosts starting with 127.0.0.1 (USB)
    for (final host in candidateHosts) {
      final testUrl = host.startsWith('http') ? host : 'http://$host:$serverPort';
      final ok = await probeUrl(testUrl);
      if (ok) {
        _cachedBaseUrl = testUrl;
        debugPrint('[ApiClient] Connected successfully to: $testUrl');
        return testUrl;
      }
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
  static String orderStatus(String id) => '$baseUrl/api/orders/$id/status';

  // Construct absolute image URL
  static String resolveImageUrl(String? relativePath) => getImageUrl(relativePath);

  static String getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    final cleanPath = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$baseUrl$cleanPath';
  }
}
