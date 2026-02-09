import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<List<MedicationModel>> getMedications();
  Future<MedicationModel> createMedication(Map<String, dynamic> data);
  Future<MedicationModel> getMedication(String id);
  Future<MedicationModel> updateMedication(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deleteMedication(String id);
  // Alarms
  Future<MedicationAlarmModel> createAlarm(
    String medicationId,
    Map<String, dynamic> data,
  );
  Future<MedicationAlarmModel> updateAlarm(
    String alarmId,
    Map<String, dynamic> data,
  );
  Future<void> deleteAlarm(String alarmId);
  // Logs
  Future<List<MedicationLogModel>> getMedicationLogs(String medicationId);
  Future<MedicationLogModel> createMedicationLog(
    String medicationId,
    Map<String, dynamic> data,
  );
  // Adherence
  Future<Map<String, dynamic>> getAdherence({String? period});
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final ApiClient apiClient;

  MedicationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MedicationModel>> getMedications() async {
    final response = await apiClient.get(ApiConstants.medications);
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => MedicationModel.fromJson(json)).toList();
  }

  @override
  Future<MedicationModel> createMedication(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.medications, body: data);
    final medData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MedicationModel.fromJson(medData);
  }

  @override
  Future<MedicationModel> getMedication(String id) async {
    final response = await apiClient.get('${ApiConstants.medications}/$id');
    final medData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MedicationModel.fromJson(medData);
  }

  @override
  Future<MedicationModel> updateMedication(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.medications}/$id',
      body: data,
    );
    final medData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MedicationModel.fromJson(medData);
  }

  @override
  Future<void> deleteMedication(String id) async {
    await apiClient.delete('${ApiConstants.medications}/$id');
  }

  @override
  Future<MedicationAlarmModel> createAlarm(
    String medicationId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.medications}/$medicationId/alarms',
      body: data,
    );
    final alarmData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MedicationAlarmModel.fromJson(alarmData);
  }

  @override
  Future<MedicationAlarmModel> updateAlarm(
    String alarmId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      '${ApiConstants.medicationAlarms}/$alarmId',
      body: data,
    );
    final alarmData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MedicationAlarmModel.fromJson(alarmData);
  }

  @override
  Future<void> deleteAlarm(String alarmId) async {
    await apiClient.delete('${ApiConstants.medicationAlarms}/$alarmId');
  }

  @override
  Future<List<MedicationLogModel>> getMedicationLogs(
    String medicationId,
  ) async {
    final response = await apiClient.get(
      '${ApiConstants.medications}/$medicationId/logs',
    );
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => MedicationLogModel.fromJson(json)).toList();
  }

  @override
  Future<MedicationLogModel> createMedicationLog(
    String medicationId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post(
      '${ApiConstants.medications}/$medicationId/logs',
      body: data,
    );
    final logData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MedicationLogModel.fromJson(logData);
  }

  @override
  Future<Map<String, dynamic>> getAdherence({String? period}) async {
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;
    final response = await apiClient.get(
      ApiConstants.medicationAdherence,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    return response is Map<String, dynamic> ? response : {};
  }
}
