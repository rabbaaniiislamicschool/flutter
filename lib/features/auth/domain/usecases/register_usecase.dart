import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String fullName;
  final String? phone;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
  });
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return _repository.register(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      phone: params.phone,
    );
  }
}
