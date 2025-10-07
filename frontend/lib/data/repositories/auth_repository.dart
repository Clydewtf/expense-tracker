import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';


class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    required FlutterSecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  Future<void> register(String email, String password) async {
    try {
      await _apiClient.request(
        '/users/',
        method: 'POST',
        data: {'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.request(
        '/users/login',
        method: 'POST',
        data: {'email': email, 'password': password},
      );

      final token = response.data['access_token'] as String?;
      if (token != null) {
        await _secureStorage.write(key: 'access_token', value: token);
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['detail'] ?? 'Error: ${e.response?.statusCode}';
    }
    return 'Connection error';
  }
}