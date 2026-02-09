import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/food_model.dart';
import '../models/food_record_model.dart';
import '../models/meal_plan_model.dart';

abstract class NutritionRemoteDataSource {
  Future<List<FoodModel>> getFoods({String? category, String? sodiumLevel});
  Future<FoodModel> getFood(String id);
  Future<List<FoodRecordModel>> getFoodLogs();
  Future<FoodRecordModel> addFoodLog(Map<String, dynamic> data);
  Future<void> deleteFoodLog(String id);
  Future<List<MealPlanModel>> getMealPlans();
  Future<MealPlanModel> createMealPlan(Map<String, dynamic> data);
  Future<MealPlanModel> getMealPlan(String id);
  Future<MealPlanModel> updateMealPlan(String id, Map<String, dynamic> data);
  Future<void> deleteMealPlan(String id);
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  final ApiClient apiClient;

  NutritionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<FoodModel>> getFoods({String? category, String? sodiumLevel}) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (sodiumLevel != null) queryParams['sodium_level'] = sodiumLevel;
    final response = await apiClient.get(
      ApiConstants.foods,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => FoodModel.fromJson(json)).toList();
  }

  @override
  Future<FoodModel> getFood(String id) async {
    final response = await apiClient.get('${ApiConstants.foods}/$id');
    final foodData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return FoodModel.fromJson(foodData);
  }

  @override
  Future<List<FoodRecordModel>> getFoodLogs() async {
    final response = await apiClient.get(ApiConstants.foodLogs);
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => FoodRecordModel.fromJson(json)).toList();
  }

  @override
  Future<FoodRecordModel> addFoodLog(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.foodLogs, body: data);
    final logData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return FoodRecordModel.fromJson(logData);
  }

  @override
  Future<void> deleteFoodLog(String id) async {
    await apiClient.delete('${ApiConstants.foodLogs}/$id');
  }

  @override
  Future<List<MealPlanModel>> getMealPlans() async {
    final response = await apiClient.get(ApiConstants.mealPlans);
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => MealPlanModel.fromJson(json)).toList();
  }

  @override
  Future<MealPlanModel> createMealPlan(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.mealPlans, body: data);
    final planData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MealPlanModel.fromJson(planData);
  }

  @override
  Future<MealPlanModel> getMealPlan(String id) async {
    final response = await apiClient.get('${ApiConstants.mealPlans}/$id');
    final planData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MealPlanModel.fromJson(planData);
  }

  @override
  Future<MealPlanModel> updateMealPlan(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put('${ApiConstants.mealPlans}/$id', body: data);
    final planData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return MealPlanModel.fromJson(planData);
  }

  @override
  Future<void> deleteMealPlan(String id) async {
    await apiClient.delete('${ApiConstants.mealPlans}/$id');
  }
}
