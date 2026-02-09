import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_datasource.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HabitRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Habit>>> getHabits(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final habits = await remoteDataSource.getHabits();
      // Enrich with completion logs
      final logs = await remoteDataSource.getHabitLogs();
      final enrichedHabits = habits.map((habit) {
        final habitLogs = logs.where((l) => l.habitId == habit.id).toList();
        final completedDates = habitLogs.map((l) => l.completedAt).toList();
        return HabitModel(
          id: habit.id,
          userId: userId,
          title: habit.title,
          description: habit.description,
          icon: habit.icon,
          isActive: habit.isActive,
          completedDates: completedDates,
          createdAt: habit.createdAt,
        );
      }).toList();
      return Right(enrichedHabits);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Habit>> createHabit(Habit habit) async {
    // The API has a catalog of habits, users log completion
    // For now, return the habit as-is
    return Right(habit);
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(Habit habit) async {
    return Right(habit);
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Habit>> completeHabit(String habitId, DateTime date) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final logModel = HabitLogModel(
        id: '',
        userId: '',
        habitId: habitId,
        completedAt: date,
      );
      await remoteDataSource.addHabitLog(logModel.toJson());
      final habit = await remoteDataSource.getHabit(habitId);
      return Right(habit);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  // Reminders — handled locally via flutter_local_notifications
  @override
  Future<Either<Failure, List<Reminder>>> getReminders(String userId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Reminder>> createReminder(Reminder reminder) async {
    return Right(reminder);
  }

  @override
  Future<Either<Failure, Reminder>> updateReminder(Reminder reminder) async {
    return Right(reminder);
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Reminder>> toggleReminder(String reminderId) async {
    return const Left(ServerFailure('No implementado'));
  }
}
