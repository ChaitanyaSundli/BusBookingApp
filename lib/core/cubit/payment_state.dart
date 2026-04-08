// lib/core/features/payment/data/cubit/payment_state.dart
part of 'payment_cubit.dart';

sealed class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSuccess extends PaymentState {
  final String status;
  final String bookingStatus;
  const PaymentSuccess({required this.status, required this.bookingStatus});
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
}