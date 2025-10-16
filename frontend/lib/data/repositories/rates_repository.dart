import '../../core/api_client.dart';


class RatesRepository {
  final ApiClient _apiClient;

  RatesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<double> getRate(String base, String target) async {
    final response = await _apiClient.request(
      '/rates',
      method: 'GET',
      queryParameters: {'base': base, 'target': target},
    );
    return (response.data['rate'] as num).toDouble();
  }

  Future<Map<String, double>> getAllRates(String base) async {
    final response = await _apiClient.request(
      '/rates/all',
      method: 'GET',
      queryParameters: {'base': base},
    );

    final Map<String, dynamic> raw = response.data['rates'];
    return raw.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
}