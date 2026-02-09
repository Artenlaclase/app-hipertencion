import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';

abstract class HabitRemoteDataSource {
  Future<List<HabitModel>> getHabits();
  Future<HabitModel> getHabit(String id);
  Future<List<HabitLogModel>> getHabitLogs();
  Future<HabitLogModel> addHabitLog(Map<String, dynamic> data);
  Future<void> deleteHabitLog(String id);
  Future<Map<String, dynamic>> getStreaks();
  Future<Map<String, dynamic>> getHabitStreak(String habitId);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final ApiClient apiClient;

  HabitRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<HabitModel>> getHabits() async {
    final response = await apiClient.get(ApiConstants.habits);
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => HabitModel.fromJson(json)).toList();
  }

  @override
  Future<HabitModel> getHabit(String id) async {
    final response = await apiClient.get('${ApiConstants.habits}/$id');
    final habitData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return HabitModel.fromJson(habitData);
  }

  @override
  Future<List<HabitLogModel>> getHabitLogs() async {
    final response = await apiClient.get(ApiConstants.habitLogs);
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => HabitLogModel.fromJson(json)).toList();
  }

  @override
  Future<HabitLogModel> addHabitLog(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.habitLogs, body: data);
    final logData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return HabitLogModel.fromJson(logData);
  }

  @override
  Future<void> deleteHabitLog(String id) async {
    await apiClient.delete('${ApiConstants.habitLogs}/$id');
  }

  @override
  Future<Map<String, dynamic>> getStreaks() async {
    final response = await apiClient.get(ApiConstants.habitStreaks);
    return response is Map<String, dynamic> ? response : {};
  }

  @override
  Future<Map<String, dynamic>> getHabitStreak(String habitId) async {
    final response = await apiClient.get('${ApiConstants.habitStreaks}/$habitId');
    return response is Map<String, dynamic> ? response : {};
  }
}
