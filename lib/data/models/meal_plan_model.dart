import '../../domain/entities/meal_plan.dart';

class MealPlanModel extends MealPlan {
  const MealPlanModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.breakfast,
    required super.lunch,
    required super.dinner,
    required super.snacks,
    required super.totalSodiumMg,
    required super.totalPotassiumMg,
    required super.totalCalories,
    required super.date,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: 'Plan semanal',
      description: json['notes'] ?? '',
      breakfast: const [],
      lunch: const [],
      dinner: const [],
      snacks: const [],
      totalSodiumMg: 0,
      totalPotassiumMg: 0,
      totalCalories: 0,
      date: json['week_start'] != null
          ? DateTime.parse(json['week_start'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_start':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'notes': description,
    };
  }

  factory MealPlanModel.fromEntity(MealPlan entity) {
    return MealPlanModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      breakfast: entity.breakfast,
      lunch: entity.lunch,
      dinner: entity.dinner,
      snacks: entity.snacks,
      totalSodiumMg: entity.totalSodiumMg,
      totalPotassiumMg: entity.totalPotassiumMg,
      totalCalories: entity.totalCalories,
      date: entity.date,
    );
  }
}
