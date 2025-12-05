import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithApple();
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> updateProfile({String? fullName, String? phone, String? avatarUrl});
}
