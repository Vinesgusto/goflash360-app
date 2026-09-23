import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthService({
    required this.apiClient,
    required this.tokenStorage,
  });

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final Response response = await apiClient.dio.post(
      'auth/login/',
      data: {
        'username': username,
        'password': password,
      },
    );

    final String access = response.data['access'];
    final String refresh = response.data['refresh'];

    await tokenStorage.saveTokens(
      access: access,
      refresh: refresh,
    );
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final Response response = await apiClient.dio.get(
      'auth/me/',
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }
}