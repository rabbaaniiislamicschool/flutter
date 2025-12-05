import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/payment_entity.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

part 'payment_bloc.freezed.dart';

@freezed
class PaymentEvent with _$PaymentEvent {
  const factory PaymentEvent.createPayment({
    required CreatePaymentParams params,
  }) = _CreatePayment;
  const factory PaymentEvent.checkPaymentStatus({
    required String merchantOrderId,
  }) = _CheckPaymentStatus;
  const factory PaymentEvent.loadPaymentHistory() = _LoadPaymentHistory;
}

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;
  const factory PaymentState.loading() = _Loading;
  const factory PaymentState.paymentCreated({
    required PaymentResult result,
  }) = _PaymentCreated;
  const factory PaymentState.paymentStatus({
    required PaymentEntity payment,
  }) = _PaymentStatus;
  const factory PaymentState.historyLoaded({
    required List<PaymentEntity> payments,
  }) = _HistoryLoaded;
  const factory PaymentState.success({
    required PaymentEntity payment,
  }) = _Success;
  const factory PaymentState.error({
    required Failure failure,
  }) = _Error;
}

// Placeholders for UseCases
class CreatePaymentUseCase {
  Future<Either<Failure, PaymentResult>> call(CreatePaymentParams params) async => throw UnimplementedError();
}
class CheckPaymentStatusUseCase {
  Future<Either<Failure, PaymentEntity>> call(String merchantOrderId) async => throw UnimplementedError();
}
class GetPaymentHistoryUseCase {
  Future<Either<Failure, List<PaymentEntity>>> call() async => throw UnimplementedError();
}


@injectable
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentUseCase _createPaymentUseCase;
  final CheckPaymentStatusUseCase _checkPaymentStatusUseCase;
  final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;

  PaymentBloc(
    this._createPaymentUseCase,
    this._checkPaymentStatusUseCase,
    this._getPaymentHistoryUseCase,
  ) : super(const PaymentState.initial()) {
    on<PaymentEvent>((event, emit) async {
      await event.when(
        createPayment: (params) => _createPayment(params, emit),
        checkPaymentStatus: (orderId) => _checkStatus(orderId, emit),
        loadPaymentHistory: () => _loadHistory(emit),
      );
    });
  }

  Future<void> _createPayment(
    CreatePaymentParams params,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());

    final result = await _createPaymentUseCase(params);

    result.fold(
      (failure) => emit(PaymentState.error(failure: failure)),
      (paymentResult) => emit(PaymentState.paymentCreated(result: paymentResult)),
    );
  }

  Future<void> _checkStatus(String orderId, Emitter<PaymentState> emit) async {
    emit(const PaymentState.loading());
    final result = await _checkPaymentStatusUseCase(orderId);
    result.fold(
      (failure) => emit(PaymentState.error(failure: failure)),
      (payment) => emit(PaymentState.paymentStatus(payment: payment)),
    );
  }

  Future<void> _loadHistory(Emitter<PaymentState> emit) async {
    emit(const PaymentState.loading());
    final result = await _getPaymentHistoryUseCase();
    result.fold(
      (failure) => emit(PaymentState.error(failure: failure)),
      (payments) => emit(PaymentState.historyLoaded(payments: payments)),
    );
  }
}
