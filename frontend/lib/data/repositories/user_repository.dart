import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../models/user_model.dart';


class UserRepository {
  final ApiClient _apiClient;

  UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<UserModel> fetchCurrentUser() async {
    try {
      final response = await _apiClient.request(
        '/users/me',
        method: 'GET',
        requiresAuth: true,
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch user');
    }
  }

  Future<UserModel> updateCurrency(String currency) async {
    try {
      final response = await _apiClient.request(
        '/users/settings',
        method: 'PATCH',
        data: {'default_currency': currency},
        requiresAuth: true,
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update currency');
    }
  }
}