import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _dio.options
      ..baseUrl = 'http://localhost:8000'
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers = {'Content-Type': 'application/json'};
  }

  Future<Response> request(
    String path, {
    required String method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    if (requiresAuth) {
      final token = await _secureStorage.read(key: 'access_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return _dio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(method: method),
    );
  }
}