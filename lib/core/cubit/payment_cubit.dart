// lib/core/features/payment/data/cubit/payment_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/payment_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repo;

  PaymentCubit(this.repo) : super(const PaymentInitial());

  Future<void> createPayment(int bookingId) async {
    emit(const PaymentLoading());
    try {
      final response = await repo.createPayment(bookingId);
      emit(PaymentSuccess(
        status: response['status'] ?? 'success',
        bookingStatus: response['booking_status'] ?? 'confirmed',
      ));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}