import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_entity.freezed.dart';

@freezed
class PaymentEntity with _$PaymentEntity {
  const factory PaymentEntity({
    required String id,
    String? invitationId,
    String? userId,
    required double amount,
    required PaymentType type,
    required PaymentGateway gateway,
    required PaymentMethod method,
    String? paymentChannel,
    required String merchantOrderId,
    String? gatewayReference,
    String? paymentUrl,
    String? vaNumber,
    String? qrString,
    @Default(PaymentStatus.pending) PaymentStatus status,
    DateTime? paidAt,
    DateTime? expiredAt,
    double? gatewayFee,
    required DateTime createdAt,
  }) = _PaymentEntity;
}

enum PaymentType { subscription, envelope }
enum PaymentGateway { duitku, flip }
enum PaymentMethod { va, qris, ewallet, creditCard, retail }
enum PaymentStatus { pending, success, failed, expired }

@freezed
class CreatePaymentParams with _$CreatePaymentParams {
  const factory CreatePaymentParams({
    required PaymentType type,
    required double amount,
    required PaymentMethod method,
    required String paymentChannel,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    // For subscription
    String? packageType,
    List<String>? addons,
    // For envelope
    String? invitationId,
    String? message,
    @Default(false) bool isAnonymous,
  }) = _CreatePaymentParams;
}

@freezed
class PaymentResult with _$PaymentResult {
  const factory PaymentResult({
    required String merchantOrderId,
    required String paymentUrl,
    String? vaNumber,
    String? qrString,
    required double amount,
    required DateTime expiredAt,
  }) = _PaymentResult;
}
