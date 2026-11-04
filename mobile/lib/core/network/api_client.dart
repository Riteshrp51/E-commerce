import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static const String tokenKey = 'dailymart_jwt_token';
  static const Duration requestTimeout = Duration(seconds: 8);

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String errorMessage = 'An error occurred. Please try again.';
      if (body is Map && body['message'] != null) {
        errorMessage = body['message'].toString();
      } else if (response.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (response.statusCode == 404) {
        errorMessage = 'Requested resource not found.';
      } else if (response.statusCode >= 500) {
        errorMessage = 'Server error. Please try again later.';
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  static Future<dynamic> get(String url, {bool requireAuth = false}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(requestTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please ensure the backend server is running.');
    } on http.ClientException {
      throw ApiException('Network request failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  static Future<dynamic> post(String url, {Map<String, dynamic>? body, bool requireAuth = false}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please ensure the backend server is running.');
    } on http.ClientException {
      throw ApiException('Network request failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  static Future<dynamic> patch(String url, {Map<String, dynamic>? body, bool requireAuth = false}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please ensure the backend server is running.');
    } on http.ClientException {
      throw ApiException('Network request failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  static Future<dynamic> delete(String url, {bool requireAuth = false}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(requestTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timed out. Please ensure the backend server is running.');
    } on http.ClientException {
      throw ApiException('Network request failed.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
