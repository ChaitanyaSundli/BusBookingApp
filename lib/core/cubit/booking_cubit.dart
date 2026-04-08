// lib/core/features/booking/data/cubit/booking_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/request/booking_request.dart';
import '../models/response/booking.dart';
import '../models/response/post_booking_detail.dart';
import '../models/response/booking_response.dart';
import '../repository/booking_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repo;

  BookingCubit(this.repo) : super(BookingInitial());

  Future<void> createBooking(CreateBookingRequest request) async {
    emit(BookingLoading());
    try {
      final response = await repo.createBooking(request);
      if (response.success) {
        emit(BookingCreateSuccess(response));
      } else {
        emit(BookingError(response.error ?? 'Booking failed'));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> fetchBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await repo.getBookings();
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> fetchBookingDetails(int id) async {
    emit(BookingDetailLoading());
    try {
      final detail = await repo.getBookingDetails(id);
      emit(BookingDetailLoaded(detail));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(int id) async {
    emit(BookingLoading());
    try {
      final response = await repo.cancelBooking(id);
      if (response.success) {
        emit(BookingCancelled(response));
      } else {
        emit(BookingError(response.error ?? 'Cancellation failed'));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}