import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_datasource.dart';

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EducationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EducationContent>>> getContents() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final contents = await remoteDataSource.getContents();
      return Right(contents);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<EducationContent>>> getContentsByCategory(
    String category,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final contents = await remoteDataSource.getContents(topic: category);
      return Right(contents);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, EducationContent>> getContentById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final content = await remoteDataSource.getContent(id);
      return Right(content);
    } on UnauthorizedException {
      return const Left(AuthFailure());
    } on NotFoundException {
      return const Left(ServerFailure('Contenido no encontrado'));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String contentId) async {
    // Stored locally for now
    return const Right(null);
  }
}
