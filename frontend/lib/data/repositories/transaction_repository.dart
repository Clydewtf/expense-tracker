import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../data/models/transaction_model.dart';


class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<TransactionModel>> getTransactions({required int userId}) async {
    try {
      final response = await _apiClient.request(
        '/transactions/',
        method: 'GET',
        queryParameters: {'user_id': userId},
        requiresAuth: true,
      );

      final data = response.data as List;
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch transactions');
    }
  }

  Future<TransactionModel> getTransactionById(int id) async {
    try {
      final response = await _apiClient.request(
        '/transactions/$id',
        method: 'GET',
        requiresAuth: true,
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch transaction');
    }
  }

  Future<TransactionModel> addTransaction(TransactionModel txn) async {
    try {
      final response = await _apiClient.request(
        '/transactions',
        method: 'POST',
        data: txn.toJson(),
        requiresAuth: true,
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to add transaction');
    }
  }

  Future<TransactionModel> updateTransaction(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.request(
        '/transactions/$id',
        method: 'PUT',
        data: updates,
        requiresAuth: true,
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _apiClient.request(
        '/transactions/$id',
        method: 'DELETE',
        requiresAuth: true,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete transaction');
    }
  }
}