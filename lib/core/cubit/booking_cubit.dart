import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/request/booking_request.dart';
import '../models/response/booking.dart';
import '../models/response/booking_details.dart';
import '../models/response/booking_response.dart';
import '../repository/booking_repository.dart';
import '../utils/local_storage/session_manager.dart';

part 'booking_state.dart';
// lib/features/booking/data/cubit/booking_cubit.dart
class BookingCubit extends Cubit<BookingState> {
  final BookingRepository repo;

  BookingCubit(this.repo) : super(const BookingInitial());

  Future<void> fetchBookings() async {
    if (SessionManager().isGuest) {
      emit(BookingLoaded(bookings: [])); // or appropriate empty/guest state
      return;
    }
    emit(const BookingLoading());
    try {
      final bookings = await repo.getBookings();
      emit(BookingLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> fetchBookingDetails(int id) async {
    if (SessionManager().isGuest) {
      emit(BookingLoaded(bookings: [])); // or appropriate empty/guest state
      return;
    }
    emit(const BookingLoading());
    try {
      final detail = await repo.getBookingDetails(id);
      final current = state is BookingLoaded ? state as BookingLoaded : null;
      emit(BookingLoaded(
        bookings: current?.bookings ?? [],
        selectedBooking: detail,
      ));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> createBooking(CreateBookingRequest request) async {
    if (SessionManager().isGuest) {
      emit(BookingLoaded(bookings: [])); // or appropriate empty/guest state
      return;
    }
    emit(const BookingLoading());
    try {
      final response = await repo.createBooking(request);
      if (response.success) {
        // after successful creation, refresh bookings
        final bookings = await repo.getBookings();
        emit(BookingLoaded(
          bookings: bookings,
          createResponse: response,
        ));
      } else {
        emit(BookingError(response.error ?? 'Booking failed'));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(int id) async {
    if (SessionManager().isGuest) {
      emit(BookingLoaded(bookings: [])); // or appropriate empty/guest state
      return;
    }
    emit(const BookingLoading());
    try {
      final response = await repo.cancelBooking(id);
      if (response.success) {
        final bookings = await repo.getBookings();
        emit(BookingLoaded(bookings: bookings, cancelResponse: response));
      } else {
        emit(BookingError(response.error ?? 'Cancellation failed'));
      }
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}