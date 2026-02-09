import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/blood_pressure_model.dart';

abstract class BloodPressureRemoteDataSource {
  Future<List<BloodPressureModel>> getRecords();
  Future<BloodPressureModel> addRecord(Map<String, dynamic> data);
  Future<BloodPressureModel> getRecord(String id);
  Future<void> deleteRecord(String id);
  Future<Map<String, dynamic>> getStatistics({String? period});
}

class BloodPressureRemoteDataSourceImpl implements BloodPressureRemoteDataSource {
  final ApiClient apiClient;

  BloodPressureRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<BloodPressureModel>> getRecords() async {
    final response = await apiClient.get(ApiConstants.bloodPressure);
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => BloodPressureModel.fromJson(json)).toList();
  }

  @override
  Future<BloodPressureModel> addRecord(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.bloodPressure, body: data);
    final recordData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return BloodPressureModel.fromJson(recordData);
  }

  @override
  Future<BloodPressureModel> getRecord(String id) async {
    final response = await apiClient.get('${ApiConstants.bloodPressure}/$id');
    final recordData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return BloodPressureModel.fromJson(recordData);
  }

  @override
  Future<void> deleteRecord(String id) async {
    await apiClient.delete('${ApiConstants.bloodPressure}/$id');
  }

  @override
  Future<Map<String, dynamic>> getStatistics({String? period}) async {
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;
    final response = await apiClient.get(
      ApiConstants.bloodPressureStats,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    return response is Map<String, dynamic> ? response : {};
  }
}
