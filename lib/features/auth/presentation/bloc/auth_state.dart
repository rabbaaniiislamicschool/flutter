import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required UserEntity user,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error({
    required Failure failure,
  }) = _Error;
  const factory AuthState.passwordResetSent({
    required String email,
  }) = _PasswordResetSent;
  const factory AuthState.otpVerified() = _OtpVerified;
  const factory AuthState.passwordResetSuccess() = _PasswordResetSuccess;
}
