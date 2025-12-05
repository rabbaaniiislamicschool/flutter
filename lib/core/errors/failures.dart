import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.network({
    @Default('No internet connection') String message,
  }) = NetworkFailure;

  const factory Failure.cache({
    @Default('Cache failure') String message,
  }) = CacheFailure;

  const factory Failure.auth({
    required String message,
    String? code,
  }) = AuthFailure;

  const factory Failure.validation({
    required Map<String, String> errors,
  }) = ValidationFailure;

  const factory Failure.notFound({
    @Default('Resource not found') String message,
  }) = NotFoundFailure;

  const factory Failure.permission({
    @Default('Permission denied') String message,
  }) = PermissionFailure;

  const factory Failure.payment({
    required String message,
    String? gatewayCode,
  }) = PaymentFailure;
}
