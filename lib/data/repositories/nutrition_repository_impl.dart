import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_record.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_remote_datasource.dart';
import '../models/food_record_model.dart';
import '../models/meal_plan_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NutritionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Food>>> getFoods() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final foods = await remoteDataSource.getFoods();
      return Right(foods);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Food>>> searchFoods(String query) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final foods = await remoteDataSource.getFoods();
      final filtered = foods
          .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return Right(filtered);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Food>>> getFoodsByCategory(String category) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final foods = await remoteDataSource.getFoods(category: category);
      return Right(foods);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FoodRecord>> addFoodRecord(FoodRecord record) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = FoodRecordModel.fromEntity(record);
      final result = await remoteDataSource.addFoodLog(model.toJson());
      return Right(result);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FoodRecord>>> getFoodRecordsByDate(
    String userId,
    DateTime date,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final logs = await remoteDataSource.getFoodLogs();
      final filtered = logs
          .where((l) =>
              l.recordedAt.year == date.year &&
              l.recordedAt.month == date.month &&
              l.recordedAt.day == date.day)
          .toList();
      return Right(filtered);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFoodRecord(String recordId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.deleteFoodLog(recordId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MealPlan>> getMealPlan(String userId, DateTime date) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final plans = await remoteDataSource.getMealPlans();
      if (plans.isEmpty) {
        return Left(const ServerFailure('No hay planes alimenticios'));
      }
      return Right(plans.first);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MealPlan>> generateMealPlan(
    String userId,
    DateTime date,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = MealPlanModel(
        id: '',
        userId: userId,
        title: 'Plan semanal',
        description: '',
        breakfast: const [],
        lunch: const [],
        dinner: const [],
        snacks: const [],
        totalSodiumMg: 0,
        totalPotassiumMg: 0,
        totalCalories: 0,
        date: date,
      );
      final result = await remoteDataSource.createMealPlan(model.toJson());
      return Right(result);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
