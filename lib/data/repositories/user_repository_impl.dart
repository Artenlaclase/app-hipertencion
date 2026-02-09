import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/services/auth_token_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AuthTokenService authTokenService;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.authTokenService,
  });

  @override
  Future<Either<Failure, UserProfile>> createProfile(
    UserProfile profile,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      // The profile creation is handled via register endpoint
      // This converts the domain entity to an API-compatible format
      final userModel = UserModel(
        id: profile.id,
        name: profile.name,
        age: profile.age,
        gender: profile.gender,
        weight: profile.weight,
        height: profile.height,
        activityLevel: profile.activityLevel,
        hypertensionLevel: profile.hypertensionLevel,
        initialSystolic: profile.initialSystolic,
        initialDiastolic: profile.initialDiastolic,
        createdAt: profile.createdAt,
        hasAcceptedDisclaimer: profile.hasAcceptedDisclaimer,
      );
      final profileData = userModel.toJson();
      final result = await remoteDataSource.updateProfile(profileData);
      await authTokenService.saveUserId(result.id);
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
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.getMe();
      return Right(result);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
    UserProfile profile,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final userModel = UserModel(
        id: profile.id,
        name: profile.name,
        age: profile.age,
        gender: profile.gender,
        weight: profile.weight,
        height: profile.height,
        activityLevel: profile.activityLevel,
        hypertensionLevel: profile.hypertensionLevel,
        initialSystolic: profile.initialSystolic,
        initialDiastolic: profile.initialDiastolic,
        createdAt: profile.createdAt,
        hasAcceptedDisclaimer: profile.hasAcceptedDisclaimer,
      );
      final result = await remoteDataSource.updateProfile(userModel.toJson());
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
  Future<Either<Failure, bool>> acceptDisclaimer(String userId) async {
    await authTokenService.setDisclaimerAccepted(true);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    return Right(authTokenService.hasCompletedOnboarding);
  }

  /// Register a new user.
  Future<Either<Failure, UserProfile>> register({
    required String name,
    required String email,
    required String password,
    required UserProfile profile,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final userModel = UserModel(
        id: '',
        name: name,
        age: profile.age,
        gender: profile.gender,
        weight: profile.weight,
        height: profile.height,
        activityLevel: profile.activityLevel,
        hypertensionLevel: profile.hypertensionLevel,
        initialSystolic: profile.initialSystolic,
        initialDiastolic: profile.initialDiastolic,
        createdAt: DateTime.now(),
      );
      await remoteDataSource.register(
        userModel.toRegisterJson(email, password),
      );
      // Get user data after registration
      final user = await remoteDataSource.getMe();
      await authTokenService.saveUserId(user.id);
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  /// Login an existing user.
  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.login(email, password);
      final user = await remoteDataSource.getMe();
      await authTokenService.saveUserId(user.id);
      return Right(user);
    } on UnauthorizedException {
      return const Left(AuthFailure('Credenciales incorrectas'));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  /// Logout the current user.
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (_) {
      await authTokenService.clearAuth();
      return const Right(null);
    }
  }
}
