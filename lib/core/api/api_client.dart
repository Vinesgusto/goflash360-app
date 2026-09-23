import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

class ApiClient {
  final TokenStorage tokenStorage;

  late final Dio dio;

  ApiClient({
    required this.tokenStorage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await tokenStorage.getAccessToken();

          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          handler.next(options);
        },
      ),
    );
  }
}