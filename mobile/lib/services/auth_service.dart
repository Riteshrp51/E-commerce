import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.authRegister,
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response['token'] != null) {
      await ApiClient.saveToken(response['token']);
    }

    return {
      'user': UserModel.fromJson(response['user']),
      'token': response['token'],
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.authLogin,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response['token'] != null) {
      await ApiClient.saveToken(response['token']);
    }

    return {
      'user': UserModel.fromJson(response['user']),
      'token': response['token'],
    };
  }

  Future<UserModel?> getProfile() async {
    final token = await ApiClient.getToken();
    if (token == null || token.isEmpty) return null;

    final response = await ApiClient.get(
      ApiConstants.authMe,
      requireAuth: true,
    );

    return UserModel.fromJson(response['user']);
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
  }
}

