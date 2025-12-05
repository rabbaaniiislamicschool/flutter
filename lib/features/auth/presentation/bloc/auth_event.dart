import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkAuthStatus() = _CheckAuthStatus;
  const factory AuthEvent.loginWithEmail({
    required String email,
    required String password,
  }) = _LoginWithEmail;
  const factory AuthEvent.loginWithGoogle() = _LoginWithGoogle;
  const factory AuthEvent.loginWithApple() = _LoginWithApple;
  const factory AuthEvent.register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) = _Register;
  const factory AuthEvent.forgotPassword({
    required String email,
  }) = _ForgotPassword;
  const factory AuthEvent.verifyOtp({
    required String email,
    required String otp,
  }) = _VerifyOtp;
  const factory AuthEvent.resetPassword({
    required String newPassword,
  }) = _ResetPassword;
  const factory AuthEvent.updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) = _UpdateProfile;
  const factory AuthEvent.logout() = _Logout;
}
