// lib/core/features/booking/data/cubit/booking_state.dart
part of 'booking_cubit.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}
class BookingDetailLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  BookingsLoaded(this.bookings);
}

class BookingDetailLoaded extends BookingState {
  final PostBookingDetail detail;
  BookingDetailLoaded(this.detail);
}

class BookingCreateSuccess extends BookingState {
  final CreateBookingResponse response;
  BookingCreateSuccess(this.response);
}

class BookingCancelled extends BookingState {
  final CancelBookingResponse response;
  BookingCancelled(this.response);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}