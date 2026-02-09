import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/blood_pressure.dart';
import '../../domain/repositories/blood_pressure_repository.dart';
import '../datasources/blood_pressure_remote_datasource.dart';
import '../models/blood_pressure_model.dart';

class BloodPressureRepositoryImpl implements BloodPressureRepository {
  final BloodPressureRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BloodPressureRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BloodPressure>> addRecord(BloodPressure record) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = BloodPressureModel.fromEntity(record);
      final result = await remoteDataSource.addRecord(model.toJson());
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
  Future<Either<Failure, List<BloodPressure>>> getRecords(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final records = await remoteDataSource.getRecords();
      return Right(records);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BloodPressure>>> getRecordsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final allRecords = await remoteDataSource.getRecords();
      final filtered = allRecords
          .where((r) =>
              r.recordedAt.isAfter(start.subtract(const Duration(days: 1))) &&
              r.recordedAt.isBefore(end.add(const Duration(days: 1))))
          .toList();
      return Right(filtered);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, BloodPressure?>> getLatestRecord(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final records = await remoteDataSource.getRecords();
      if (records.isEmpty) return const Right(null);
      records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      return Right(records.first);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String recordId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.deleteRecord(recordId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
